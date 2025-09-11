from django.contrib import admin

# Register your models here.

from .models import Payment, PaymentCallback

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("worker", "amount", "status", "transaction_id", "created_at")
    list_filter = ("status", "created_at")
    search_fields = ("worker__name", "transaction_id")

@admin.register(PaymentCallback)
class PaymentCallbackAdmin(admin.ModelAdmin):
    list_display = ("payment", "received_at")
