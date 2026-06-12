from rest_framework import serializers
from .models import VillageReport, ComplianceReport

class VillageReportSerializer(serializers.ModelSerializer):
    reporter_name = serializers.CharField(source='reported_by.username', read_only=True)
    assigned_to_name = serializers.CharField(source='assigned_to.username', read_only=True, allow_null=True)
    
    class Meta:
        model = VillageReport
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']

class ComplianceReportSerializer(serializers.ModelSerializer):
    generated_by_name = serializers.CharField(source='generated_by.username', read_only=True)
    
    class Meta:
        model = ComplianceReport
        fields = '__all__'
        read_only_fields = ['created_at']