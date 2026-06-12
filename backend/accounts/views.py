from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth.models import User
from .serializers import UserSerializer
from .models import UserProfile

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = UserSerializer
    
    def post(self, request, *args, **kwargs):
        print("Registration request data:", request.data)
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            role = user.profile.role if hasattr(user, 'profile') else 'viewer'
            return Response({
                'success': True,
                'message': 'User created successfully',
                'username': user.username,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'role': role
            }, status=status.HTTP_201_CREATED)
        print("Registration errors:", serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CurrentUserView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        user = request.user
        data = {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'date_joined': user.date_joined,
        }
        if hasattr(user, 'profile'):
            data['role'] = user.profile.role
            data['phone_number'] = user.profile.phone_number
            if user.profile.orphanage:
                data['orphanage_name'] = user.profile.orphanage.name
        return Response(data)
    
    def patch(self, request):
        user = request.user
        data = request.data
        
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'email' in data:
            user.email = data['email']
        user.save()
        
        if hasattr(user, 'profile'):
            if 'phone_number' in data:
                user.profile.phone_number = data['phone_number']
                user.profile.save()
        
        return self.get(request)


class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        user = request.user
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')
        
        if not user.check_password(current_password):
            return Response({'error': 'Current password is incorrect'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(new_password)
        user.save()
        return Response({'message': 'Password changed successfully'})


class UserListView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        # Only super admin can view all users
        if hasattr(request.user, 'profile') and request.user.profile.role == 'super_admin':
            users = User.objects.all()
            data = []
            for user in users:
                user_data = {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                }
                if hasattr(user, 'profile'):
                    user_data['role'] = user.profile.role
                    user_data['phone_number'] = user.profile.phone_number
                    if user.profile.orphanage:
                        user_data['orphanage_name'] = user.profile.orphanage.name
                data.append(user_data)
            return Response(data)
        return Response({'error': 'Unauthorized'}, status=status.HTTP_403_FORBIDDEN)