from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Donation
from .serializers import DonationSerializer

class DonationViewSet(viewsets.ModelViewSet):
    serializer_class = DonationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        # Donors see only their donations, admins see all
        if user.profile.role == 'super_admin':
            return Donation.objects.all()
        else:
            return Donation.objects.filter(donor=user)
    
    def perform_create(self, serializer):
        serializer.save(donor=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_completed(self, request, pk=None):
        donation = self.get_object()
        donation.status = 'completed'
        donation.save()
        return Response({'status': 'completed'})
    
    @action(detail=True, methods=['get'])
    def download_receipt(self, request, pk=None):
        donation = self.get_object()
        # In production, generate PDF receipt here
        return Response({
            'receipt_number': donation.receipt_number,
            'amount': str(donation.amount),
            'date': donation.created_at,
            'message': 'Receipt download would be available here'
        })