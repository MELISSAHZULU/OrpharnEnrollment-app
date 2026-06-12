from rest_framework import viewsets, permissions
from .models import Child
from .serializers import ChildSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework import status
from .models import CaseNote
from .serializers import CaseNoteSerializer

@api_view(['GET'])
def test_connection(request):
    return Response({'message': 'Backend is connected successfully!'})

class ChildViewSet(viewsets.ModelViewSet):
    queryset = Child.objects.all()
    serializer_class = ChildSerializer
    permission_classes = [permissions.AllowAny]  

    @action(detail=False, methods=['post'])
    def emergency(self, request):
        """Emergency enrollment for mother loss at birth, abandoned newborns"""
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            child = serializer.save(
                reported_by=request.user,
                reporter_role='healthcare_worker',
                status='EMERGENCY'
            )
            
            # Create emergency notification
            Notification.objects.create(
                recipient=None,  # Broadcast to all orphanages
                title='EMERGENCY ENROLLMENT',
                message=f'URGENT: Newborn needs immediate placement at {request.data.get("health_facility", "health facility")}',
                notification_type='EMERGENCY'
            )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def birth_enrollment(self, request):
        """Special enrollment for birth-related orphan cases"""
        # Similar to above but with specific birth fields
        pass

    @action(detail=True, methods=['post'])
    def add_case_note(self, request, pk=None):
        child = self.get_object()
        serializer = CaseNoteSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(child=child, author=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'])
    def emergency_enrollment(self, request):
        """Special endpoint for emergency enrollment"""
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            child = serializer.save(
                reported_by=request.user,
                reporter_role='healthcare_worker',
                status='EMERGENCY'
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)