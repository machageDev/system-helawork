from rest_framework import serializers ,viewsets, permissions

from payments.models import Payment
from .models import User, UserProfile
from .models import Employer
from .models import Task
from .models import Rating

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



class RatingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rating
        fields = '__all__'
        read_only_fields = ('rater',)

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'
        read_only_fields = ("user",)

    def get_average_rating(self, obj):
        return obj.average_rating()
    
class RatingViewSet(viewsets.ModelViewSet):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(rater=self.request.user)