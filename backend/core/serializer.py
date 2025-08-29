from rest_framework import serializers
from models import User
from .models import Employer
from .models import Task
from .models import WorkLog

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
    class meta:
        fields = '__all__'        