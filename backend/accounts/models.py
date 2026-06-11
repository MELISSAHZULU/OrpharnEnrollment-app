from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserProfile(models.Model):
    ROLE_CHOICES = [
        ('admin', 'System Administrator'),
        ('orphanage_staff', 'Orphanage Staff'),
        ('healthcare_worker', 'Healthcare Worker'),
        ('village_head', 'Village Head'),
        ('viewer', 'Viewer'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    orphanage_name = models.CharField(max_length=200, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='viewer')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.user.username}'s Profile"

# Fix signals to prevent duplicate creation
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    if hasattr(instance, 'profile'):
        instance.profile.save()


# Add this to your existing models.py

class Staff(models.Model):
    STAFF_ROLES = [
        ('admin', 'Administrator'),
        ('manager', 'Orphanage Manager'),
        ('social_worker', 'Social Worker'),
        ('nurse', 'Nurse'),
        ('caregiver', 'Caregiver'),
        ('driver', 'Driver'),
        ('security', 'Security'),
        ('kitchen', 'Kitchen Staff'),
        ('teacher', 'Teacher'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='staff_profile')
    staff_id = models.CharField(max_length=20, unique=True)
    role = models.CharField(max_length=20, choices=STAFF_ROLES, default='caregiver')
    department = models.CharField(max_length=100, blank=True)
    hire_date = models.DateField(auto_now_add=True)
    salary = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    emergency_contact = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.role}"