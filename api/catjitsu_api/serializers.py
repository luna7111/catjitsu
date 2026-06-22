from rest_framework import serializers
from .models import Player
from .models import Match

class PlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        fields = ['id', 'name', 'nickname']

class MatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Match
        fields = ['id', 'name', 'code', 'winner', 'player1', 'player2']