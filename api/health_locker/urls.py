from django.urls import path
from health_locker.views import *

urlpatterns = [
    path("", index),
    path("convert-dicom/", convert_dicom),
    path("upload-file/", upload_file),
    path("fetch-data/", fetch_data),
    path("fetch-requests/", fetch_requests),
    path("add-request/", add_request),
    path("toggle-request/", toggle_request),
    path("withdraw-request/", withdraw_request),
    path("delete-data/", delete_data),
    path("signup/", signup),
    path("login/", login),
]