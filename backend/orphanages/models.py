from django.db import models

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