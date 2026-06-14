from django.db import models
from django.contrib.auth.models import User
from orphanages.models import Orphanage

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
    
    # Make user optional - allow null
    user = models.OneToOneField(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='staff_profile')
    staff_id = models.CharField(max_length=20, unique=True, blank=True, null=True)
    name = models.CharField(max_length=200, blank=True)  # Add name field
    email = models.EmailField(blank=True)  # Add email field
    role = models.CharField(max_length=20, choices=STAFF_ROLES, default='caregiver')
    department = models.CharField(max_length=100, blank=True)
    orphanage = models.ForeignKey(Orphanage, on_delete=models.SET_NULL, null=True, blank=True, related_name='staff_members')
    phone = models.CharField(max_length=20, blank=True)  # Add phone field
    hire_date = models.DateField(auto_now_add=True)
    emergency_contact = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.name} - {self.role}"