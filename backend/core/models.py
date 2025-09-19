from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType


class User(models.Model):
    user_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100, default="Anonymous")
    email = models.EmailField(unique=True)
    phoneNo = models.CharField(max_length=13, unique=True)
    password = models.CharField(max_length=128, null=True, blank=True)

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)

    def __str__(self):
        return self.name


# Employer (for clients)
class Employer(models.Model):
    employer_id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=255)
    password = models.CharField(max_length=128, null=True, blank=True)
    contact_email = models.EmailField(unique=True)
    company_name = models.CharField(max_length=255, blank=True, null=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.username



class Task(models.Model):
    task_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=255)
    description = models.TextField()
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="tasks")
    assigned_user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="assigned_tasks", null=True, blank=True)

    def __str__(self):
        return self.title


# Task completion / payout
class TaskCompletion(models.Model):
    completion_id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    completed_at = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.name} - {self.task.title} - {'Paid' if self.paid else 'Unpaid'}"



class PayrollReport(models.Model):
    report_id = models.AutoField(primary_key=True)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="payroll_reports")
    month = models.DateField()
    total_expense = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payroll Report {self.month} by {self.employer.username}"



class EmployerRating(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    freelancer = models.ForeignKey(User, on_delete=models.CASCADE)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE)
    score = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    review = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)


class FreelancerRating(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    freelancer = models.ForeignKey(User, on_delete=models.CASCADE)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE)
    score = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    review = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)


class UserProfile(models.Model):
    profile_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="worker_profile")
    bio = models.TextField(blank=True, null=True)
    skills = models.CharField(max_length=255, help_text="Comma-separated list of skills")
    experience = models.TextField(blank=True, null=True)
    portfolio_link = models.URLField(blank=True, null=True)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    profile_picture = models.ImageField(upload_to="profile_pics/", null=True, blank=True)

    def average_rating(self):
        ratings = self.user.received_ratings.all()
        if ratings.exists():
            return sum(r.score for r in ratings) / ratings.count()
        return 0

    def __str__(self):
        return f"Profile of {self.user.name}"



class Proposal(models.Model):
    proposal_id = models.AutoField(primary_key=True)
    task = models.ForeignKey(Task, related_name="proposals", on_delete=models.CASCADE)
    freelancer = models.ForeignKey(User, related_name="proposals", on_delete=models.CASCADE)
    cover_letter = models.TextField()
    bid_amount = models.DecimalField(max_digits=10, decimal_places=2)
    submitted_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.freelancer.name} -> {self.task.title}"


# Contract (when freelancer is hired)
class Contract(models.Model):
    contract_id = models.AutoField(primary_key=True)
    task = models.OneToOneField(Task, related_name="contract", on_delete=models.CASCADE)
    freelancer = models.ForeignKey(User, on_delete=models.CASCADE)
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE)
    start_date = models.DateField(default=timezone.now)
    end_date = models.DateField(blank=True, null=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"Contract for {self.task.title}"
