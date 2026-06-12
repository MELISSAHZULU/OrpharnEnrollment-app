from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Staff

class StaffSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='user.get_full_name', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    user_id = serializers.IntegerField(write_only=True, required=True)
    
    class Meta:
        model = Staff
        fields = ['id', 'user_id', 'user', 'name', 'username', 'email', 'staff_id', 
                  'role', 'department', 'orphanage', 'hire_date', 'emergency_contact', 
                  'address', 'is_active']
        read_only_fields = ['id', 'hire_date']
    
    def create(self, validated_data):
        user_id = validated_data.pop('user_id')
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            raise serializers.ValidationError({'user_id': 'User not found'})
        
        staff = Staff.objects.create(user=user, **validated_data)
        return staff