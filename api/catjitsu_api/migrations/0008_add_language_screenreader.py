# Generated migration to add language and screenreader fields to Player
from django.db import migrations, models

class Migration(migrations.Migration):

    dependencies = [
        ('catjitsu_api', '0007_alter_player_avatar'),
    ]

    operations = [
        migrations.AddField(
            model_name='player',
            name='language',
            field=models.CharField(max_length=10, blank=True, default='en'),
        ),
        migrations.AddField(
            model_name='player',
            name='screenreader',
            field=models.BooleanField(default=False),
        ),
    ]
