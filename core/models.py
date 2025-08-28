from django.db import models

# Create your models here.
# models.py
from django.db import models

class User(models.Model):
    
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    
    
    phone_number = models.CharField(max_length=13, unique=True)
    mpesa_number = models.CharField(max_length=13, null=True, blank=True)
    
    
    
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    national_id = models.CharField(max_length=20, unique=True, null=True, blank=True)
    physical_address = models.TextField(null=True, blank=True)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    
    # Status Fields
    verification_status = models.CharField(max_length=10)  # pending, approved, rejected
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.username} - {self.user_type}"