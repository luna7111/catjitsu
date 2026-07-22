from rest_framework import serializers
from .models import Player
from .models import Match

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