from django.shortcuts import render
from django.http import JsonResponse
from .models import TaskCompletion
from django.shortcuts import redirect
from django.contrib import messages
from .utils import stk_push

def pay_worker(request):
    # Example: pay fixed amount to a worker
    phone_number = "2547XXXXXXXX"   # get from worker model
    amount = 1000  # calculate from tasks/payments

    response = stk_push(phone_number, amount)

    if response.get("ResponseCode") == "0":
        messages.success(request, "STK Push sent successfully. Check your phone.")
    else:
        messages.error(request, f"Payment failed: {response.get('errorMessage')}")

    return redirect("employer_dashboard")

import requests
from requests.auth import HTTPBasicAuth
import base64

# 1. Get access token
def get_access_token():
    consumer_key = "YOUR_CONSUMER_KEY"
    consumer_secret = "YOUR_CONSUMER_SECRET"
    api_url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"

    response = requests.get(api_url, auth=HTTPBasicAuth(consumer_key, consumer_secret))
    return response.json()['access_token']

# 2. Send B2C payment
def send_b2c_payment(phone_number, amount):
    access_token = get_access_token()
    url = "https://sandbox.safaricom.co.ke/mpesa/b2c/v1/paymentrequest"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    payload = {
        "InitiatorName": "testapi",                # Sandbox initiator
        "SecurityCredential": "SECURITY_CREDENTIAL", # Encrypt sandbox password
        "CommandID": "BusinessPayment",
        "Amount": amount,
        "PartyA": "600000",                        # Sandbox shortcode
        "PartyB": phone_number,
        "Remarks": "Task reward",
        "QueueTimeOutURL": "https://yourdomain.com/api/b2c/timeout",
        "ResultURL": "https://yourdomain.com/api/b2c/result",
        "Occasion": "Task Payment"
    }

    response = requests.post(url, json=payload, headers=headers)
    return response.json()

def pay_all_completed(request):
    # Fetch all users who completed the task and haven't been paid yet
    completed_tasks = TaskCompletion.objects.filter(paid=False)
    results = []

    for task in completed_tasks:
        response = send_b2c_payment(task.user.phone, task.amount)
        # Save response and mark as paid if successful
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