from .models import Player
from .models import Match
from .serializers import PlayerSerializer
from .serializers import MatchSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework_api_key.permissions import HasAPIKey

from django import shortcuts

class PlayerList(APIView):
    @api_view(['GET'])
    def get(self):
        players = Player.objects.all()
        serializer = PlayerSerializer(players, many=True)
        return Response({'players': serializer.data})

    @api_view(['POST'])
    def post(self, request):
        serializer = PlayerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

class PlayerDetail(APIView):
    def get_object(self, pk):
        return shortcuts.aget_object_or_404(Player, pk=pk)

    @api_view(['GET'])
    def get(self, request, pk):
        player = self.get_object(pk)
        serializer = PlayerSerializer(player)
        return Response(serializer.data)
    
    @api_view(['PUT'])
    def put(self, request, pk):
        player = self.get_object(pk)
        data = request.data
        serializer = PlayerSerializer(player, data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @api_view(['DELETE'])
    def delete(self, request, pk):
        player = self.get_object(pk)
        player.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class MatchList(APIView):
    @api_view(['GET'])
    def get(self, request):
        matches = Match.objects.all()
        serializer = MatchSerializer(matches, many=True)
        return Response({'matches': serializer.data})

    @api_view(['POST'])
    def post(self, request):
        serializer = MatchSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

class MatchDetail(APIView):
    def get_object(self, pk):
        return shortcuts.aget_object_or_404(Match, pk=pk)

    @api_view(['GET'])
    def get(self, request, pk):
        match = self.get_object(pk)
        serializer = MatchSerializer(match)
        return Response(serializer.data)
    
    @api_view(['PUT'])
    def put(self, request, pk):
        match = self.get_object(pk)
        data = request.data
        serializer = MatchSerializer(match, data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @api_view(['DELETE'])
    def delete(self, request, pk):
        match = self.get_object(pk)
        match.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

