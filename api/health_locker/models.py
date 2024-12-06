from django.db import models

# Create your models here.
class UserCredentials(models.Model):
    user_id = models.AutoField(primary_key = True, unique = True, null = False)
    email = models.TextField(unique = False, null = True)


class HealthLocker(models.Model):
    record_id = models.AutoField(primary_key = True, unique = True, null = False)
    user = models.ForeignKey(UserCredentials, on_delete = models.CASCADE, null = False)
    type = models.TextField(unique = False, null = False)
    file_name = models.TextField(unique = False, null = False)
    data = models.JSONField(unique = False, null = False)