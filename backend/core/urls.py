from django.urls import path
from . import views


urlpatterns = [
    #worker/ mobile app
    path('debug-auth-test/', views.debug_auth_test, name='debug-auth-test'),
    path('apilogin',views.apilogin, name = 'apilogin'),
    path('apiregister',views.apiregister,name='apiregister'),
    path('apiforgot_password',views.apiforgot_password, name = 'apiforgotpassword'),
    path('employer_ratings/', views.employer_ratings_list, name='employer_ratings-list'),
    path('employer_ratings', views.employer_rating_detail, name='employer_rating_detail'),
    path('my_employer_ratings/', views.my_employer_ratings, name='my_employer_ratings'),
    path('freelancer_ratings/', views.freelancer_ratings, name='freelancer_ratings'),
      
    path('apilistpayments',views.list_payments,name='list_payments'),
    path('apiupdatepayments',views.update_payment,name='update_payments'),
    path('apipaymentsummary',views.apipayment_summary,name='apipayment_summary'),
    path('task', views.apitask_list, name='tasklist'),
    #path('task/',views.apitask_detail, name='taskdetail'),
    path('apiproposal', views.apisubmit_proposal, name='submit-proposal'),
    path('apiuserprofile',views.apiuserprofile,name='apiuser_profile'),
    path('apiuserlogin', views.current_user,name="current_user"),
    
    #employer urls/ web site

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
    path("reset_password/<uidb64>/<token>", views.reset_password, name="reset_password"),
    path("tasks_rate/", views.create_employer_rating, name="create_employer_rating"),
    path("ratings/", views.employer_rating_list, name="employer_rating_list"),
    path("employer/<int:employer_id>/ratings/", views.employer_ratings_detail, name="employer_ratings_detail"),
    path("proposals", views.proposal, name="task_proposals"),
    path('profile',views.create_employer_profile,name='employer_profile'),
    path('profileview',views.employer_profile,name='profileview'),

    path("test-404/", views.test_404, name="test_404"),

]
