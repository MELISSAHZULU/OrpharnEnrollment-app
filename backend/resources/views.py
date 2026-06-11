from rest_framework import viewsets, permissions
from .models import BedSpace, TransportRequest
from .serializers import BedSpaceSerializer, TransportRequestSerializer

class BedSpaceViewSet(viewsets.ModelViewSet):
    queryset = BedSpace.objects.all()
    serializer_class = BedSpaceSerializer
    permission_classes = [permissions.AllowAny]

class TransportRequestViewSet(viewsets.ModelViewSet):
    queryset = TransportRequest.objects.all()
    serializer_class = TransportRequestSerializer
    permission_classes = [permissions.AllowAny]