import requests
import secrets
from datetime import timedelta
from http.client import HTTPResponse
from django.contrib.auth.models import User
from django.core.cache import cache
from django.utils import timezone
from .models import Player, AuthIdentity
from .models import Match
from .serializers import PlayerSerializer
from .serializers import MatchSerializer
from django.http import HttpResponse
from django.conf import settings
from django.shortcuts import redirect
from urllib.parse import urlencode
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework_api_key.permissions import HasAPIKey
from rest_framework_simplejwt.tokens import RefreshToken


from django import shortcuts

class TestGame(APIView):
    def get(self, request):
        return shortcuts.render(request, 'game/catjitsu.html', {})

#TODO: maybe this sould be a POST or something idk
#TODO: cleanly manage timeout (this is a Godot thing but maybe there is a response code or something idk)
class IdentifyClient(APIView):
    def get(self, request):
        exchange_uuid = request.GET.get("exchange_uuid", '')
        if not exchange_uuid:
            return Response({"error": "exchange_uuid required"}, status=status.HTTP_400_BAD_REQUEST)
        
        player = Player.objects.filter(current_session_uuid=exchange_uuid).first()
        if not player:
            return Response({"error": "Invalid or expired exchange_uuid"}, status=status.HTTP_401_UNAUTHORIZED)
        
        if player.current_session_uuid_set_at and timezone.now() - player.current_session_uuid_set_at > timedelta(minutes=5):
            player.current_session_uuid = None
            player.current_session_uuid_set_at = None
            player.save()
            return Response({"error": "Invalid or expired exchange_uuid"}, status=status.HTTP_401_UNAUTHORIZED)
        
        refresh = RefreshToken.for_user(player.user)
        
        player.current_session_uuid = None
        player.current_session_uuid_set_at = None
        player.save()
        
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'nickname': player.nickname
        })

class OAuth42Login(APIView):
    def get(self, request):
        exchange_uuid = request.GET.get('exchange_uuid', '')
        print("exchange_uuid is: " + exchange_uuid)
        
        params = {
            "client_id": settings.CLIENT_ID,
            "redirect_uri": settings.REDIRECT_URI,
            "response_type": "code",
            "scope": "public",
            "state": exchange_uuid,
        }

        url = "https://api.intra.42.fr/oauth/authorize?" + urlencode(params)

        return redirect(url)

class OAuth42Callback(APIView):
    def get(self, request):
        code = request.GET.get("code")
        exchange_uuid = request.GET.get("state", "")

        token_response = requests.post(
            "https://api.intra.42.fr/oauth/token",
            data={
                "grant_type": "authorization_code",
                "client_id": settings.CLIENT_ID,
                "client_secret": settings.CLIENT_SECRET,
                "code": code,
                "redirect_uri": settings.REDIRECT_URI,
            }
        )

        token = token_response.json()
        access_token = token["access_token"]

        user_response = requests.get(
            "https://api.intra.42.fr/v2/me",
            headers={
                "Authorization": f"Bearer {access_token}"
            }
        )

        user_data = user_response.json()

        identity = AuthIdentity.objects.filter(
            provider="42",
            oauth_id=str(user_data["id"])
        ).first()

        if identity:
            player = identity.player
        else:
            user = User.objects.filter(username=user_data["login"]).first()
            if not user:
                user = User.objects.create_user(
                    username=user_data["login"],
                    email=user_data["email"],
                )

            player = Player.objects.filter(user=user).first()
            if not player:
                player = Player.objects.create(
                    user=user,
                    name=user_data["displayname"],
                    nickname=user_data["login"],
                    deck=""
                )

            identity = AuthIdentity.objects.create(
                player=player,
                provider="42",
                oauth_id=str(user_data["id"])
            ) #TODO check this

        if exchange_uuid:
            player.current_session_uuid = exchange_uuid
            player.current_session_uuid_set_at = timezone.now()
            player.save()

        auth_code = secrets.token_urlsafe(32)
        cache_data = {"player_id": player.id}
        if exchange_uuid:
            cache_data["exchange_uuid"] = exchange_uuid
        cache.set(f"auth_code_{auth_code}", cache_data, timeout=300)

        print("uuid from callback: " + exchange_uuid)

        return redirect("http://127.0.0.1:8000/auth/completed")
 
 
def auth_completed(request):
    return shortcuts.render(request, 'catjitsu_api/auth_completed.html', {})

@api_view(['POST']) #TODO convert to classes
def token_exchange(request):
    code = request.data.get('code')
    if not code:
        return Response({'error': 'code required'}, status=status.HTTP_400_BAD_REQUEST)
    
    cache_data = cache.get(f"auth_code_{code}")
    if not cache_data:
        return Response({'error': 'Invalid or expired code'}, status=status.HTTP_401_UNAUTHORIZED)
    
    cache.delete(f"auth_code_{code}")
    
    player_id = cache_data.get('player_id')
    exchange_uuid = cache_data.get('exchange_uuid')
    
    player = Player.objects.get(id=player_id)
    refresh = RefreshToken.for_user(player.user)
    
    response_data = {
        'access': str(refresh.access_token),
        'refresh': str(refresh)
    }
    if exchange_uuid:
        response_data['exchange_uuid'] = exchange_uuid
    
    return Response(response_data)

class PlayerList(APIView):
    def get(self, request):
        players = Player.objects.all()
        serializer = PlayerSerializer(players, many=True)
        return Response({'players': serializer.data})

    def post(self, request):
        serializer = PlayerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

class PlayerDetail(APIView):
    def get_object(self, pk):
        return shortcuts.aget_object_or_404(Player, pk=pk)

    def get(self, request, pk):
        player = self.get_object(pk)
        serializer = PlayerSerializer(player)
        return Response(serializer.data)
    
    def put(self, request, pk):
        player = self.get_object(pk)
        data = request.data
        serializer = PlayerSerializer(player, data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        player = self.get_object(pk)
        player.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class MatchList(APIView):
    def get(self, request):
        matches = Match.objects.all()
        serializer = MatchSerializer(matches, many=True)
        return Response({'matches': serializer.data})

    def post(self, request):
        serializer = MatchSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

class MatchDetail(APIView):
    def get_object(self, pk):
        return shortcuts.aget_object_or_404(Match, pk=pk)

    def get(self, request, pk):
        match = self.get_object(pk)
        serializer = MatchSerializer(match)
        return Response(serializer.data)
    
    def put(self, request, pk):
        match = self.get_object(pk)
        data = request.data
        serializer = MatchSerializer(match, data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        match = self.get_object(pk)
        match.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

