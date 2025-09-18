from django.db import models
from django.contrib.auth.hashers import make_password, check_password

from helawork import settings

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


class Employer(models.Model):    
    username = models.CharField(max_length=255)
    password = models.CharField(max_length=128, null=True, blank=True)
    contact_email = models.EmailField()
    phone_number = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.username


class Task(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField()
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="tasks")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="assigned_tasks", null=True, blank=True)

    def __str__(self):
        return self.title


class TaskCompletion(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    task_name = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    completed_at = models.DateTimeField(auto_now_add=True)
    paid = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.name} - {self.task_name} - {'Paid' if self.paid else 'Unpaid'}"


class PayrollReport(models.Model):
    employer = models.ForeignKey(Employer, on_delete=models.CASCADE, related_name="payroll_reports")
    month = models.DateField()
    total_expense = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payroll Report {self.month} by {self.employer.username}"


class Rating(models.Model):
    task = models.ForeignKey(Task, related_name="ratings", on_delete=models.CASCADE)
    rater = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="given_ratings", on_delete=models.CASCADE)
    rated_user = models.ForeignKey(settings.AUTH_USER_MODEL, related_name="received_ratings", on_delete=models.CASCADE)
    score = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    review = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('task', 'rater', 'rated_user')  
        
class WorkerProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="worker_profile")
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