from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import BedSpace, TransportRequest, Room
from .serializers import BedSpaceSerializer, TransportRequestSerializer, RoomSerializer

class BedSpaceViewSet(viewsets.ModelViewSet):
    queryset = BedSpace.objects.all()
    serializer_class = BedSpaceSerializer
    permission_classes = [permissions.IsAuthenticated]

class TransportRequestViewSet(viewsets.ModelViewSet):
    queryset = TransportRequest.objects.all()
    serializer_class = TransportRequestSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return TransportRequest.objects.all()
        return TransportRequest.objects.filter(requested_by=user)

class RoomViewSet(viewsets.ModelViewSet):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @action(detail=True, methods=['patch'])
    def increment_occupancy(self, request, pk=None):
        room = self.get_object()
        room.occupied_beds += 1
        room.save()
        return Response({'status': 'updated', 'occupied_beds': room.occupied_beds})