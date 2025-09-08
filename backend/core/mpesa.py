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









def get_access_token():
    consumer_key = "XSgLM7QN5cadTlEHSgrjRGyiJadbzYnSVLA4Te3mhvjRGMln"
    consumer_secret = "YtIksAfmJmYW988gbx1nG0vNwRexsJ6DWUtAgG3iBGB3SvKzAk9fAGHsd3rbfAbv"
    api_url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"

    response = requests.get(api_url, auth=HTTPBasicAuth(consumer_key, consumer_secret))
    json_response = response.json()
    return json_response['access_token']




def stk_push(phone_number, amount):
    access_token = get_access_token()
    api_url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    headers = {"Authorization": "Bearer %s" % access_token}

    shortcode = "174379"  # Test Paybill
    passkey = "YOUR_PASSKEY"
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")

    password = base64.b64encode((shortcode + passkey + timestamp).encode()).decode("utf-8")

    payload = {
        "BusinessShortCode": shortcode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": phone_number,   
        "PartyB": shortcode,
        "PhoneNumber": phone_number,
        "CallBackURL": "https://yourdomain.com/api/mpesa/callback",
        "AccountReference": "HelaWork",
        "TransactionDesc": "Payment for services"
    }

    response = requests.post(api_url, json=payload, headers=headers)
    return response.json()
