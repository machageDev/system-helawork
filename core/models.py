from django.db import models

class User (models.Model):
    user_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    phoneNo = models.CharField(max_length=13, unique=True)
    
    def __str__(self):
        return super().__str__()
    


class Employer(models.Model):
    company_name = models.CharField(max_length=255)
    contact_email = models.EmailField()
    phone_number = models.CharField(max_length=20, blank=True, null=True)

    def __str__(self):
        return self.company_name
    