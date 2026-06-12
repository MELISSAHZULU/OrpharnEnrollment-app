from rest_framework import serializers
from .models import BedSpace, TransportRequest

class BedSpaceSerializer(serializers.ModelSerializer):
    available_beds = serializers.ReadOnlyField()
    
    class Meta:
        model = BedSpace
        fields = '__all__'

class TransportRequestSerializer(serializers.ModelSerializer):
    child_name = serializers.CharField(source='child.first_name', read_only=True)
    requested_by_name = serializers.CharField(source='requested_by.username', read_only=True)
    
    class Meta:
        model = TransportRequest
        fields = '__all__'
        read_only_fields = ['request_date', 'requested_by', 'status']