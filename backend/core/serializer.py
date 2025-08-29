from rest_framework import serializers
from models import User
from .models import Employer
from .models import Task
from .models import WorkLog
from .models import ProofOfWork, Payment, PaymentRate, TransactionLog

class UserSerializer(serializers.ModelField):
    class meta:
        model = User
        fields = "__all__"



class EmployerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employer
        fields = '__all__'

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'        

class WorkLOgSerializer(serializers.ModelSerializer):
    hours_worked = serializers.ReadOnlyField()
    class meta:
        model = WorkLog 
        fiels = '__all__'        



class ProofOfWorkSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProofOfWork
        fields = '__all__'


class PaymentSerializer(serializers.ModelSerializer):
    amount = serializers.ReadOnlyField()  # amount can be calculated automatically

    class Meta:
        model = Payment
        fields = '__all__'


class PaymentRateSerializer(serializers.ModelSerializer):
    class Meta:
        model = PaymentRate
        fields = '__all__'


class TransactionLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = TransactionLog
        fields = '__all__'
        
class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name', 'email', 'hourly_rate']        