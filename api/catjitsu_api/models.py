from django.core.exceptions import ValidationError
from django.db import models

class Player(models.Model):
    
    name = models.CharField(max_length=200)
    nickname = models.CharField(max_length=50, default="")

    # class Meta:
    #     verbose_name = _("player")
    #     verbose_name_plural = _("players")

    def __str__(self):
        return self.name

    # def get_absolute_url(self):
    #     return reverse("player_detail", kwargs={"pk": self.pk})

class Match(models.Model):

    name = models.CharField(max_length=100)
    code = models.CharField(max_length=10)
    winner = models.ForeignKey(Player, on_delete=models.RESTRICT, related_name="won_the_match", null=True, blank=True)
    player1 = models.ForeignKey(Player, on_delete=models.RESTRICT, related_name="plays_as_one")
    player2 = models.ForeignKey(Player, on_delete=models.RESTRICT, related_name="plays_as_two", null=True, blank=True)

    # class Meta:
    #     verbose_name = _("match")
    #     verbose_name_plural = _("matches")

    def clean(self):
        super().clean()
        
        if self.code.__len__() != 10: # TODO find a better way to enforce code format, maybe external func, should be generated
            raise ValidationError({'code': "the unique code must be 10 characters long"})
        if self.player1 == self.player2:
            raise ValidationError({'player2': "a player can not play against himself"})
        if self.winner:
            if not self.player2:
                raise ValidationError({'winner': "winner can only be declared if two players are in the match"})
            elif self.winner != self.player1 and self.winner != self.player2:
                raise ValidationError({'winner': "the winner must be one of the match participants"})

    def __str__(self):
        return self.name

    # def get_absolute_url(self):
    #     return reverse("match_detail", kwargs={"pk": self.pk})
