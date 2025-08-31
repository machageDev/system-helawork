import uuid
from django.db import models
from django.utils import timezone
from decimal import Decimal
from django.contrib.auth.hashers import make_password, check_password

class User(models.Model):
    user_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100,default="Anonymous")
    email = models.EmailField(unique=True)
    phoneNo = models.CharField(max_length=13, unique=True)
    password = models.CharField(max_length=128,null=True,blank=True) 
    
    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)

    def __str__(self):
        return self.name
    
class UserToken(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="token")
    key = models.CharField(max_length=255, unique=True, default=uuid.uuid4)

    def __str__(self):
        return f"Token for {self.user.name}"

class Employer(models.Model):
    company_name = models.CharField(max_length=255)
    contact_email = models.EmailField()
    phone_number = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.company_name


class Task(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField()
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="tasks")
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="tasks")
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


class WorkLog(models.Model):
    
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="worklogs")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="worklogs")
    start_time = models.DateTimeField(default=timezone.now)
    end_time = models.DateTimeField(null=True, blank=True)

    def hours_worked(self):
        if self.end_time:
            duration = self.end_time - self.start_time
            return round(duration.total_seconds() / 3600, 2)  # hours
        return 0

    def __str__(self):
        return f"{self.user.name} worked on {self.task.title}"


class ProofOfWork(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="proofs")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="proofs")
    description = models.TextField()
    file_upload = models.FileField(upload_to="proofs/", blank=True, null=True)  # optional file
    submitted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Proof for {self.task.title} by {self.user.name}"


class Payment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="payments")
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="payments")
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="payments")
    total_hours = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    created_at = models.DateTimeField(auto_now_add=True)
    is_paid = models.BooleanField(default=False)
    mpesa_receipt = models.CharField(max_length=100, blank=True, null=True)

    def calculate_amount(self):
        
        rate = self.user.hourly_rate
        self.amount = Decimal(self.total_hours) * Decimal(rate)
        return self.amount

    def __str__(self):
        return f"Payment {self.amount} for {self.task.title} ({self.user.name})"
    
    
class PaymentRate(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="rates")
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="rates")
    rate_per_hour = models.DecimalField(max_digits=10, decimal_places=2)
    effective_from = models.DateTimeField()
    effective_to = models.DateTimeField(null=True, blank=True)

class TransactionLog(models.Model):
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name="transactions")
    mpesa_receipt = models.CharField(max_length=100, unique=True)
    phone_number = models.CharField(max_length=20)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=50)  
    created_at = models.DateTimeField(auto_now_add=True)


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    bio = models.TextField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)

    def __str__(self):
        return f"{self.user.name}'s Profile"
    