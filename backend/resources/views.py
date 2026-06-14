from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Room
from .serializers import RoomSerializer

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