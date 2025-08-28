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


# models.py
from django.db import models

class Task(models.Model):
    # Task Information
    title = models.CharField(max_length=200)
    description = models.TextField()
    
    # Assignment Details
    assigned_to = models.ForeignKey('User', on_delete=models.CASCADE, related_name='assigned_tasks')
    assigned_by = models.ForeignKey('User', on_delete=models.CASCADE, related_name='created_tasks')
    
    # Dates and Deadlines
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deadline = models.DateTimeField()
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Budget and Payment
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    
    # Status Tracking
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # Priority Level
    PRIORITY_CHOICES = (
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    )
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='medium')
    
    # Additional Fields
    estimated_hours = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    actual_hours = models.DecimalField(max_digits=5, decimal_places=2, default=0.00)
    notes = models.TextField(null=True, blank=True)
    is_urgent = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.title} - {self.assigned_to.username}"

    def save(self, *args, **kwargs):
        
        if self.hourly_rate and self.actual_hours:
            self.total_cost = self.hourly_rate * self.actual_hours
        elif self.budget and not self.total_cost:
            self.total_cost = self.budget
        super().save(*args, **kwargs)

    def get_status_display(self):
        return dict(self.STATUS_CHOICES).get(self.status, self.status)    