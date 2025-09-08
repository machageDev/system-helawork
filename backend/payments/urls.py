from django.urls import path
from . import views

urlpatterns = [
    path("pay-worker/", views.pay_worker, name="pay_worker"),
]
