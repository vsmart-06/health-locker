# Generated by Django 5.1.2 on 2024-12-27 11:36

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('health_locker', '0007_rename_approved_datarequests_status'),
    ]

    operations = [
        migrations.AlterField(
            model_name='datarequests',
            name='status',
            field=models.BooleanField(default=False, null=True),
        ),
    ]
