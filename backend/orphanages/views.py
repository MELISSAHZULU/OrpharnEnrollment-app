from rest_framework import viewsets, permissions
from .models import Orphanage
from .serializers import OrphanageSerializer

class OrphanageViewSet(viewsets.ModelViewSet):
    queryset = Orphanage.objects.all()
    serializer_class = OrphanageSerializer
    permission_classes = [permissions.IsAuthenticated]