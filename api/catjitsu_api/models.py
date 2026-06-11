from django.db import models

class Player(models.Model):
    
    name = models.CharField(max_length=200)

    # class Meta:
    #     verbose_name = _("player")
    #     verbose_name_plural = _("players")

    def __str__(self):
        return self.name

    # def get_absolute_url(self):
    #     return reverse("player_detail", kwargs={"pk": self.pk})
