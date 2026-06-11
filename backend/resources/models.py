from django.db import models
from django.contrib.auth.models import User
from children.models import Child

class BedSpace(models.Model):
    orphanage_name = models.CharField(max_length=200)
    total_beds = models.IntegerField()
    occupied_beds = models.IntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)
    
    @property
    def available_beds(self):
        return self.total_beds - self.occupied_beds
    
    def __str__(self):
        return f"{self.orphanage_name} - {self.available_beds} beds available"

class TransportRequest(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('APPROVED', 'Approved'),
        ('COMPLETED', 'Completed'),
        ('CANCELLED', 'Cancelled'),
    ]
    
    child = models.ForeignKey(Child, on_delete=models.CASCADE, related_name='transport_requests')
    requested_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='transport_requests')
    pickup_location = models.CharField(max_length=300)
    destination = models.CharField(max_length=300)
    request_date = models.DateTimeField(auto_now_add=True)
    scheduled_date = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    notes = models.TextField(blank=True)
    
    def __str__(self):
        child_name = self.child.first_name if self.child else "Unknown"
        return f"Transport for {child_name} - {self.status}"
    
class Orphanage(models.Model):
    ORPHANAGE_TYPES = [
        ('public', 'Public'),
        ('private', 'Private'),
        ('faith_based', 'Faith Based'),
        ('ngo', 'NGO'),
    ]
    
    name = models.CharField(max_length=200)
    registration_number = models.CharField(max_length=50, unique=True)
    type = models.CharField(max_length=20, choices=ORPHANAGE_TYPES, default='public')
    address = models.TextField()
    city = models.CharField(max_length=100)
    district = models.CharField(max_length=100)
    phone = models.CharField(max_length=20)
    email = models.EmailField(blank=True)
    director_name = models.CharField(max_length=200)
    capacity = models.IntegerField()
    current_children = models.IntegerField(default=0)
    staff_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    established_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.name
    
    @property
    def available_space(self):
        return self.capacity - self.current_children