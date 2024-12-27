from django.http import HttpRequest, JsonResponse, HttpResponse
from django.contrib.auth import authenticate
from django.views.decorators.csrf import csrf_exempt
from pydicom import dcmread
import numpy as np
from PIL import Image
import io
import base64
from health_locker.models import *
import json

def dicom_to_png(image):
    png = (np.maximum(image, 0) / image.max()) * 255.0
    png = np.uint8(png)

    png = Image.fromarray(png)

    return png


def index(request: HttpRequest):
    return HttpResponse("API is up and running")

@csrf_exempt 
def convert_dicom(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    x = request.FILES.get("image")

    data = dcmread(x)

    image = data.pixel_array.astype(float)

    final = dicom_to_png(image)

    buffer = io.BytesIO()
    final.save(buffer, format = "PNG")
    img = base64.b64encode(buffer.getvalue()).decode()

    return JsonResponse({"image": img})

@csrf_exempt
def upload_file(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    file = request.FILES.get("file")
    file_type = request.POST.get("type")
    user_id = int(request.POST.get("user_id"))
    extension = request.POST.get("extension")

    file_data = {
        "file_name": file.name,
        "extension": extension,
        "file": base64.b64encode(file.read()).decode() if extension != "json" else json.loads(file.read()),
    }
    
    try:
        user = UserCredentials(user_id = user_id)
    except:
        return JsonResponse({"error": "A user with this user ID does not exist"}, status = 403)
    
    try:
        HealthLocker.objects.get(user = user, type = file_type, file_name = file.name)
        return JsonResponse({"error": "A file with that name already exists"}, status = 403)
    except:
        record = HealthLocker(type = file_type, user = user, file_name = file.name, data = file_data)
        record.save()
        return JsonResponse({"message": "File successfully added"})

@csrf_exempt
def fetch_data(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    file_type = request.POST.get("type")
    user_id = int(request.POST.get("user_id"))

    try:
        user = UserCredentials(user_id = user_id)
    except:
        return JsonResponse({"error": "A user with this user ID does not exist"}, status = 400)

    records = HealthLocker.objects.filter(user = user, type = file_type)

    records = list(records.values())

    return_data = {}

    for x in records:
        if x["data"]["extension"] == "dcm":
            file = x["data"]["file"]

            f = base64.b64decode(file)

            data = dcmread(io.BytesIO(f))

            image = data.pixel_array.astype(float)

            final = dicom_to_png(image)

            buffer = io.BytesIO()
            final.save(buffer, format = "PNG")
            img = base64.b64encode(buffer.getvalue()).decode()

            x["data"]["image"] = img

        return_data[x["file_name"]] = x

    return JsonResponse({"data": return_data})

@csrf_exempt
def delete_data(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)

    files = eval(request.POST.get("files"))
    user_id = int(request.POST.get("user_id"))
    file_type = request.POST.get("type")

    try:
        user = UserCredentials(user_id = user_id)
    except:
        return JsonResponse({"error": "A user with this user ID does not exist"}, status = 400)

    error = False
    for file in files:
        try:
            record = HealthLocker.objects.get(user = user, type = file_type, file_name = file)
            record.delete()
        except:
            error = True
    
    if not error:
        return JsonResponse({"message": "Selected files successfully deleted"})
    return JsonResponse({"error": "Some files could not be deleted"}, status = 520)

@csrf_exempt
def signup(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    email = request.POST.get("email")
    password = request.POST.get("password")
    role = request.POST.get("role")

    if not email:
        return JsonResponse({"error": "'email' field is required"}, status = 400)
    if not password:
        return JsonResponse({"error": "'password' field is required"}, status = 400)
    if not role:
        return JsonResponse({"error": "'role' field is required"}, status = 400)

    try:
        user = UserCredentials.objects.create_user(email = email, password = password, role = role)
        user.save()
    except Exception:
        return JsonResponse({"error": "A user with that email already exists"}, status = 409)

    return JsonResponse({"message": "User successfully signed up", "user_id": user.user_id, "role": user.role})

@csrf_exempt
def login(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    email = request.POST.get("email")
    password = request.POST.get("password")

    if not email:
        return JsonResponse({"error": "'email' field is required"}, status = 400)
    if not password:
        return JsonResponse({"error": "'password' field is required"}, status = 400)

    user = authenticate(request, email = email, password = password)

    if user:
        return JsonResponse({"message": "User successfully logged in", "user_id": user.user_id, "role": user.role})
    
    return JsonResponse({"error": "Email or password is incorrect"}, status = 401)

@csrf_exempt
def fetch_requests(request: HttpRequest):
    if request.method != "POST":
        return JsonResponse({"error": "This endpoint can only be accessed via POST"}, status = 400)
    
    user_id = int(request.POST.get("user_id"))
    second_id = request.POST.get("second_id")
    role = request.POST.get("role")

    try:
        user = UserCredentials(user_id = user_id)
    except:
        return JsonResponse({"error": "A user with this user ID does not exist"}, status = 400)
    
    if second_id:
        second_id = int(second_id)

        try:
            second = UserCredentials(user_id = second_id)
        except:
            return JsonResponse({"error": "A user with this second ID does not exist"}, status = 400)

    if role == "doctor":
        records = DataRequests.objects.filter(requestor = user)
        if second_id:
            records.filter(donor = second)

    else:
        records = DataRequests.objects.filter(donor = user)
        if second_id:
            records.filter(requestor = second)


    records = list(records.values())

    return JsonResponse({"data": records})
    