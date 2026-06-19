from django.contrib import admin
from .models import Player
from .models import Match

admin.site.register(Player)
admin.site.register(Match)