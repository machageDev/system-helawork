from django.urls import path
from . import views

urlpatterns = [
    path("pay_worker", views.pay_worker, name="pay_worker"),
]
