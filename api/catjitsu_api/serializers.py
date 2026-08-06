from typing import Any

from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError# as DjangoValidationError
from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Player
from .models import Match

class UserAuthSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'password']

    def validate_password(self, value):
        try:
            validate_password(value) # Runs Django's configured AUTH_PASSWORD_VALIDATORS against the password
        except ValidationError as e: # ensures proper exception is raised and error message sent
            raise serializers.ValidationError(list(e.messages))
        return value

    def create(self, validated_data): # this ensures Django hashes the password upon user registration
        user = User.objects.create_user(
            username = validated_data['username'],
            password = validated_data['password']
        )
        Player.objects.create(
            user = user,
            deck = 'defaultdeck',
            avatar = 'Apolito',
            language = 'en',
            screenreader = False,
            volume = 100,
            current_session_uuid = None,
            current_session_uuid_set_at = None,
        )
        return user

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'first_name']

class PlayerSerializer(serializers.ModelSerializer):
    # expose username from related User for convenience
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Player
        # keep fields explicit to avoid exposing transient/session data
        fields = ['id', 'user', 'username', 'deck', 'avatar', 'language', 'screenreader', 'volume']
    
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