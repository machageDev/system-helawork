from rest_framework.permissions import BasePermission
from .models import UserToken

class IsCustomUserAuthenticated(BasePermission):
    def has_permission(self, request, view):
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return False

        try:
            prefix, key = auth_header.split()
            if prefix.lower() != "bearer":
                return False
        except:
            return False

        return UserToken.objects.filter(key=key).exists()
