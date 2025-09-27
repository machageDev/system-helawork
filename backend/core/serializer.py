from rest_framework import serializers 

from payments.models import Payment
from .models import Contract, Proposal, User, UserProfile
from .models import Employer, User
from .models import Task
from .models import EmployerRating, FreelancerRating

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


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'task_name', 'amount', 'date', 'status']

    def create(self, validated_data):
        payment = Payment.objects.create(**validated_data)
        payment.calculate_amount()
        payment.save()
        return payment

        
class RegisterSerializer(serializers.ModelSerializer):
    
    phone_number = serializers.CharField(source='phoneNo', required=True)

    class Meta:
        model = User
        fields = ['name', 'email', 'phone_number','password', ]  
        extra_kwargs = {
            "password": {"write_only": True},  
        }


    def to_internal_value(self, data):
        
        if "phoneNo" in data and "phone_number" not in data:
            data["phone_number"] = data["phoneNo"]
        return super().to_internal_value(data)

        
class LoginSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name','password']  



class EmployerRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmployerRating
        fields = ['id', 'task', 'freelancer', 'employer', 'score', 'review', 'created_at']


class FreelancerRatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = FreelancerRating
        fields = ['id', 'task', 'freelancer', 'employer', 'score', 'review', 'created_at']

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'
        read_only_fields = ("user",)

    def get_average_rating(self, obj):
        return obj.average_rating()
    
class ProposalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Proposal
        fields = ['proposal_id', 'task', 'freelancer', 'cover_letter', 'bid_amount', 'submitted_at']
        read_only_fields = ['proposal_id', 'submitted_at']


class ContractSerializer(serializers.ModelSerializer):
    task_title = serializers.CharField(source="task.title", read_only=True)
    freelancer_name = serializers.CharField(source="freelancer.username", read_only=True)
    employer_name = serializers.CharField(source="employer.username", read_only=True)

    class Meta:
        model = Contract
        fields = [
            "contract_id",
            "task_title",
            "freelancer_name",
            "employer_name",
            "start_date",
            "end_date",
            "is_active",
        ]        