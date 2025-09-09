import secrets
import uuid
from django.conf import settings
from django.db import models
from django.dispatch import receiver
from django.utils import timezone
from decimal import Decimal
from django.contrib.auth.hashers import make_password, check_password
from django.db.models.signals import post_save

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
    key = models.CharField(max_length=40, unique=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.key:
            self.key = secrets.token_hex(20)
        super().save(*args, **kwargs)



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
    user = models.ForeignKey(User, on_delete=models.CASCADE, verbose_name="User")
    amount = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="Amount")
    date = models.DateTimeField(default=timezone.now, verbose_name="Payment Date")
    status = models.CharField(
        max_length=20,
        choices=[("Paid", "Paid"), ("Pending", "Pending")],
        default="Paid",
        verbose_name="Payment Status"
    )
    
    
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
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")
    bio = models.TextField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)

    def __str__(self):
        return f"{self.user.name}'s Profile"



@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()


class PayrollReport(models.Model):
    employer = models.ForeignKey(User, on_delete=models.CASCADE, related_name="payroll_reports")
    month = models.DateField()  #
    total_expense = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payroll Report {self.month} by {self.employer.username}"    
    
class Worker(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    position = models.CharField(max_length=100)
    date_hired = models.DateField(auto_now_add=True)

    def __str__(self):
        return self.user.name  