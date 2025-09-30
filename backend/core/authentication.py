from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from .models import UserToken

class CustomTokenAuthentication(BaseAuthentication):
    def authenticate(self, request):
    
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        
        print(f" RAW Auth header: {auth_header}")
        
        if not auth_header or not auth_header.startswith('Bearer '):
            print(" No Bearer token found")
            return None
            
        try:
            # Extract token
            token_key = auth_header.split(' ')[1].strip()
            print(f" Looking for token: '{token_key}'")
                
            # Find the token
            user_token = UserToken.objects.get(key=token_key)
            user = user_token.user
            
            print(f" SUCCESS: Authenticated {user.name} (ID: {user.user_id})")
            
            # Add required attributes for DRF
            user.is_authenticated = True
            user.is_anonymous = False
            
            return (user, user_token)
            
        except UserToken.DoesNotExist:
            print(f" Token not found: {token_key}")
            raise AuthenticationFailed('Invalid token')
        except Exception as e:
            print(f" Authentication error: {e}")
            raise AuthenticationFailed('Authentication failed')

    def authenticate_header(self, request):
        return 'Bearer'