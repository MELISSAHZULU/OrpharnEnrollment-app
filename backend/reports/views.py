from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Sum, Avg
from .models import VillageReport, ComplianceReport
from .serializers import VillageReportSerializer, ComplianceReportSerializer
from children.models import Child
from orphanages.models import Orphanage
from staff.models import Staff

class VillageReportViewSet(viewsets.ModelViewSet):
    serializer_class = VillageReportSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        if role == 'super_admin':
            return VillageReport.objects.all()
        elif role == 'social_worker':
            return VillageReport.objects.filter(assigned_to=user)
        elif role == 'village_head':
            return VillageReport.objects.filter(reported_by=user)
        else:
            return VillageReport.objects.none()
    
    def perform_create(self, serializer):
        serializer.save(reported_by=self.request.user)
    
    @action(detail=True, methods=['post'])
    def assign(self, request, pk=None):
        report = self.get_object()
        social_worker_id = request.data.get('social_worker_id')
        from django.contrib.auth.models import User
        try:
            social_worker = User.objects.get(id=social_worker_id)
            report.assigned_to = social_worker
            report.status = 'assigned'
            report.save()
            return Response({'status': 'assigned', 'to': social_worker.username})
        except User.DoesNotExist:
            return Response({'error': 'Social worker not found'}, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        report = self.get_object()
        report.status = 'resolved'
        report.resolution_notes = request.data.get('resolution_notes', '')
        report.save()
        return Response({'status': 'resolved'})


class ComplianceReportViewSet(viewsets.ReadOnlyModelViewSet):
    """Read-only for government officials"""
    serializer_class = ComplianceReportSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        role = user.profile.role if hasattr(user, 'profile') else 'viewer'
        
        if role in ['super_admin', 'government_official']:
            return ComplianceReport.objects.all()
        return ComplianceReport.objects.none()
    
    @action(detail=False, methods=['get'])
    def generate(self, request):
        """Generate current compliance statistics"""
        orphanages = Orphanage.objects.all()
        children = Child.objects.all()
        staff = Staff.objects.all()
        
        total_orphanages = orphanages.count()
        total_children = children.count()
        total_staff = staff.count()
        
        # Calculate compliance score (simplified)
        compliance_score = 85.5  # Calculate based on your criteria
        
        return Response({
            'total_orphanages': total_orphanages,
            'total_children': total_children,
            'total_staff': total_staff,
            'compliance_score': compliance_score,
            'generated_at': 'Now'
        })