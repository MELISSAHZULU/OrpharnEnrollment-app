from django.db import models
from django.contrib.auth.models import User

class Child(models.Model):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    
    STATUS_CHOICES = [
        ('PENDING', 'Pending Review'),
        ('ENROLLED', 'Enrolled'),
        ('TRANSFERRED', 'Transferred'),
        ('REUNITED', 'Reunited with Family'),
    ]
    
    # Personal Information
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    village = models.CharField(max_length=200)
    district = models.CharField(max_length=100)
    
    # Background Information
    guardian_name = models.CharField(max_length=200, blank=True)
    guardian_contact = models.CharField(max_length=20, blank=True)
    reason_for_care = models.TextField()
    
    # Enrollment Information
    enrollment_date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    
    # Photo
    photo = models.ImageField(upload_to='child_photos/', blank=True, null=True)
    
    # Reported by
    reported_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='reported_children')
    reporter_role = models.CharField(max_length=100, blank=True)
    
    # Additional Info
    medical_notes = models.TextField(blank=True)
    special_needs = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name}"
    
    @property
    def age(self):
        from datetime import date
        today = date.today()
        return today.year - self.date_of_birth.year - ((today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day))