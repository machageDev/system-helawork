from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='home'), 
    path('apilogin ',views.apilogin, name = 'apilogin'),
    path('apiregister',views.apiregister,name='apiregister'),
    path('apiforgot_password',views.apiforgot_password, mame = 'apiforgotpassword')
    
]
