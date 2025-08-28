from rest_framework import serializers
from models import User

class UserSerializer(serializers.ModelField):
    class meta:
        model = User
        fields = "__all__"
        