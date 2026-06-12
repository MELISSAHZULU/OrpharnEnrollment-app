from django.db import models
from django.contrib.auth.models import User

class Child(models.Model):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
        ('U', 'Unknown'),
    ]
    
    STATUS_CHOICES = [
        ('PENDING', 'Pending Review'),
        ('ENROLLED', 'Enrolled'),
        ('EMERGENCY', 'Emergency Placement'),
        ('TRANSFERRED', 'Transferred'),
        ('REUNITED', 'Reunited with Family'),
    ]
    
    EMERGENCY_TYPE_CHOICES = [
        ('birth_loss', 'Mother passed during childbirth'),
        ('abandoned', 'Abandoned newborn/infant'),
        ('medical_emergency', 'Critical medical condition'),
        ('abuse', 'Child abuse/neglect case'),
    ]
    
    # Personal Information
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES, default='U')
    village = models.CharField(max_length=200)
    district = models.CharField(max_length=100)
    
    # Emergency Enrollment Fields (NEW)
    emergency_type = models.CharField(max_length=20, choices=EMERGENCY_TYPE_CHOICES, null=True, blank=True)
    mother_name = models.CharField(max_length=200, blank=True, null=True)  # Deceased mother's name
    health_facility = models.CharField(max_length=200, blank=True, null=True)
    needs_immediate_transport = models.BooleanField(default=False)
    
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
        return f"{self.first_name} {self.last_name}" if self.first_name else f"Child #{self.id}"
    
    @property
    def age(self):
        if self.date_of_birth:
            from datetime import date
            today = date.today()
            return today.year - self.date_of_birth.year - ((today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day))
        return None
    
class CaseNote(models.Model):
    child = models.ForeignKey(Child, on_delete=models.CASCADE, related_name='case_notes')
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    note = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Note for {self.child.first_name} - {self.created_at.date()}"