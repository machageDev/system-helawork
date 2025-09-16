

# Register your models here.
from django.contrib import admin
from .models import (
    PayrollReport, TaskCompletion, User,  Employer, Task, 
    
)

# Simple registration


admin.site.register(Employer)
admin.site.register(Task)
admin.site.register(User)
admin.site.register(TaskCompletion)
admin.site.register(PayrollReport)