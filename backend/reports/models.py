from django.db import models
from django.contrib.auth.models import User

class VillageReport(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('assigned', 'Social Worker Assigned'),
        ('investigating', 'Under Investigation'),
        ('resolved', 'Resolved'),
        ('closed', 'Closed'),
    ]
    
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    
    # Report Information
    reported_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='village_reports')
    child_name = models.CharField(max_length=200)
    age = models.IntegerField()
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    village = models.CharField(max_length=200)
    district = models.CharField(max_length=100, blank=True)
    
    # Guardian Information
    guardian_name = models.CharField(max_length=200, blank=True)
    guardian_contact = models.CharField(max_length=50, blank=True)
    
    # Situation Details
    situation_description = models.TextField()
    urgent = models.BooleanField(default=False)
    
    # Status Tracking
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    assigned_to = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, blank=True, 
        related_name='assigned_reports'
    )
    
    # Resolution
    resolution_notes = models.TextField(blank=True)
    resolved_date = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Report for {self.child_name} - {self.status}"
    
    def save(self, *args, **kwargs):
        if self.status == 'resolved' and not self.resolved_date:
            from django.utils import timezone
            self.resolved_date = timezone.now()
        super().save(*args, **kwargs)
    
    class Meta:
        ordering = ['-created_at']


class ComplianceReport(models.Model):
    """For government compliance reporting"""
    MONTH_CHOICES = [
        (1, 'January'), (2, 'February'), (3, 'March'), (4, 'April'),
        (5, 'May'), (6, 'June'), (7, 'July'), (8, 'August'),
        (9, 'September'), (10, 'October'), (11, 'November'), (12, 'December'),
    ]
    
    generated_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='generated_reports')
    month = models.IntegerField(choices=MONTH_CHOICES)
    year = models.IntegerField()
    total_orphanages = models.IntegerField()
    total_children = models.IntegerField()
    total_staff = models.IntegerField()
    compliance_score = models.DecimalField(max_digits=5, decimal_places=2)
    report_file = models.FileField(upload_to='compliance_reports/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Compliance Report - {self.month}/{self.year}"