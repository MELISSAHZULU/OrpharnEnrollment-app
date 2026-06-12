from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import Staff
from .serializers import StaffSerializer

class StaffViewSet(viewsets.ModelViewSet):
    serializer_class = StaffSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        # Super admin sees all staff
        if role == 'super_admin':
            return Staff.objects.all()
        # Orphanage director sees staff in their orphanage only
        elif role == 'orphanage_director' and hasattr(user, 'profile') and user.profile.orphanage:
            return Staff.objects.filter(orphanage=user.profile.orphanage)
        # Others see nothing (can't view staff list)
        else:
            return Staff.objects.none()
    
    def get_permissions(self):
        # Only super admin and orphanage director can create staff
        if self.action == 'create':
            return [permissions.IsAuthenticated()]
        return [permissions.IsAuthenticated()]
    
    def perform_create(self, serializer):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        # Only super admin and orphanage director can add staff
        if role not in ['super_admin', 'orphanage_director']:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You don't have permission to add staff")
        
        # If orphanage director, assign staff to their orphanage
        if role == 'orphanage_director' and hasattr(user, 'profile') and user.profile.orphanage:
            serializer.save(orphanage=user.profile.orphanage)
        else:
            serializer.save()