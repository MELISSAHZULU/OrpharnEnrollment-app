from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile
from orphanages.models import Orphanage

class UserSerializer(serializers.ModelSerializer):
    role = serializers.CharField(write_only=True, required=False, default='viewer')
    phone_number = serializers.CharField(write_only=True, required=False, allow_blank=True, allow_null=True)
    orphanage_name = serializers.CharField(write_only=True, required=False, allow_blank=True, allow_null=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'first_name', 'last_name', 
                  'role', 'phone_number', 'orphanage_name']
        extra_kwargs = {
            'password': {'write_only': True},
            'email': {'required': False},
            'first_name': {'required': False},
            'last_name': {'required': False},
        }
    
    def validate(self, data):
        if not data.get('username'):
            raise serializers.ValidationError({'username': 'Username is required'})
        return data
    
    def create(self, validated_data):
        # Extract profile fields
        role = validated_data.pop('role', 'viewer')
        phone_number = validated_data.pop('phone_number', '')
        orphanage_name = validated_data.pop('orphanage_name', '')
        
        print(f"Creating user with role: {role}")  # Debug print
        
        # Create user (this will trigger the post_save signal which creates a profile)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        
        # Find or create orphanage if name provided
        orphanage = None
        if orphanage_name:
            orphanage, _ = Orphanage.objects.get_or_create(
                name=orphanage_name,
                defaults={
                    'registration_number': f"REG-{orphanage_name[:5].upper()}",
                    'city': 'Unknown',
                    'district': 'Unknown',
                    'phone': phone_number or 'N/A',
                    'director_name': f"{user.first_name} {user.last_name}",
                    'capacity': 0,
                    'is_active': True
                }
            )
        
        # Update the existing profile (created by signal)
        profile, created = UserProfile.objects.get_or_create(user=user)
        profile.role = role  # Set the correct role
        profile.phone_number = phone_number
        if orphanage:
            profile.orphanage = orphanage
        profile.save()
        
        print(f"Profile created/updated with role: {profile.role}")  # Debug print
        
        return user
    
    def to_representation(self, instance):
        """Customize the output response"""
        data = {
            'id': instance.id,
            'username': instance.username,
            'email': instance.email,
            'first_name': instance.first_name,
            'last_name': instance.last_name,
        }
        if hasattr(instance, 'profile'):
            data['role'] = instance.profile.role
            data['phone_number'] = instance.profile.phone_number
            if instance.profile.orphanage:
                data['orphanage_name'] = instance.profile.orphanage.name
        return data