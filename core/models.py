from django.db import models
from django.utils import timezone
from decimal import Decimal


class User(models.Model):
    user_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100,default="Anonymous")
    email = models.EmailField(unique=True)
    phoneNo = models.CharField(max_length=13, unique=True)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0.00) 

    def __str__(self):
        return self.name


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
