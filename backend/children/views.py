from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth.models import User
from .models import Child
from .serializers import ChildSerializer
from resources.models import TransportRequest
from resources.serializers import TransportRequestSerializer

class ChildViewSet(viewsets.ModelViewSet):
    queryset = Child.objects.all()
    serializer_class = ChildSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        # Super admin and government see all
        if role in ['super_admin', 'government_official']:
            return Child.objects.all()
        # Orphanage staff/director see children in their orphanage only
        elif role in ['orphanage_director', 'orphanage_staff'] and hasattr(user, 'profile') and user.profile.orphanage:
            return Child.objects.filter(current_orphanage=user.profile.orphanage)
        # Healthcare workers see all (for medical purposes)
        elif role == 'healthcare_worker':
            return Child.objects.all()
        # Social workers see children they are assigned to
        elif role == 'social_worker':
            return Child.objects.filter(reported_by=user)
        # Village head sees children from their village
        elif role == 'village_head':
            return Child.objects.filter(village=user.profile.village) if hasattr(user, 'profile') and user.profile.village else Child.objects.none()
        # Others see limited data
        else:
            return Child.objects.none()
    
    def perform_create(self, serializer):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        # Set current orphanage if user belongs to one
        orphanage = None
        if hasattr(user, 'profile') and user.profile.orphanage:
            orphanage = user.profile.orphanage
        
        serializer.save(
            reported_by=user,
            reporter_role=role,
            current_orphanage=orphanage
        )
    
    @action(detail=True, methods=['post'], url_path='request_transport')
    def request_transport(self, request, pk=None):
        child = self.get_object()
        serializer = TransportRequestSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(
                child=child,
                requested_by=request.user
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)