from django.urls import path
from . import views
app_name = "payments"

urlpatterns = [
    path("pay", views.pay_worker, name="pay_worker"),
    path("pay-all", views.pay_all_completed, name="pay_all_completed"),
   
]