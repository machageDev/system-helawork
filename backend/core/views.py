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
from core.serializer import LoginSerializer, PaymentSerializer, ProofOfWorkSerializer, RegisterSerializer, TaskSerializer, UserProfileSerializer, WorkLogSerializer
from django.core.mail import send_mail
from django.contrib import messages
from .models import Worker,  Task, Payment
from django.contrib.auth.hashers import check_password
from .models import Worker, Payment, ProofOfWork, User, WorkLog
from rest_framework import serializers, viewsets, permissions, status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import render
from django.db.models import Sum
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse




def send_otp(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        user = User.objects.filter(email=email).first()

        if user:
            otp = random.randint(100000, 999999)  # Generate 6-digit OTP
            request.session['otp'] = otp  # Store OTP in session
            request.session['email'] = email  # Store email in session

            # Send OTP via email
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
    
@api_view(['POST'])
@permission_classes([AllowAny])
def apicreate_user_profile(request):
    serializer = UserProfileSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)  





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



@api_view(['GET', 'POST'])
def apiworklog_list(request):
    if request.method == 'GET':
        worklogs = WorkLog.objects.all()
        serializer = WorkLogSerializer(worklogs, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = WorkLogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
def apiworklog_detail(request):
    try:
        worklog = WorkLog.objects.get()
    except WorkLog.DoesNotExist:
        return Response({"error": "WorkLog not found"}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = WorkLogSerializer(worklog)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = WorkLogSerializer(worklog, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        worklog.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    
    
def apiproofwork(request):
    if request.method == 'GET':
        proofs = ProofOfWork.objects.all()
        serializer = ProofOfWorkSerializer(proofs, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = ProofOfWorkSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
def apiproof_detail(request):
    try:
        proof = ProofOfWork.objects.get()
    except ProofOfWork.DoesNotExist:
        return Response({"error": "ProofOfWork not found"}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = ProofOfWorkSerializer(proof)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = ProofOfWorkSerializer(proof, data=request.data, partial=True)  
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        proof.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)    


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
        #  Query all payments for logged-in user
        payments = Payment.objects.filter(user=request.user)

        # Total hours & rates (assuming stored in Payment model or user profile)
        total_hours = sum(p.hours for p in payments) if payments.exists() else 0
        hourly_rate = request.user.profile.hourly_rate if hasattr(request.user, "profile") else 0
        total_payment = sum(p.amount for p in payments)

        
        breakdown = {
            "base_earnings": sum(p.amount for p in payments if p.type == "base"),
            "bonus": sum(p.amount for p in payments if p.type == "bonus"),
            "total": total_payment
        }

        # Last 3 recent payments
        recent_payments = payments.order_by("-date")[:3]
        recent_serializer = PaymentSerializer(recent_payments, many=True)

        #  Response payload
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
 
 

@login_required
def employer_dashboard(request):
    total_employees = Worker.objects.count()
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
    }
    return render(request, "dashboard.html", context)


def login_view(request):
    
    if request.employer.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        
        employer = authenticate(request, username=username, password=password)
        
        if employer is not None:
            # Login successful
            login(request, employer)
            messages.success(request, f'Welcome back, {username}!')
            return redirect('dashboard')
        else:
            # Login failed
            messages.error(request, 'Invalid username or password. Please try again.')
            return render(request, 'login.html', {'username': username})
    
    
    return render(request, 'login.html')

@login_required
def logout_view(request):
    """
    Handle user logout
    """
    logout(request)
    messages.success(request, 'You have been successfully logged out.')
    return redirect('login')

@login_required
def task_list(request):
    tasks = Task.objects.all().select_related("employer", "user")
    return render(request, "task.html", {"tasks": tasks})    
@login_required
def create_task(request):
    if request.method == "POST":
        title = request.POST.get("title")
        description = request.POST.get("description")
        user_id = request.POST.get("user")  
        is_approved = True if request.POST.get("is_approved") else False

        worker = None
        if user_id:
            try:
                worker = Worker.objects.get(user_id=user_id)
            except Worker.DoesNotExist:
                worker = None

        Task.objects.create(
            title=title,
            description=description,
            employer=User.objects.get(pk=request.user.pk),  
            user=worker.user if worker else None,          
            is_approved=is_approved,
        )
        return redirect("task_list")

    return render(request, "create_task.html")



def worker_list(request):
    workers = Worker.objects.select_related("user").all()
    return render(request, "worker.html", {"workers": workers})
def edit_worker(request, employee_id):
    worker = get_object_or_404(Worker, id=worker_list)

    if request.method == "POST":
        position = request.POST.get("position")
        Worker.position = position
        Worker.save()
        return redirect("worker_list")

    return render(request, "edit_worker.html", {"worker": Worker})

def delete_worker(request):
    worker = get_object_or_404()
    worker.delete()
    return redirect("worker_list")

def create_worker(request):
    if request.method == "POST":
        name = request.POST.get("name")
        email = request.POST.get("email")
        phoneNo = request.POST.get("phoneNo")
        password = request.POST.get("password")
        
        try:
            # Use a transaction to ensure both user and worker are created successfully
            with transaction.atomic():
                
                user = User.objects.create(
                    email=email,
                    password=password,
                    name=name,
                    phoneNo=phoneNo
                )
                
                
                Worker.objects.create(user=user)

                messages.success(request, f"Worker {name} created successfully!")
                return redirect("worker_list")

        except IntegrityError:
            
            messages.error(request, "A user with this email or phone number already exists.")
            return render(request, "create_worker.html")

    return render(request, "create_worker.html")