from django.urls import path
from . import views


urlpatterns = [
    
    path('apilogin',views.apilogin, name = 'apilogin'),
    path('apiregister',views.apiregister,name='apiregister'),
    path('apiforgot_password',views.apiforgot_password, name = 'apiforgotpassword'),
    path("ratings/freelancers", views.freelancer_rating_list_create, name="freelancer_ratings"),
    path("ratings/freelancers/<int:pk>/", views.freelancer_rating_detail, name="freelancer_rating_detail"),    
    path('apilistpayments',views.list_payments,name='list_payments'),
    path('apiupdatepayments',views.update_payment,name='update_payments'),
    path('apipaymentsummary',views.apipayment_summary,name='apipayment_summary'),
    
    
    
    #employer urls

    path('',views.home,name='home'),
    path('register',views.register,name='register'),
    path('dashboard',views.employer_dashboard,name='employer_dashboard'),
    path('login',views.login_view,name='login'),
    path('logout', views.logout_view, name='logout'),
    path("tasks/create", views.create_task, name="create_task"),      
    path("tasks", views.task_list, name="task_list"),
    path('worker_list', views.worker_list, name="worker_list"),
    path("edit_employees", views.edit_worker, name="edit_employee"),
    path("delete_employees", views.delete_worker, name="delete_employee"),
    path('create_worker',views.create_worker,name="create_worker"),
    path("forgot_password", views.forgot_password, name="forgot_password"),
    path("reset_password/<uidb64>/<token>/", views.reset_password, name="reset_password"),


    
]
