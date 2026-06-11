from django.http import JsonResponse
from .models import Player
from .serializers import PlayerSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

@api_view(['GET', 'POST'])
def player_list(request):

    if request.method == 'GET':
        players = Player.objects.all()
        serializer = PlayerSerializer(players, many=True)
        return JsonResponse({'players': serializer.data})

    if request.method == 'POST':
        serializer = PlayerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
