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

class Task(models.Model):
    title= models.CharField(max_length=200)
    description = models.TextField()
    employer = models.ForeignKey(Employer,on_delete=models.CASCADE,releted_name="tasks")
    user = models.ForeignKey(User,on_delete=models.SET_NULL,null=True,blank=True,related_name="tasks")
    is_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return super().__str__()


class ProofOfWork(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name="proofs")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="proofs")
    description = models.TextField()
    submitted_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Proof for {self.task.title} by {self.worker.user.name}"         