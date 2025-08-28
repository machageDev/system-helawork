import requests
import base64
import datetime
from django.conf import settings
from django.http import JsonResponse

# =======================
# CONFIGS (put these in settings.py)
# =======================
# MPESA_ENV = 'sandbox'  # or 'production'
# MPESA_CONSUMER_KEY = 'your_consumer_key'
# MPESA_CONSUMER_SECRET = 'your_consumer_secret'
# MPESA_SHORTCODE = '174379'  # Lipa na Mpesa shortcode (Paybill/Till Number)
# MPESA_PASSKEY = 'your_passkey'
# MPESA_CALLBACK_URL = 'https://yourdomain.com/api/mpesa/callback/'

class MpesaClient:
    def __init__(self):
        self.consumer_key = settings.MPESA_CONSUMER_KEY
        self.consumer_secret = settings.MPESA_CONSUMER_SECRET
        self.shortcode = settings.MPESA_SHORTCODE
        self.passkey = settings.MPESA_PASSKEY
        self.callback_url = settings.MPESA_CALLBACK_URL

        if settings.MPESA_ENV == 'sandbox':
            self.base_url = 'https://sandbox.safaricom.co.ke'
        else:
            self.base_url = 'https://api.safaricom.co.ke'

    def get_access_token(self):
        url = f"{self.base_url}/oauth/v1/generate?grant_type=client_credentials"
        response = requests.get(url, auth=(self.consumer_key, self.consumer_secret))
        return response.json()['access_token']

    def lipa_na_mpesa_online(self, phone_number, amount, account_reference="TaskPayment", transaction_desc="Payment for task"):
        """
        Trigger STK Push (Lipa na Mpesa).
        phone_number must be in format 2547XXXXXXXX
        """
        access_token = self.get_access_token()
        api_url = f"{self.base_url}/mpesa/stkpush/v1/processrequest"
        timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')

        password = base64.b64encode(
            (self.shortcode + self.passkey + timestamp).encode('utf-8')
        ).decode('utf-8')

        headers = {"Authorization": f"Bearer {access_token}"}
        payload = {
            "BusinessShortCode": self.shortcode,
            "Password": password,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": amount,
            "PartyA": phone_number,  # customer phone
            "PartyB": self.shortcode,
            "PhoneNumber": phone_number,
            "CallBackURL": self.callback_url,
            "AccountReference": account_reference,
            "TransactionDesc": transaction_desc,
        }

        response = requests.post(api_url, json=payload, headers=headers)
        return response.json()

# =======================
# Django Views for Callback
# =======================
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def mpesa_callback(request):
    """
    Callback handler from Safaricom for STK Push.
    This will update Payment table when payment is successful.
    """
    data = json.loads(request.body.decode('utf-8'))
    print("M-PESA Callback Data:", data)  # Debugging

    try:
        result_code = data['Body']['stkCallback']['ResultCode']
        result_desc = data['Body']['stkCallback']['ResultDesc']
        checkout_request_id = data['Body']['stkCallback']['CheckoutRequestID']

        if result_code == 0:
            # Payment successful
            amount = data['Body']['stkCallback']['CallbackMetadata']['Item'][0]['Value']
            mpesa_code = data['Body']['stkCallback']['CallbackMetadata']['Item'][1]['Value']
            phone = data['Body']['stkCallback']['CallbackMetadata']['Item'][4]['Value']

            # Here, update your Payment model
            from .models import Payment, User
            user = User.objects.filter(phoneNo=phone).first()
            if user:
                Payment.objects.create(
                    user=user,
                    employer=None,  # you can assign if known
                    task=None,      # you can assign if known
                    amount=amount,
                    is_paid=True
                )

        return JsonResponse({"ResultDesc": result_desc, "ResultCode": result_code})

    except Exception as e:
        print("Error processing callback:", str(e))
        return JsonResponse({"error": str(e)})
