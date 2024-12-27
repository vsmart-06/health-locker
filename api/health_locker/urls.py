from django.urls import path
from health_locker.views import *

urlpatterns = [
    path("", index),
    path("convert-dicom/", convert_dicom),
    path("upload-file/", upload_file),
    path("fetch-data/", fetch_data),
    path("fetch-requests/", fetch_requests),
    path("delete-data/", delete_data),
    path("signup/", signup),
    path("login/", login),
]