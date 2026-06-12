from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['phone_number', 'role']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)
    role = serializers.CharField(write_only=True, required=False)
    phone_number = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                  'profile', 'role', 'phone_number', 'date_joined']
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        if hasattr(instance, 'profile'):
            data['role'] = instance.profile.role
            data['phone_number'] = instance.profile.phone_number
            if instance.profile.orphanage:
                data['orphanage_name'] = instance.profile.orphanage.name
        return data