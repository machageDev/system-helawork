"""
ASGI config for helawork project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'helawork.settings')

application = get_asgi_application()
LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'core:employer_dashboard'   
LOGOUT_REDIRECT_URL = 'login'
