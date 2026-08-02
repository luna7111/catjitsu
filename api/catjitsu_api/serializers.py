from typing import Any

from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Player
from .models import Match

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            username = validated_data['username'],
            password = validated_data['password']
        )
        return user

class PlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Player
        # fields = ['id', 'name', 'nickname']
        fields = '__all__' #TODO remove for prod and update line above
    
class MatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Match
        # fields = ['id', 'name', 'code', 'winner', 'player1', 'player2']
        fields = '__all__' #TODO remove for prod and update line above

    def validate(self, attrs):
        instance = Match(**attrs)
        try:
            instance.clean()
        except serializers.ValidationError as e:
            raise serializers.ValidationError(e.__dict__)
        
        return attrs