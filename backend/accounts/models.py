from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserProfile(models.Model):
    ROLE_CHOICES = [
        ('super_admin', 'System Administrator'),
        ('orphanage_director', 'Orphanage Director'),
        ('orphanage_staff', 'Orphanage Staff'),
        ('social_worker', 'Social Worker'),
        ('healthcare_worker', 'Healthcare Worker'),
        ('village_head', 'Village Head'),
        ('donor', 'Donor / Sponsor'),
        ('government_official', 'Government Official'),
        ('viewer', 'Viewer'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    orphanage = models.ForeignKey('orphanages.Orphanage', on_delete=models.SET_NULL, null=True, blank=True, related_name='user_profiles')
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    role = models.CharField(max_length=30, choices=ROLE_CHOICES, default='viewer')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        orphanage_name = self.orphanage.name if self.orphanage else 'No Orphanage'
        return f"{self.user.username} - {self.get_role_display()} ({orphanage_name})"

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    if hasattr(instance, 'profile'):
        instance.profile.save()