from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from .models import Staff
from .serializers import StaffSerializer

class StaffViewSet(viewsets.ModelViewSet):
    serializer_class = StaffSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        print(f"Staff list request - User: {user.username}, Role: {role}")
        
        # Super admin sees all staff
        if role == 'super_admin':
            return Staff.objects.all()
        # Orphanage director/staff see staff in their orphanage
        elif role in ['orphanage_director', 'orphanage_staff']:
            if hasattr(user, 'profile') and user.profile.orphanage:
                print(f"Filtering staff for orphanage: {user.profile.orphanage.name}")
                return Staff.objects.filter(orphanage=user.profile.orphanage)
            else:
                print("User has no orphanage assigned")
                return Staff.objects.none()
        # Others see nothing
        else:
            return Staff.objects.none()
    
    def create(self, request, *args, **kwargs):
        user = request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        print(f"Staff creation request - User: {user.username}, Role: {role}")
        print(f"Request data: {request.data}")
        
        if role not in ['super_admin', 'orphanage_director']:
            return Response(
                {'error': 'You do not have permission to add staff'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        data = request.data.copy()
        
        # Assign the staff to the director's orphanage
        if role == 'orphanage_director' and hasattr(user, 'profile') and user.profile.orphanage:
            data['orphanage'] = user.profile.orphanage.id
        
        serializer = self.get_serializer(data=data)
        if serializer.is_valid():
            staff = serializer.save()
            print(f"Staff created: {staff.name}, Orphanage: {staff.orphanage}")
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            print(f"Serializer errors: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)