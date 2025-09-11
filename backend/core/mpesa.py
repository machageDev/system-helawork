import requests
import base64
import datetime
from django.conf import settings
from django.http import JsonResponse
from requests.auth import HTTPBasicAuth


# =======================
# CONFIGS (put these in settings.py)
# =======================
# MPESA_ENV = 'sandbox'  # or 'production'
# MPESA_CONSUMER_KEY = 'your_consumer_key'
# MPESA_CONSUMER_SECRET = 'your_consumer_secret'
# MPESA_SHORTCODE = '174379'  # Lipa na Mpesa shortcode (Paybill/Till Number)
# MPESA_PASSKEY = 'your_passkey'
# MPESA_CALLBACK_URL = 'https://yourdomain.com/api/mpesa/callback/'


import requests
from requests.auth import HTTPBasicAuth
import datetime
import base64

def get_access_token():
    consumer_key = "XSgLM7QN5cadTlEHSgrjRGyiJadbzYnSVLA4Te3mhvjRGMln"
    consumer_secret = "YtIksAfmJmYW988gbx1nG0vNwRexsJ6DWUtAgG3iBGB3SvKzAk9fAGHsd3rbfAbv"
    api_url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"

    response = requests.get(api_url, auth=HTTPBasicAuth(consumer_key, consumer_secret))
    return response.json()['access_token']

import requests
from django.conf import settings

def stk_push(phone_number, amount):
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    headers = {"Authorization": f"Bearer {settings.MPESA_ACCESS_TOKEN}"}
    payload = {
        "BusinessShortCode": settings.BUSINESS_SHORT_CODE,
        "Password": settings.PASSWORD,
        "Timestamp": settings.TIMESTAMP,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phone_number,
        "PartyB": settings.BUSINESS_SHORT_CODE,
        "PhoneNumber": phone_number,
        "CallBackURL": settings.CALLBACK_URL,
        "AccountReference": "HelaWork",
        "TransactionDesc": "Payment for work",
    }
    response = requests.post(url, json=payload, headers=headers)

    try:
        return response.json()
    except ValueError:
        return {"error": "Invalid response from M-Pesa"}








