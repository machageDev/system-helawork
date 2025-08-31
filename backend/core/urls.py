from django.urls import path
from . import views


urlpatterns = [
    
    path('apilogin ',views.apilogin, name = 'apilogin'),
    path('apiregister',views.apiregister,name='apiregister'),
    path('apiforgot_password',views.apiforgot_password, name = 'apiforgotpassword'),
    path('apicreate_profile',views.apicreate_user_profile,name='apicreaateprofile'),
    path('apiworklogs/', views.apiworklog_list, name='worklog-list'),
    path('worklogs/<int:pk>/', views.apiworklog_detail, name='worklog-detail'),
    path('proofs', views.apiproof_detail, name='proof-list'),
    path('proofs', views.apiproof_detail, name='proof-detail'),
    
]
