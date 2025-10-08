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
from core.authentication import CustomTokenAuthentication
from core.serializer import ContractSerializer, FreelancerRatingSerializer, LoginSerializer, PaymentSerializer, ProposalSerializer,   RegisterSerializer, TaskSerializer, UserProfileSerializer, UserSerializer,EmployerRatingSerializer
from django.core.mail import send_mail
from django.contrib import messages
from payments.models import Payment
from .models import Contract, Employer, EmployerProfile, EmployerRating, FreelancerRating, Proposal, Task, UserProfile
from django.contrib.auth.hashers import check_password
from .models import  User
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import render
from django.db.models import Sum
from django.contrib import messages
from django.contrib.auth.hashers import make_password
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import authentication_classes, permission_classes, api_view
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

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
@api_view(['GET'])
def current_user(request):
    serializer = UserSerializer(request.user)
    return Response(serializer.data)

from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import authentication_classes, permission_classes, api_view
from rest_framework.response import Response
from rest_framework import status
from .authentication import CustomTokenAuthentication
from .permissions import IsAuthenticated  
from .models import UserProfile
@csrf_exempt
@api_view(['POST', 'PUT'])
@authentication_classes([CustomTokenAuthentication])
@permission_classes([IsAuthenticated])
def apiuserprofile(request):
    print(f"=== PROFILE API CALLED ===")
    print(f"AUTH SUCCESS: {request.user.name} (ID: {request.user.user_id})")
    print(f"Method: {request.method}")
    
    if request.method == 'POST':
        print("POST - Creating new profile...")
        serializer = UserProfileSerializer(data=request.data)
        if serializer.is_valid():
            profile = serializer.save(user=request.user)  
            return Response(UserProfileSerializer(profile).data, status=status.HTTP_201_CREATED)
        print("POST errors:", serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'PUT':
        print("PUT data:", request.data)
        print("FILES:", request.FILES)
        
        try:
            # Try to get existing profile
            profile = UserProfile.objects.get(user=request.user)
            print(f" Found existing profile: {profile}")
            
            # UPDATE existing profile
            serializer = UserProfileSerializer(profile, data=request.data, partial=True)
            if serializer.is_valid():
                updated_profile = serializer.save()
                print(" Profile updated successfully")
                return Response(UserProfileSerializer(updated_profile).data, status=status.HTTP_200_OK)
            print(" PUT validation errors:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
        except UserProfile.DoesNotExist:
            print(" No profile found - CREATING new profile")
            
            serializer = UserProfileSerializer(data=request.data)
            if serializer.is_valid():
                new_profile = serializer.save(user=request.user)
                print(" New profile created successfully")
                return Response(UserProfileSerializer(new_profile).data, status=status.HTTP_201_CREATED)
            print(" CREATE validation errors:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)  
@csrf_exempt
@api_view(['GET'])
def debug_auth_test(request):
    """Temporary endpoint to test authentication"""
    from .models import UserToken
    
    auth_header = request.META.get('HTTP_AUTHORIZATION', '')
    print(f" DEBUG - Raw header: {auth_header}")
    
    if auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1].strip()
        print(f" DEBUG - Token: '{token}'")
        
        try:
            user_token = UserToken.objects.get(key=token)
            return Response({
                "status": "success", 
                "user": user_token.user.name,
                "user_id": user_token.user.user_id
            })
        except UserToken.DoesNotExist:
            return Response({"status": "token_not_found"}, status=401)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=500)
    
    return Response({"status": "no_token"}, status=401)    
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


@csrf_exempt
@require_http_methods(["GET", "POST"])
@authentication_classes([CustomTokenAuthentication])
@permission_classes([IsAuthenticated])
def employer_ratings_list(request):
    """
    GET: List all employer ratings
    POST: Create a new employer rating
    """
    try:
        if request.method == 'GET':
            ratings = EmployerRating.objects.all()
            serializer = EmployerRatingSerializer(ratings, many=True)
            return JsonResponse(serializer.data, safe=False)
            
        elif request.method == 'POST':
            # For POST requests with JSON data
            import json
            data = json.loads(request.body)
            
            # Add the employer from the authenticated user
            data['employer'] = request.user
            
            serializer = EmployerRatingSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                return JsonResponse(serializer.data, status=201)
            return JsonResponse(serializer.errors, status=400)
            
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET", "PUT", "DELETE"])
@authentication_classes([CustomTokenAuthentication])
@permission_classes([IsAuthenticated])
def employer_rating_detail(request):
    """
    GET: Get specific employer rating
    PUT: Update employer rating
    DELETE: Delete employer rating
    """
    try:
        rating = EmployerRating.objects.get()
        
        if request.method == 'GET':
            serializer = EmployerRatingSerializer(rating)
            return JsonResponse(serializer.data)
            
        elif request.method == 'PUT':
            # Check if user owns this rating
            if rating.employer != request.user:
                return JsonResponse({"error": "Not authorized"}, status=403)
                
            import json
            data = json.loads(request.body)
            serializer = EmployerRatingSerializer(rating, data=data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return JsonResponse(serializer.data)
            return JsonResponse(serializer.errors, status=400)
            
        elif request.method == 'DELETE':
            # Check if user owns this rating
            if rating.employer != request.user:
                return JsonResponse({"error": "Not authorized"}, status=403)
                
            rating.delete()
            return JsonResponse({"message": "Rating deleted successfully"}, status=204)
            
    except EmployerRating.DoesNotExist:
        return JsonResponse({"error": "Rating not found"}, status=404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET"])
@authentication_classes([CustomTokenAuthentication])
@permission_classes([IsAuthenticated])
def my_employer_ratings(request):
    """
    GET: Get all ratings submitted by the current employer
    """
    try:
        ratings = EmployerRating.objects.filter(employer=request.user)
        serializer = EmployerRatingSerializer(ratings, many=True)
        return JsonResponse(serializer.data, safe=False)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET"])
@authentication_classes([CustomTokenAuthentication])
@permission_classes([IsAuthenticated])
def freelancer_ratings(request, freelancer_id):
    """
    GET: Get all ratings for a specific freelancer
    """
    try:
        ratings = EmployerRating.objects.filter(freelancer_id=freelancer_id)
        serializer = EmployerRatingSerializer(ratings, many=True)
        return JsonResponse(serializer.data, safe=False)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)


   
from .models import User, UserToken
import uuid

@api_view(['POST'])
@permission_classes([AllowAny])
def apilogin(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        name = serializer.validated_data['name'].strip()
        password = serializer.validated_data['password']

        try:
            user = User.objects.get(name=name)

            if user.check_password(password):  
                
                token, created = UserToken.objects.get_or_create(user=user)
                if not created:
                    
                    token.key = uuid.uuid4()
                    token.save()

                return Response(
                    {
                        "message": "Login successful",
                        "user_id": user.user_id,
                        "name": user.name,
                        "token": str(token.key),
                    },
                    status=status.HTTP_200_OK
                )
            else:
                return Response({"error": "Invalid login"}, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
            return Response({"error": "Invalid login"}, status=status.HTTP_400_BAD_REQUEST)

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
    


@csrf_exempt
@require_http_methods(["POST"])
def apisubmit_proposal(request):
    try:
        print(" PROPOSAL SUBMISSION STARTED")
        
        
        auth = CustomTokenAuthentication()
        auth_result = auth.authenticate(request)
        
        if auth_result is None:
            print(" AUTHENTICATION FAILED - No valid token")
            return JsonResponse({"error": "Authentication failed"}, status=401)
            
        request.user, request.auth = auth_result
        
        
        user_identifier = getattr(request.user, 'username', 
                                getattr(request.user, 'email', 
                                        getattr(request.user, 'name', 
                                                f"User_{request.user}")))
        print(f" USER AUTHENTICATED: {user_identifier}")
        print(f" USER ID: {request.user}")

        # Get form data - use request.POST for multipart forms
        task_id = request.POST.get("task_id")
        bid_amount = request.POST.get("bid_amount")
        title = request.POST.get("title", "")
        cover_letter_file = request.FILES.get('cover_letter_file')

        print(f" RECEIVED FORM DATA:")
        print(f"   - task_id: {task_id}")
        print(f"   - bid_amount: {bid_amount}")
        print(f"   - title: {title}")
        print(f"   - file_received: {cover_letter_file is not None}")

        
        if not task_id:
            return JsonResponse({"error": "Task ID is required"}, status=400)
        if not cover_letter_file:
            return JsonResponse({"error": "Cover letter PDF file is required"}, status=400)

        
        try:
            task = Task.objects.get(pk=task_id)
            print(f" Task found: {task.title}")
        except Task.DoesNotExist:
            return JsonResponse({"error": "Task not found"}, status=404)

       
        if Proposal.objects.filter(task=task, freelancer=request.user).exists():
            return JsonResponse({"error": "You have already submitted a proposal for this task"}, status=400)

        
        proposal = Proposal(
            task=task,
            freelancer=request.user,
            bid_amount=float(bid_amount) if bid_amount else 0.0,      
            
            #cover_letter='Cover letter provided as PDF file',
        )
        proposal.save()
        print(f"Proposal saved with ID: {proposal}")

        # Save file
        if cover_letter_file and hasattr(proposal, 'cover_letter_file'):
            proposal.cover_letter_file.save(cover_letter_file.name, cover_letter_file)
            proposal.save()
            print(f" PDF file saved: {cover_letter_file.name}")

        return JsonResponse({
            "id": proposal,
            "task_id": proposal.task.id,
            "freelancer_id": proposal.freelancer.id,
            "cover_letter": proposal.cover_letter,
            "bid_amount": float(proposal.bid_amount),
            "status": proposal.status,
            "title": proposal.title,
            "message": "Proposal submitted successfully"
        }, status=201)

    except Exception as e:
        print(f" ERROR: {str(e)}")
        import traceback
        print(f" TRACEBACK: {traceback.format_exc()}")
        return JsonResponse({"error": f"Server error: {str(e)}"}, status=500)
@api_view(['GET'])
def apitask_list(request):
    
    try:
        
        tasks = Task.objects.select_related('employer').prefetch_related('employer__profile').all()
        
        data = []
        for task in tasks:
            
            employer_profile = getattr(task.employer, 'profile', None)
            
            task_data = {
                'task_id': task.task_id,
                'title': task.title,
                'description': task.description,
                'is_approved': task.is_approved,
                'created_at': task.created_at.isoformat() if task.created_at else None,
                'assigned_user': task.assigned_user.user_id if task.assigned_user else None,
                'completed': False,  
                'employer': {
                    'id': task.employer.employer_id,
                    'username': task.employer.username,
                    'contact_email': task.employer.contact_email,
                    'company_name': employer_profile.company_name if employer_profile else None,
                    'profile_picture': employer_profile.profile_picture.url if employer_profile and employer_profile.profile_picture else None,
                    'phone_number': employer_profile.phone_number if employer_profile else None,
                }
            }
            data.append(task_data)
        
        print(f" Returning {len(data)} tasks with employer data")
        return Response(data)
        
    except Exception as e:
        print(f" Error in apitask_list: {e}")
        return Response({"error": str(e)}, status=500)


@api_view(['GET', 'PUT', 'DELETE'])
def apitask_detail(request, pk):
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response({"error": "Task not found"}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = TaskSerializer(task)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = TaskSerializer(task, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        task.delete()
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
@api_view(["GET"])
def freelancer_contracts(request, freelancer_id):
   
    contracts = Contract.objects.filter(freelancer_id=freelancer_id)
    serializer = ContractSerializer(contracts, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(["GET"])
def contract_detail(request, contract_id):
    
    try:
        contract = Contract.objects.get(pk=contract_id)
    except Contract.DoesNotExist:
        return Response({"error": "Contract not found"}, status=status.HTTP_404_NOT_FOUND)

    serializer = ContractSerializer(contract)
    return Response(serializer.data, status=status.HTTP_200_OK)
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
    payment.mpesa_receipt = "MPESA12345"  
    payment.save()

    return Response({
        "message": "Withdraw request processed successfully",
        "payment": PaymentSerializer(payment).data
    }, status=status.HTTP_200_OK)


def employer_dashboard(request):
    employer_id = request.session.get('employer_id')
    
    if not employer_id:
        return redirect('login')
    
    try:
        employer = Employer.objects.get(employer_id=employer_id)
        
        
        active_jobs = Task.objects.filter(employer=employer).count()
        pending_proposals = Proposal.objects.filter(task__employer=employer).count()
        ongoing_tasks = Task.objects.filter(employer=employer).count()
        
        total_spent = 0  # Temporary until Payment model is fixed
        
        
        jobs = Task.objects.filter(employer=employer).order_by('-created_at')[:5]
        proposals = Proposal.objects.filter(task__employer=employer).select_related('freelancer', 'task').order_by('-submitted_at')[:5]
        payments = []  
        ratings = []   
        
        context = {
            'active_jobs': active_jobs,
            'pending_proposals': pending_proposals,
            'ongoing_tasks': ongoing_tasks,
            'total_spent': total_spent,
            'jobs': jobs,
            'proposals': proposals,
            'payments': payments,
            'ratings': ratings,
            'employer': employer,
        }
        
        return render(request, 'dashboard.html', context)
        
    except Exception as e:
        print(f"Dashboard error: {e}")
        return render(request, 'dashboard.html', {
            'active_jobs': 0,
            'pending_proposals': 0,
            'ongoing_tasks': 0,
            'total_spent': 0,
            'jobs': [],
            'proposals': [],
            'payments': [],
            'ratings': [],
        })
        
def register(request):
    if request.method == "POST":
        username = request.POST.get("username")
        contact_email = request.POST.get("contact_email")
        phone_number = request.POST.get("phone_number")
        password = request.POST.get("password")
        
        
        if Employer.objects.filter(contact_email=contact_email).exists():
            messages.error(request, "Email already exists!")
            return redirect("register")
        
        
        if Employer.objects.filter(username=username).exists():
            messages.error(request, "Username already exists!")
            return redirect("register")
        
        
        if phone_number and Employer.objects.filter(phone_number=phone_number).exists():
            messages.error(request, "Phone number already registered!")
            return redirect("register")
        
        employer = Employer(
            username=username,
            contact_email=contact_email,
            phone_number=phone_number,
            password=make_password(password)          
        )
        employer.save()
        messages.success(request, "Registration successful. Please login.")
        return redirect("login")
    
    return render(request, 'register.html')

def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        try:
            employer = Employer.objects.get(username=username)
            if check_password(password, employer.password):
                # Store employer_id in session, not the object
                request.session['employer_id'] = employer.employer_id
                request.session['employer_name'] = employer.username
                return redirect('employer_dashboard')
            else:
                messages.error(request, "Invalid password")
        except Employer.DoesNotExist:
            messages.error(request, "Username not found")
    
    return render(request, 'login.html')

def logout_view(request):
    request.session.flush()
    messages.success(request, "You have been successfully logged out.")
    return redirect("login")



def task_list(request):
    # Get the logged-in employer's ID from session
    employer_id = request.session.get('employer_id')
    
    if not employer_id:
        return redirect('login')
    
    try:
        # Get the employer object
        employer = Employer.objects.get(employer_id=employer_id)
        
        # Only show tasks that belong to this specific employer
        tasks = Task.objects.filter(employer=employer).select_related("employer")
        
        return render(request, "task.html", {
            "tasks": tasks,
            "employer": employer
        })
        
    except Employer.DoesNotExist:
        request.session.flush()
        return redirect('login')
def create_task(request):
    # Get the logged-in employer's ID from session
    employer_id = request.session.get('employer_id')
    
    if not employer_id:
        return redirect('login')
    
    try:
        # Get the employer object
        employer = Employer.objects.get(employer_id=employer_id)
        
        if request.method == 'POST':
            # Create task and automatically assign it to this employer
            # BUT the task will be visible to ALL freelancers
            task = Task(
                title=request.POST.get('title'),
                description=request.POST.get('description'),
                employer=employer,  # This tracks who created the task
                category=request.POST.get('category'),
                budget=request.POST.get('budget') or 0,
                deadline=request.POST.get('deadline'),
                required_skills=request.POST.get('skills', ''),
                is_urgent=bool(request.POST.get('is_urgent')),
                is_active=True,  # Task is active and visible to freelancers
                status='Open'  # Task is open for proposals
            )
            task.save()
            
            messages.success(request, "Task created successfully! It's now visible to all freelancers.")
            return redirect('task_list')
        
        return render(request, "create_task.html", {
            "employer": employer
        })
        
    except Employer.DoesNotExist:
        request.session.flush()
        return redirect('login')

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
    

def create_employer_rating(request):
    # Get the logged-in employer
    employer_id = request.session.get('employer_id')
    if not employer_id:
        return redirect('login')
    
    try:
        employer = Employer.objects.get(employer_id=employer_id)
        
        if request.method == "POST":
            # Get task_id from the form to identify which task to rate
            task_id = request.POST.get("task_id")
            if not task_id:
                messages.error(request, "Please select a task to rate.")
                return redirect('create_employer_rating')
            
            task = get_object_or_404(Task, task_id=task_id, employer=employer)
            
            score = request.POST.get("score")
            review = request.POST.get("review", "")

            if not score:
                messages.error(request, "Please select a rating score.")
                return render(request, "rating.html", {"task": task})

            # Create the rating
            EmployerRating.objects.create(
                task=task,
                freelancer=task.assigned_user,  # The freelancer who worked on this task
                employer=employer,  
                score=int(score),
                review=review
            )
            messages.success(request, "Your rating has been submitted successfully!")
            return redirect("employer_rating_list")

        else:
            # GET request - show tasks that can be rated
            # Show completed tasks that have an assigned freelancer and haven't been rated yet
            rateable_tasks = Task.objects.filter(
                employer=employer,
                assigned_user__isnull=False,  # Has an assigned freelancer
                status='completed'  # Or whatever indicates completion
            ).exclude(
                employerrating__isnull=False  # Exclude already rated tasks
            )
            
            return render(request, "rating.html", {"tasks": rateable_tasks})
            
    except Employer.DoesNotExist:
        request.session.flush()
        return redirect('login')


def employer_rating_list(request):
    ratings = EmployerRating.objects.all().order_by("-created_at")
    return render(request, "rating_list.html", {"ratings": ratings})


def employer_ratings_detail(request, employer_id):
    employer = get_object_or_404(Employer, id=employer_id)
    ratings = EmployerRating.objects.filter(employer=employer).order_by("-created_at")
    return render(request, "employer_ratings_detail.html", {"employer": employer, "ratings": ratings})


def proposal(request):
    # Get the logged-in employer's ID from session
    employer_id = request.session.get('employer_id')
    
    if not employer_id:
        return redirect('login')
    
    try:
        # Get the employer object
        employer = Employer.objects.get(employer_id=employer_id)
        
        # Only show proposals for this employer's tasks
        proposals = Proposal.objects.filter(
            task__employer=employer
        ).select_related('freelancer', 'task')
        
        return render(request, "proposal.html", {
            "proposals": proposals,
            "employer": employer
        })
        
    except Employer.DoesNotExist:
        request.session.flush()
        return redirect('login')


def create_employer_profile(request):
    if request.method == "POST":
        contact_email = request.POST.get("contact_email")
        company_name = request.POST.get("company_name")
        phone_number = request.POST.get("phone_number")
        profile_picture = request.FILES.get("profile_picture")

        try:
            EmployerProfile.objects.create(
                contact_email=contact_email,
                company_name=company_name,
                phone_number=phone_number,
                profile_picture=profile_picture,
            )
            messages.success(request, "Profile created successfully ✅")
            return redirect("employer_dashboard")

        except IntegrityError:
            messages.warning(request, f"A profile with email {contact_email} already exists ❗")
            return redirect("create_employer_profile")

    return render(request, "employer_profile.html")


def employer_profile(request, pk):
    profile = EmployerProfile.objects.get(pk=pk)
    return render(request, 'employer_profile_detail.html', {'profile': profile})

def employer_contract(request, contract_id):
    
    if not request.session.get("employer_id"):
        return redirect("login")

    
    contract = get_object_or_404(Contract, pk=contract_id, employer_id=request.session.get("employer_id"))

    if request.method == "POST":
        contract.is_active = True   
        contract.save()
        messages.success(request, "You have successfully agreed to the contract.")
        return redirect("employer_dashboard")

    return render(request, "contract.html", {"contract": contract})


def test_404(request):
    return render(request, "404.html", status=404)