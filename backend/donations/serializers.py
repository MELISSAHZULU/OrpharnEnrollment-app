from rest_framework import serializers
from .models import Donation

class DonationSerializer(serializers.ModelSerializer):
    donor_name = serializers.CharField(source='donor.username', read_only=True)
    donor_email = serializers.EmailField(source='donor.email', read_only=True)
    child_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Donation
        fields = [
            'id', 'donor', 'donor_name', 'donor_email', 'child', 'child_name',
            'amount', 'donation_type', 'status', 'transaction_id', 
            'receipt_number', 'notes', 'created_at', 'updated_at'
        ]
        read_only_fields = ['transaction_id', 'receipt_number', 'created_at', 'updated_at']
    
    def get_child_name(self, obj):
        if obj.child:
            return f"{obj.child.first_name} {obj.child.last_name}"
        return "General Fund"