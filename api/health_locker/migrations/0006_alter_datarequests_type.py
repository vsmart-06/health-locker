# Generated by Django 5.1.2 on 2024-12-27 11:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('health_locker', '0005_datarequests'),
    ]

    operations = [
        migrations.AlterField(
            model_name='datarequests',
            name='type',
            field=models.JSONField(),
        ),
    ]
