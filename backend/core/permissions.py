from rest_framework import permissions

class IsAuthenticated(permissions.BasePermission):
    """
    Custom permission that works with your User model
    """
    def has_permission(self, request, view):
        return bool(request.user and getattr(request.user, 'is_authenticated', False))