from django.urls import path
from health_locker.views import *

urlpatterns = [
    path("", index),
    path("convert-dicom/", convert_dicom),
    path("upload-file/", upload_file),
    path("retrieve-data/", retrieve_data),
    path("delete-data/", delete_data),
    path("signup/", signup),
    path("login/", login),
]