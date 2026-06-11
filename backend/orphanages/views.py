from rest_framework import viewsets, permissions
from rest_framework.response import Response
from .models import Orphanage
from .serializers import OrphanageSerializer

class OrphanageViewSet(viewsets.ModelViewSet):
    queryset = Orphanage.objects.all()  # Add this line
    serializer_class = OrphanageSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        
        # Check if user has profile attribute
        if not hasattr(user, 'profile'):
            return Orphanage.objects.none()
        
        role = user.profile.role
        
        # Super admin sees all orphanages
        if role == 'super_admin':
            return Orphanage.objects.all()
        # Government official sees all (read-only in frontend)
        elif role == 'government_official':
            return Orphanage.objects.all()
        # Orphanage staff/director sees only their orphanage
        elif user.profile.orphanage:
            return Orphanage.objects.filter(id=user.profile.orphanage.id)
        # Viewers and donors see only active orphanages (read-only)
        elif role in ['viewer', 'donor']:
            return Orphanage.objects.filter(is_active=True)
        # Others see none
        else:
            return Orphanage.objects.none()
    
    def get_permissions(self):
        # Read-only for viewers, donors, government
        if self.request.method in ['GET', 'HEAD', 'OPTIONS']:
            return [permissions.IsAuthenticated()]
        # Write permissions only for super admin and orphanage directors
        elif hasattr(self.request.user, 'profile') and self.request.user.profile.role in ['super_admin', 'orphanage_director']:
            return [permissions.IsAuthenticated()]
        else:
            return [permissions.IsAuthenticated()]