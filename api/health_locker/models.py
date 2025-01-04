from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

# Create your models here.

class UserManager(BaseUserManager):
    def create_user(self, email, password, **kwargs):
        if not email:
            raise ValueError("'email' field is required")
        if not password:
            raise ValueError("'password' field is required")

        email = self.normalize_email(email)
        user: UserCredentials = self.model(email = email, **kwargs)
        user.set_password(password)

        try:
            user.save(using = self._db)
        except:
            raise Exception("A user with that email already exists")

        return user
    
    def create_superuser(self, email, password, **kwargs):
        kwargs.setdefault("is_staff", True)
        kwargs.setdefault("is_superuser", True)
        return self.create_user(email, password, **kwargs)


class UserCredentials(AbstractBaseUser, PermissionsMixin):
    user_id = models.AutoField(primary_key = True, unique = True, null = False)
    email = models.EmailField(unique = True, null = False)
    role = models.TextField(choices = [("doctor", "doctor"), ("patient", "patient")], null = False)
    is_staff = models.BooleanField(default = False, null = False)

    USERNAME_FIELD = "email"

    objects = UserManager()


class HealthLocker(models.Model):
    record_id = models.AutoField(primary_key = True, unique = True, null = False)
    user = models.ForeignKey(UserCredentials, on_delete = models.CASCADE, null = False)
    type = models.TextField(unique = False, null = False)
    file_name = models.TextField(unique = False, null = False)
    data = models.JSONField(unique = False, null = False)


class DataRequests(models.Model):
    request_id = models.AutoField(primary_key = True, unique = True, null = False)
    requestor = models.ForeignKey(UserCredentials, related_name = "requestor", on_delete = models.CASCADE, null = False)
    donor = models.ForeignKey(UserCredentials, related_name = "donor", on_delete = models.CASCADE, null = False)
    type = models.JSONField(unique = False, null = False)
    end_date = models.TextField(unique = False, null = False)
    request_date = models.TextField(unique = False, null = False)
    status = models.TextField(default = "pending", unique = False, null = False)