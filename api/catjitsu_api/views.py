from django.http import JsonResponse
from .models import Player
from .models import Match
from .serializers import PlayerSerializer
from .serializers import MatchSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['GET', 'POST'])
def player_list(request):

    if request.method == 'GET':
        players = Player.objects.all()
        serializer = PlayerSerializer(players, many=True)
        return JsonResponse({'players': serializer.data})

    elif request.method == 'POST':
        serializer = PlayerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET', 'POST'])
def match_list(request):

    if request.method == 'GET':
        matches = Match.objects.all()
        serializer = MatchSerializer(matches, many=True)
        return Response({'matches': serializer.data})

    elif request.method == 'POST':
        serializer = MatchSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET', 'PUT', 'DELETE'])
def match(request, id):
    
    try:
        match = Match.objects.get(pk=id)
    except Match.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = MatchSerializer(match)
        return Response(serializer.data)

    elif request.method == 'PUT':
        print("on est dans put")
        data = request.data
        serializer = MatchSerializer(match, data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        match.delete()
        return Response() #TODO find appropriate error code and how to send it
