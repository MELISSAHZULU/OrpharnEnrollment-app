from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['role', 'phone_number', 'orphanage_name', 'profile_picture']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)
    role = serializers.CharField(write_only=True, required=False)
    phone_number = serializers.CharField(write_only=True, required=False)
    orphanage_name = serializers.CharField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 
                  'profile', 'role', 'phone_number', 'orphanage_name', 'date_joined']
        read_only_fields = ['date_joined']
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        if hasattr(instance, 'profile'):
            data['role'] = instance.profile.role
            data['phone_number'] = instance.profile.phone_number
            data['orphanage_name'] = instance.profile.orphanage_name
        return data
    
    def create(self, validated_data):
        role = validated_data.pop('role', 'social_worker')
        phone_number = validated_data.pop('phone_number', '')
        orphanage_name = validated_data.pop('orphanage_name', '')
        
        user = User.objects.create_user(**validated_data)
        
        profile, created = UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'role': role,
                'phone_number': phone_number,
                'orphanage_name': orphanage_name,
            }
        )
        
        return user