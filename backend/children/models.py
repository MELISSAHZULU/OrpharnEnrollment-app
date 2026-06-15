from django.db import models
from django.contrib.auth.models import User
from orphanages.models import Orphanage  # Add this import

class Child(models.Model):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
        ('U', 'Unknown'),
    ]
    
    STATUS_CHOICES = [
    ('INITIATED', 'Initiated'),
    ('PENDING', 'Pending Review'),
    ('EMERGENCY', 'Emergency'),
    ('APPROVED', 'Approved'),
    ('REJECTED', 'Rejected'),
    ('ENROLLED', 'Enrolled'),
    ('PLACED', 'Placed'),
    ('TRANSFERRED', 'Transferred'),
    ('REUNITED', 'Reunited'),
]
    
    EMERGENCY_TYPE_CHOICES = [
        ('birth_loss', 'Mother passed during childbirth'),
        ('abandoned', 'Abandoned newborn/infant'),
        ('medical_emergency', 'Critical medical condition'),
        ('abuse', 'Child abuse/neglect case'),
    ]

    ENROLLMENT_STATUS_CHOICES = [
        ('INITIATED', 'Initiated - Pending Screening'),
        ('SCREENING', 'Under Social Worker Screening'),
        ('VERIFIED', 'Verified - Pending Approval'),
        ('APPROVED', 'Approved - Ready for Placement'),
        ('ENROLLED', 'Enrolled - Placement in Progress'),
        ('PLACED', 'Placed - In Care'),
        ('REJECTED', 'Rejected - Does Not Meet Criteria'),
        ('PENDING_INFO', 'Pending More Information'),
    ]
    
    enrollment_status = models.CharField(
        max_length=20, 
        choices=ENROLLMENT_STATUS_CHOICES, 
        default='INITIATED'
    )
    
    # Approval Tracking
    initiated_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, 
        related_name='initiated_enrollments', blank=True
    )
    screened_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, 
        related_name='screened_enrollments', blank=True
    )
    verified_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, 
        related_name='verified_enrollments', blank=True
    )
    approved_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, 
        related_name='approved_enrollments', blank=True
    )
    
    # Criteria Tracking
    criteria_met = models.JSONField(default=list)  # List of criteria IDs met
    verification_notes = models.TextField(blank=True)
    rejection_reason = models.TextField(blank=True)
    
    # Documents
    documents = models.JSONField(default=list)  # List of uploaded document URLs
    
    screening_date = models.DateTimeField(null=True, blank=True)
    approval_date = models.DateTimeField(null=True, blank=True)
    placement_date = models.DateTimeField(null=True, blank=True)

    
    # Personal Information
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES, default='U')
    village = models.CharField(max_length=200)
    district = models.CharField(max_length=100)
    
    # Emergency Enrollment Fields
    emergency_type = models.CharField(max_length=20, choices=EMERGENCY_TYPE_CHOICES, null=True, blank=True)
    mother_name = models.CharField(max_length=200, blank=True, null=True)
    health_facility = models.CharField(max_length=200, blank=True, null=True)
    needs_immediate_transport = models.BooleanField(default=False)
    
    # Background Information
    guardian_name = models.CharField(max_length=200, blank=True)
    guardian_contact = models.CharField(max_length=20, blank=True)
    reason_for_care = models.TextField()
    
    # Enrollment Information
    enrollment_date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    
    # Orphanage Assignment
    current_orphanage = models.ForeignKey(Orphanage, on_delete=models.SET_NULL, null=True, blank=True, related_name='children')
    
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
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='case_notes')
    note = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        child_name = self.child.first_name if self.child.first_name else f"Child #{self.child.id}"
        return f"Note for {child_name} - {self.created_at.date()}"
    
    class Meta:
        ordering = ['-created_at']


class MedicalRecord(models.Model):
    child = models.ForeignKey(Child, on_delete=models.CASCADE, related_name='medical_records')
    record_date = models.DateTimeField(auto_now_add=True)
    recorded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    diagnosis = models.TextField()
    treatment = models.TextField(blank=True)
    notes = models.TextField(blank=True)
    
    def __str__(self):
        return f"Medical record for {self.child.first_name} - {self.record_date.date()}"


class Vaccination(models.Model):
    child = models.ForeignKey(Child, on_delete=models.CASCADE, related_name='vaccinations')
    vaccine_name = models.CharField(max_length=100)
    date_given = models.DateField()
    next_due_date = models.DateField(null=True, blank=True)
    administered_by = models.CharField(max_length=200)
    notes = models.TextField(blank=True)
    
    def __str__(self):
        return f"{self.vaccine_name} for {self.child.first_name} - {self.date_given}"

current_orphanage = models.ForeignKey(
    'orphanages.Orphanage', 
    on_delete=models.SET_NULL, 
    null=True, 
    blank=True, 
    related_name='children'
)    