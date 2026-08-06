# Generated migration to add avatar field to Player
from django.db import migrations, models

class Migration(migrations.Migration):

    dependencies = [
        ('catjitsu_api', '0005_remove_player_name_remove_player_nickname'),
    ]

    operations = [
        migrations.AddField(
            model_name='player',
            name='avatar',
            field=models.CharField(max_length=200, blank=True, default=''),
        ),
    ]
