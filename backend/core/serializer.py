from rest_framework import serializers
from models import User
from .models import Employer

class UserSerializer(serializers.ModelField):
    class meta:
        model = User
        fields = "__all__"



class EmployerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employer
        fields = '__all__'
        