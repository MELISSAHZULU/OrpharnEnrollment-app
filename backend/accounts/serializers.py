from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    role = serializers.ChoiceField(choices=UserProfile.ROLE_CHOICES, write_only=True)
    phone_number = serializers.CharField(write_only=True, required=False, allow_blank=True)
    orphanage_name = serializers.CharField(write_only=True, required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'first_name', 'last_name', 
                  'role', 'phone_number', 'orphanage_name']
    
    def create(self, validated_data):
        role = validated_data.pop('role', 'viewer')
        phone_number = validated_data.pop('phone_number', '')
        orphanage_name = validated_data.pop('orphanage_name', '')
        
        # Create user
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        
        # Check if profile already exists (created by signal)
        profile, created = UserProfile.objects.get_or_create(
            user=user,
            defaults={
                'role': role,
                'phone_number': phone_number,
                'orphanage_name': orphanage_name,
            }
        )
        
        # If profile already existed, update it
        if not created:
            profile.role = role
            profile.phone_number = phone_number
            profile.orphanage_name = orphanage_name
            profile.save()
        
        return user