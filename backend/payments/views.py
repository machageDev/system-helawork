from django.conf import settings
from django.shortcuts import redirect
from django.contrib import messages
from django.http import JsonResponse

import requests
from requests.auth import HTTPBasicAuth

from core.models import TaskCompletion


# 1. Generate access token
def generate_mpesa_token():
    url = f"{settings.DARAJA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials"
    response = requests.get(
        url,
        auth=HTTPBasicAuth(settings.DARAJA_CONSUMER_KEY, settings.DARAJA_CONSUMER_SECRET)
    )
    response.raise_for_status()
    return response.json()["access_token"]


# 2. Send B2C payment
def send_b2c_payment(phone_number, amount):
    access_token = generate_mpesa_token()
    url = f"{settings.DARAJA_BASE_URL}/mpesa/b2c/v1/paymentrequest"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    payload = {
        "InitiatorName": settings.DARAJA_INITIATOR_NAME,       # put in settings.py
        "SecurityCredential": settings.DARAJA_SECURITY_CREDENTIAL, # encrypted password
        "CommandID": "BusinessPayment",
        "Amount": amount,
        "PartyA": settings.DARAJA_SHORTCODE,   # e.g. "600000" in sandbox
        "PartyB": phone_number,
        "Remarks": "Task reward",
        "QueueTimeOutURL": "https://yourdomain.com/api/b2c/timeout",
        "ResultURL": "https://yourdomain.com/api/b2c/result",
        "Occasion": "Task Payment"
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()


# 3. Pay a single worker (manual)
def pay_worker(request):
    phone_number = "2547XXXXXXXX"   # should come from Worker model
    amount = 1000                   # should be calculated
    response = send_b2c_payment(phone_number, amount)

    if response.get("ResponseCode") == "0":
        messages.success(request, "Payment sent successfully. Check your phone.")
    else:
        messages.error(request, f"Payment failed: {response.get('errorMessage')}")

    return redirect("employer_dashboard")


# 4. Pay all workers who completed tasks
def pay_all_completed(request):
    completed_tasks = TaskCompletion.objects.filter(paid=False)
    results = []

    for task in completed_tasks:
        response = send_b2c_payment(task.user.phone, task.amount)
        if response.get("ResponseCode") == "0":
            task.paid = True
            task.save()

        results.append({
            "user": task.user.username,
            "phone": task.user.phone,
            "amount": task.amount,
            "response": response
        })

    return JsonResponse({"payments": results})
