# Generated by Django 5.1.2 on 2024-12-27 11:48

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('health_locker', '0009_alter_datarequests_status'),
    ]

    operations = [
        migrations.AlterField(
            model_name='datarequests',
            name='end_date',
            field=models.TextField(),
        ),
        migrations.AlterField(
            model_name='datarequests',
            name='status',
            field=models.TextField(default='pending', null=True),
        ),
    ]
