

# Register your models here.
from django.contrib import admin
from .models import (
    User, UserToken, Employer, Task, WorkLog, ProofOfWork,
    Payment, PaymentRate, TransactionLog, UserProfile
)

# Simple registration
admin.site.register(User)
admin.site.register(UserToken)
admin.site.register(Employer)
admin.site.register(Task)
admin.site.register(WorkLog)
admin.site.register(ProofOfWork)
admin.site.register(Payment)
admin.site.register(PaymentRate)
admin.site.register(TransactionLog)
admin.site.register(UserProfile)
