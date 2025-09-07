from rest_framework import serializers
from .models import User, UserProfile
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

class WorkLogSerializer(serializers.ModelSerializer):
    hours_worked = serializers.ReadOnlyField()
    class meta:
        model = WorkLog 
        fiels = '__all__'        



class ProofOfWorkSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProofOfWork
        fields = '__all__'




class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'task_name', 'amount', 'date', 'status']

    def create(self, validated_data):
        payment = Payment.objects.create(**validated_data)
        payment.calculate_amount()
        payment.save()
        return payment


class PaymentRateSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source="user.name", read_only=True)
    employer_name = serializers.CharField(source="employer.name", read_only=True)

    class Meta:
        model = PaymentRate
        fields = [
            "id",
            "user",
            "user_name",
            "employer",
            "employer_name",
            "rate_per_hour",
            "effective_from",
            "effective_to",
        ]



class TransactionLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = TransactionLog
        fields = '__all__'
        
class RegisterSerializer(serializers.ModelSerializer):
    
    phone_number = serializers.CharField(source='phoneNo', required=True)

    class Meta:
        model = User
        fields = ['name', 'email', 'password', 'phone_number']  
        extra_kwargs = {
            "password": {"write_only": True},  
        }


    def to_internal_value(self, data):
        # Accept both phone_number and phoneNo in the request
        if "phoneNo" in data and "phone_number" not in data:
            data["phone_number"] = data["phoneNo"]
        return super().to_internal_value(data)

        
class LoginSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name','password']  


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'bio',  'profile_picture']         
class WorkLogSerializer(serializers.ModelSerializer):
    hours_worked = serializers.ReadOnlyField()

    class Meta:
        model = WorkLog
        fields = ['id', 'task', 'user', 'start_time', 'end_time', 'hours_worked']        