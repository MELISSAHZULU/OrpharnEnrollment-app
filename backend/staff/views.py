from rest_framework import viewsets, permissions
from rest_framework.response import Response
from .models import Staff
from .serializers import StaffSerializer

class StaffViewSet(viewsets.ModelViewSet):
    queryset = Staff.objects.all()  # Add this line
    serializer_class = StaffSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        
        # Check if user has profile attribute
        if not hasattr(user, 'profile'):
            return Staff.objects.none()
        
        role = user.profile.role
        
        # Super admin sees all staff
        if role == 'super_admin':
            return Staff.objects.all()
        # Orphanage staff/director sees only their orphanage staff
        elif user.profile.orphanage:
            return Staff.objects.filter(orphanage=user.profile.orphanage)
        # Others see nothing
        else:
            return Staff.objects.none()