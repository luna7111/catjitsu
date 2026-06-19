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
    #     verbose_name_plural = _("matchs")

    def __str__(self):
        return self.name

    # def get_absolute_url(self):
    #     return reverse("match_detail", kwargs={"pk": self.pk})
