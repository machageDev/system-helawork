from datetime import date
import random
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from django.contrib.auth.tokens import default_token_generator
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import IntegrityError, transaction
from rest_framework import status
from core.serializer import FreelancerRatingSerializer, LoginSerializer, PaymentSerializer,   RegisterSerializer, TaskSerializer, UserProfileSerializer
from django.core.mail import send_mail
from django.contrib import messages
from payments.models import Payment
from .models import Employer, EmployerRating, FreelancerRating, Task, UserProfile
from django.contrib.auth.hashers import check_password
from .models import  User
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import render
from django.db.models import Sum
from django.contrib import messages
from django.contrib.auth.hashers import make_password
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str



def send_otp(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        user = User.objects.filter(email=email).first()

        if user:
            otp = random.randint(100000, 999999)  
            request.session['otp'] = otp  
            request.session['email'] = email  

            
            send_mail(
                'Password Reset OTP',
                f'Your OTP is {otp}. Use it to reset your password.',
                settings.DEFAULT_FROM_EMAIL,
                [email],
                fail_silently=False,
            )

            messages.success(request, 'OTP sent to your email.')
            return redirect('verify_otp')

        else:
            messages.error(request, 'Email not found.')
            return redirect('forgot_password')

    return render(request, 'forgot_password.html')



def otp(request):
    if request.method == 'POST':
        entered_otp = request.POST.get('otp')
        stored_otp = request.session.get('otp')

        if stored_otp and str(entered_otp) == str(stored_otp):
            return redirect('reset_password')  # Redirect to password reset page
        else:
            messages.error(request, 'Invalid OTP. Please try again.')

    return render(request, 'otp.html')
@api_view(['POST'])
@permission_classes([AllowAny])

def apiuserprofile(request):
    serializer = UserProfileSerializer(data=request.data)
    if serializer.is_valid():
        bio = serializer.validated_data['bio'].strip() if serializer.validated_data.get('bio') else ""
        skills = serializer.validated_data.get('skills', "")
        experience = serializer.validated_data.get('experience', "")
        portfolio_link = serializer.validated_data.get('portfolio_link', "").strip()
        hourly_rate = serializer.validated_data.get('hourly_rate')
        profile_picture = serializer.validated_data.get('profile_picture')      
    
        
    profile = UserProfile.objects.create(
        user = request.user,
        bio = bio,
        skills = skills,
        experience = experience,
        portfolio_link = portfolio_link,
        hourly_rate = hourly_rate,
        profile_picture = profile_picture,       
        
    )
    return Response(UserProfileSerializer(profile).data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([AllowAny])
def apiregister(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        name = serializer.validated_data['name'].strip()
        email = serializer.validated_data['email'].strip().lower()
        password = serializer.validated_data['password']
        phone_no = serializer.validated_data['phoneNo'].strip()   

        if User.objects.filter(email=email).exists():
            return Response(
                {"error": "User with this email already exists"},
                status=status.HTTP_400_BAD_REQUEST
            )
        if User.objects.filter(name=name).exists():
            return Response(
                {"error": "Username already exists"},
                status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            user = User(
                name=name,
                email=email,
                phoneNo=phone_no,   
            )
            user.set_password(password)
            user.save()

        return Response(
            {"message": "User registered successfully."},
            status=status.HTTP_201_CREATED
        )

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "POST"])
@permission_classes([IsAuthenticated])
def freelancer_rating_list_create(request):
    if request.method == "GET":
        """List all freelancer ratings"""
        ratings = FreelancerRating.objects.all()
        serializer = FreelancerRatingSerializer(ratings, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    elif request.method == "POST":
        """Create a new freelancer rating"""
        serializer = FreelancerRatingSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET", "DELETE"])
@permission_classes([IsAuthenticated])
def freelancer_rating_detail(request, pk):
    rating = get_object_or_404(FreelancerRating, pk=pk)

    if request.method == "GET":
        """Retrieve a specific freelancer rating"""
        serializer = FreelancerRatingSerializer(rating)
        return Response(serializer.data, status=status.HTTP_200_OK)

    elif request.method == "DELETE":
        """Delete a freelancer rating"""
        rating.delete()
        return Response({"message": "Rating deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
       
@api_view(['POST'])
@permission_classes([AllowAny])        
def apilogin(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        name = serializer.validated_data['name'].strip()
        password = serializer.validated_data['password']

        try:
            user = User.objects.get(name=name)

            
            if check_password(password, user.password):
                return Response(
                    {
                        "message": "Login successful",
                        "user_id": user.user_id,
                        "name": user.name
                    },
                    status=status.HTTP_200_OK
                )
            else:
                
                return Response({"error": "invalid login"}, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
        
            return Response({"error": "invalid login"}, status=status.HTTP_400_BAD_REQUEST)

    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



@api_view(['POST'])
@permission_classes([AllowAny])
def apiforgot_password(request):
    try:
        email = request.data.get('email')
        if not email:
            return Response({"error": "Please fill all fields"}, status=status.HTTP_400_BAD_REQUEST)
        if not User.objects.filter(email=email).exists():
            return Response({"error": "User does not exist"}, status=status.HTTP_400_BAD_REQUEST)
        user = User.objects.get(email=email)
         
        token = default_token_generator.make_token(user)
        reset_url = request.build_absolute_uri(reverse('password-reset-confirm', kwargs={'token': token, 'uidb64': user.pk}))

         
        send_mail(
            subject="Password Reset Request",
            message=f"Click the link below to reset your password:\n{reset_url}",
            from_email="no-reply@yourdomain.com",
            recipient_list=[email],
            fail_silently=False,
        )
        return Response({"message": "Password reset successfully"}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)        
    


@api_view(['GET'])
@permission_classes([AllowAny])
def list_tasks(request):
    tasks = Task.objects.all()
    serializer = TaskSerializer(tasks, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_task(request, pk):
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response({'error': 'Task not found'}, status=status.HTTP_404_NOT_FOUND)

    serializer = TaskSerializer(task)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def list_payments(request):
    payments = Payment.objects.all()
    serializer = PaymentSerializer(payments, many=True)
    return Response(serializer.data)



@api_view(['POST'])
@permission_classes([AllowAny])
def create_payment(request):
    serializer = PaymentSerializer(data=request.data)
    if serializer.is_valid():
        payment = serializer.save()
        return Response(PaymentSerializer(payment).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recent_payments(request):
    recent = Payment.objects.filter(user=request.user).order_by('-date')[:3]
    serializer = PaymentSerializer(recent, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([AllowAny])
def update_payment(request):
    try:
        payment = Payment.objects.get()
    except Payment.DoesNotExist:
        return Response({"error": "Payment not found"}, status=status.HTTP_404_NOT_FOUND)

    serializer = PaymentSerializer(payment, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def apipayment_summary(request):
    try:
       
        payments = Payment.objects.filter(user=request.user)

       
        total_hours = sum(p.hours for p in payments) if payments.exists() else 0
        hourly_rate = request.user.profile.hourly_rate if hasattr(request.user, "profile") else 0
        total_payment = sum(p.amount for p in payments)

        
        breakdown = {
            "base_earnings": sum(p.amount for p in payments if p.type == "base"),
            "bonus": sum(p.amount for p in payments if p.type == "bonus"),
            "total": total_payment
        }

        
        recent_payments = payments.order_by("-date")[:3]
        recent_serializer = PaymentSerializer(recent_payments, many=True)

        
        data = {
            "total_hours": total_hours,
            "hourly_rate": hourly_rate,
            "total_payment": total_payment,
            "currency": "Ksh",
            "breakdown": breakdown,
            "recent": recent_serializer.data
        }

        return Response(data, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#  Withdraw via M-PESA (mock for now, replace with Daraja B2C logic later)
@api_view(['POST'])
@permission_classes([AllowAny])
def withdraw_mpesa(request, pk):
    try:
        payment = Payment.objects.get(pk=pk)
    except Payment.DoesNotExist:
        return Response({"error": "Payment not found"}, status=status.HTTP_404_NOT_FOUND)

    if payment.is_paid:
        return Response({"error": "Payment already processed"}, status=status.HTTP_400_BAD_REQUEST)

    # Here you would call Daraja API and update receipt
    payment.is_paid = True
    payment.mpesa_receipt = "MPESA12345"  # mock receipt
    payment.save()

    return Response({
        "message": "Withdraw request processed successfully",
        "payment": PaymentSerializer(payment).data
    }, status=status.HTTP_200_OK)




def employer_dashboard(request):
    #  Check if employer is logged in
    if not request.session.get('employer_id'):
        return redirect('login')

    total_employees = User.objects.count()
    active_projects = Task.objects.filter(is_approved=True).count()  
    pending_payments = Payment.objects.filter(status="Pending").aggregate(total=Sum("amount"))["total"] or 0

    active_tasks = Task.objects.filter(is_approved=False).count()
    completed_tasks = Task.objects.filter(is_approved=True).count()

    context = {
        "total_workers": total_employees,
        "active_projects": active_projects,
        "pending_payments": pending_payments,
        "active_tasks": active_tasks,
        "completed_tasks": completed_tasks,
        "employer_name": request.session.get("employer_name")  
    }

    return render(request, "dashboard.html", context)


def register(request):
    if request.method == "POST":
        username = request.POST.get("username")
        email = request.POST.get("email")
        company_name = request.POST.get("company_name")
        phone_number = request.POST.get("phone_number")
        password = request.POST.get("password")
        
        if Employer.objects.filter(email=email).exists():
                                    
           messages.error(request,"Email already Exist!")
           return redirect("register")        
        employer = Employer(
            username=username,
            email=email,
            company_name=company_name,
            phone_number=phone_number,
            password=make_password(password)          
        )
        employer.save()
        messages.success(request, "Registration successful. Please login.")
        return redirect("login")
    return render(request,'login.html')

def login_view(request):
    if request.session.get('employer_id'):
        return redirect(request.GET.get('next', 'employer_dashboard'))

    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')

        try:
            employer = Employer.objects.get(username=username, password=password)
            
            request.session['employer_id'] = employer.id
            request.session['employer_name'] = employer.username

            return redirect(request.GET.get('next', 'employer_dashboard'))

        except Employer.DoesNotExist:
            messages.error(request, "Invalid credentials")
            return render(request, 'login.html')

    return render(request, 'login.html')



def logout_view(request):
    request.session.flush()
    messages.success(request, "You have been successfully logged out.")
    return redirect("login")



def task_list(request):
    tasks = Task.objects.all().select_related("employer", "user")
    return render(request, "task.html", {"tasks": tasks})

def create_task(request):
    if request.method == "POST":
        title = request.POST.get("title")
        description = request.POST.get("description")
        user_id = request.POST.get("user")
        is_approved = True if request.POST.get("is_approved") else False

        user = None
        if user_id:
            user = User.objects.filter(user_id=user_id).first()

        employer = Employer.objects.get(pk=request.session["employer_id"])

        Task.objects.create(
            title=title,
            description=description,
            employer=employer,
            user=User.user if user else None,
            is_approved=is_approved,
        )
        return redirect("task_list")

    user = User.objects.select_related("user").all()
    return render(request, "create_task.html", {"users": user})


def worker_list(request):
    
    users = User.objects.all()
    return render(request, "worker.html", {"users": users})



def edit_worker(request, worker_id):
    worker = get_object_or_404(User, id=worker_id)

    if request.method == "POST":
        name = request.POST.get("name")
        phoneNo = request.POST.get("phoneNo")

        worker.user.name = name
        worker.user.phoneNo = phoneNo
        worker.user.save()

        messages.success(request, "Worker updated successfully.")
        return redirect("worker_list")

    return render(request, "edit_worker.html", {"worker": worker})



def delete_worker(request, worker_id):
    worker = get_object_or_404(User, id=worker_id)
    worker.delete()
    messages.success(request, "Worker deleted successfully.")
    return redirect("worker_list")


def create_worker(request):
    if request.method == "POST":
        name = request.POST.get("name")
        email = request.POST.get("email")
        phoneNo = request.POST.get("phoneNo")
        password = request.POST.get("password")

        try:
            with transaction.atomic():
                user = User.objects.create(
                    name=name,
                    email=email,
                    phoneNo=phoneNo,
                )
                user.set_password(password)  
                user.save()

                messages.success(request, f"User {name} created successfully!")
                return redirect("worker_list")

        except IntegrityError:
            messages.error(request, "A user with this email or phone number already exists.")

    return render(request, "create_worker.html")

def home(request):
    return render(request,'home.html')

def forgot_password(request):
    if request.method == "POST":
        email = request.POST.get("email")
        user = User.objects.filter(email=email).first()

        if user:
            token = default_token_generator.make_token(user)
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            reset_link = request.build_absolute_uri(f"/reset_password/{uid}/{token}/")

            
            send_mail(
                "HelaWork - Password Reset",
                f"Hi {user.username},\n\nClick the link below to reset your password:\n{reset_link}\n\nIf you didn’t request this, ignore this email.",
                settings.DEFAULT_FROM_EMAIL,
                [email],
                fail_silently=False,
            )
            messages.success(request, "A password reset link has been sent to your email.")
            return redirect("login")
        else:
            messages.error(request, "No account found with that email.")
    return render(request, "forgot_password.html")



def reset_password(request, uidb64, token):
    try:
        uid = force_str(urlsafe_base64_decode(uidb64))
        user = User.objects.get(pk=uid)
    except (TypeError, ValueError, OverflowError, User.DoesNotExist):
        user = None

    if user is not None and default_token_generator.check_token(user, token):
        if request.method == "POST":
            password = request.POST.get("password")
            confirm_password = request.POST.get("confirm_password")

            if password == confirm_password:
                user.set_password(password)
                user.save()
                messages.success(request, "Password reset successful! You can now log in.")
                return redirect("login")
            else:
                messages.error(request, "Passwords do not match.")
        return render(request, "resetpassword.html", {"uidb64": uidb64, "token": token})
    else:
        messages.error(request, "Invalid or expired password reset link.")
        return redirect("forgot_password")
    


def employer_rating_list(request):
    ratings = EmployerRating.objects.all()
    return render(request, "ratings/employer_rating_list.html", {"ratings": ratings})


def employer_rating_create(request, task_id):
    task = get_object_or_404(Task, id=task_id)
    freelancer = request.user  
    employer = task.employer

    if request.method == "POST":
        score = request.POST.get("score")
        review = request.POST.get("review", "")
        if score:
            EmployerRating.objects.create(
                task=task,
                freelancer=freelancer,
                employer=employer,
                score=int(score),
                review=review
            )
            return redirect("employer_rating_list")

    return render(request, "ratings/employer_rating_form.html", {"task": task})



def employer_rating_detail(request, rating_id):
    rating = get_object_or_404(EmployerRating, id=rating_id)
    return render(request, "ratings/employer_rating_detail.html", {"rating": rating})