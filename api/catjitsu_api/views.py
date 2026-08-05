from django.contrib.auth import authenticate
import requests
import secrets
from datetime import timedelta
from http.client import HTTPResponse
from django.contrib.auth.models import User
from django.core.cache import cache
from django.utils import timezone
from rest_framework.authtoken.models import Token
from .models import Player, AuthIdentity
from .models import Match
from .serializers import UserSerializer
from .serializers import PlayerSerializer
from .serializers import MatchSerializer
from django.http import HttpResponse
from django.conf import settings
from django.shortcuts import redirect
from urllib.parse import urlencode
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import generics
from rest_framework import status
from rest_framework.views import APIView
from rest_framework_api_key.permissions import HasAPIKey
from rest_framework_simplejwt.tokens import RefreshToken
from django import shortcuts

from django.contrib.auth.forms import UserCreationForm

class RegisterUser(generics.CreateAPIView):
    serializer_class = UserSerializer

class LoginUser(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username = username, password = password)
        if user is not None:
            token, created = Token.objects.get_or_create(user = user)
            return Response({'token':token.key}, status=status.HTTP_200_OK)
        return Response({'error': 'Invalid Credentials'}, status=status.HTTP_400_BAD_REQUEST)


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
            'player-id': player.id,
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

        # defensively parse the token response and handle errors
        try:
            token = token_response.json()
        except ValueError:
            return Response({'error': 'Invalid token response from provider'}, status=status.HTTP_502_BAD_GATEWAY)

        if token_response.status_code != 200 or 'access_token' not in token:
            # include provider JSON in details for debugging
            return Response({'error': 'OAuth token exchange failed', 'details': token}, status=status.HTTP_400_BAD_REQUEST)

        access_token = token.get("access_token")

        # fetch user info using the received access token
        user_response = requests.get(
            "https://api.intra.42.fr/v2/me",
            headers={
                "Authorization": f"Bearer {access_token}"
            }
        )

        try:
            user_data = user_response.json()
        except ValueError:
            return Response({'error': 'Invalid user info response from provider'}, status=status.HTTP_502_BAD_GATEWAY)

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
        # remove transient/session fields just in case
        sanitized = []
        for item in serializer.data:
            entry = dict(item)
            entry.pop('current_session_uuid', None)
            entry.pop('current_session_uuid_set_at', None)
            sanitized.append(entry)
        return Response({'players': sanitized})

class PlayerDetail(APIView):
    def get_object(self, pk):
        return shortcuts.get_object_or_404(Player, pk=pk)

    def get(self, request, pk):
        player = self.get_object(pk)
        serializer = PlayerSerializer(player)
        data = dict(serializer.data)
        # remove sensitive/transient fields
        data.pop('current_session_uuid', None)
        data.pop('current_session_uuid_set_at', None)
        # build preferences using serializer fields so logic stays consistent
        prefs = {
            'language': data.pop('language', serializer.data.get('language', '')),
            'screenreader': data.pop('screenreader', serializer.data.get('screenreader', False)),
            'volume': data.pop('volume', serializer.data.get('volume', 50)),
        }
        data['preferences'] = prefs
        return Response(data)
    
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
        return shortcuts.get_object_or_404(Match, pk=pk)

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


class PlayerAvatar(APIView):
    """Endpoint to update a player's avatar string. Supports PUT and POST."""
    def put(self, request, pk):
        player = shortcuts.get_object_or_404(Player, pk=pk)
        avatar = request.data.get('avatar')
        if avatar is None:
            return Response({'error': 'avatar required'}, status=status.HTTP_400_BAD_REQUEST)
        player.avatar = avatar
        player.save()
        serializer = PlayerSerializer(player)
        return Response(serializer.data)

    def post(self, request, pk):
        return self.put(request, pk)


class PlayerPreferences(APIView):
    """Endpoint to update player's language, screenreader and volume preference."""
    def put(self, request, pk):
        player = shortcuts.get_object_or_404(Player, pk=pk)
        updated = False
        language = request.data.get('language')
        if language is not None:
            player.language = language
            updated = True
        # screenreader may come as bool or string
        if 'screenreader' in request.data:
            sr = request.data.get('screenreader')
            # coerce to bool
            if isinstance(sr, bool):
                player.screenreader = sr
            else:
                # accept "true"/"false" or "1"/"0"
                player.screenreader = str(sr).lower() in ['1','true','yes']
            updated = True
        # volume: accept int-like values and clamp
        if 'volume' in request.data:
            try:
                vol = int(request.data.get('volume'))
            except (TypeError, ValueError):
                return Response({'error': 'volume must be an integer between 0 and 100'}, status=status.HTTP_400_BAD_REQUEST)
            vol = max(0, min(100, vol))
            player.volume = vol
            updated = True
        if not updated:
            return Response({'error': 'language, screenreader or volume required'}, status=status.HTTP_400_BAD_REQUEST)
        player.save()
        serializer = PlayerSerializer(player)
        return Response(serializer.data)

    def post(self, request, pk):
        return self.put(request, pk)
