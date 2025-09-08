from django.shortcuts import render


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

