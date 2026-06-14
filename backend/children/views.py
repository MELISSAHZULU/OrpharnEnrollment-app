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
        
        # Allow all roles to see all children for testing
        return Child.objects.all()
    
    def perform_create(self, serializer):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        orphanage = None
        if hasattr(user, 'profile') and user.profile.orphanage:
            orphanage = user.profile.orphanage
        
        serializer.save(
            reported_by=user,
            reporter_role=role,
            current_orphanage=orphanage,
            status='PENDING'
        )
    
    def update(self, request, *args, **kwargs):
        """Override update to handle partial updates properly"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        
        # Only update fields that are provided
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        
        # Save the update
        self.perform_update(serializer)
        
        return Response(serializer.data)
    
    def partial_update(self, request, *args, **kwargs):
        """Handle PATCH requests for status updates"""
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)
    
    @action(detail=True, methods=['post'], url_path='request_transport')
    def request_transport(self, request, pk=None):
        child = self.get_object()
        
        pickup_location = request.data.get('pickup_location')
        destination = request.data.get('destination')
        notes = request.data.get('notes', '')
        transport_type = request.data.get('transport_type', 'regular')
        
        if not pickup_location or not destination:
            return Response(
                {'error': 'Pickup location and destination are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        transport = TransportRequest.objects.create(
            child=child,
            requested_by=request.user,
            pickup_location=pickup_location,
            destination=destination,
            notes=notes,
            transport_type=transport_type,
            status='PENDING'
        )
        
        return Response({
            'success': True,
            'message': 'Transport request submitted successfully',
            'transport_id': transport.id,
            'status': transport.status
        }, status=status.HTTP_201_CREATED)