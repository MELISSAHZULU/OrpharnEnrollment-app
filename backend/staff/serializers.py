from rest_framework import serializers
from .models import Staff

class StaffSerializer(serializers.ModelSerializer):
    orphanage_name = serializers.CharField(source='orphanage.name', read_only=True)
    
    class Meta:
        model = Staff
        fields = ['id', 'name', 'email', 'staff_id', 'role', 'department', 
                  'phone', 'orphanage', 'orphanage_name', 'hire_date', 
                  'emergency_contact', 'address', 'is_active']
        read_only_fields = ['id', 'hire_date']