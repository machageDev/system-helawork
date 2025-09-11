from django.db import models

# Create your models here.

from django.conf import settings
from core.models import Worker

class Payment(models.Model):
    STATUS_CHOICES = [
        ("Pending", "Pending"),
        ("Success", "Success"),
        ("Failed", "Failed"),
    ]

    worker = models.ForeignKey(Worker, on_delete=models.CASCADE, related_name="payments")
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    phone_number = models.CharField(max_length=15)   # e.g., 2547XXXXXXXX
    transaction_id = models.CharField(max_length=100, blank=True, null=True)  # M-Pesa receipt number
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="Pending")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.employee.name} - {self.amount} KES - {self.status}"


class PaymentCallback(models.Model):
    """Stores raw callback responses from Daraja for auditing"""
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name="callbacks")
    payload = models.JSONField()
    received_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Callback for {self.payment.id} at {self.received_at}"
