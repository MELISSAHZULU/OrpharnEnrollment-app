from rest_framework import viewsets, permissions
from .models import Child
from .serializers import ChildSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def test_connection(request):
    return Response({'message': 'Backend is connected successfully!'})

class ChildViewSet(viewsets.ModelViewSet):
    queryset = Child.objects.all()
    serializer_class = ChildSerializer
    permission_classes = [permissions.AllowAny]  # Allow any for testing