from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='home'), 
    path('apilogin ',views.apilogin, name = 'apilogin'),
    path('apiregister',views.apiregister,name='apiregister'),
    path('apiforgot_password',views.apiforgot_password, mame = 'apiforgotpassword'),
    path('apicreate_profile',views.apicreate_user_profile,name='apicreaateprofile'),
    path('worklogs/', views.worklog_list, name='worklog-list'),
    path('worklogs/<int:pk>/', views.worklog_detail, name='worklog-detail'),
    path('proofs', views.proof_list, name='proof-list'),
    path('proofs', views.proof_detail, name='proof-detail'),
    
]
