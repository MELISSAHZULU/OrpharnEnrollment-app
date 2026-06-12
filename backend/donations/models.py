from django.db import models
from django.contrib.auth.models import User
from children.models import Child

class Donation(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('recurring', 'Recurring'),
    ]
    
    TYPE_CHOICES = [
        ('one_time', 'One Time Donation'),
        ('monthly', 'Monthly Sponsorship'),
        ('quarterly', 'Quarterly Sponsorship'),
        ('annual', 'Annual Sponsorship'),
    ]
    
    donor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='donations')
    child = models.ForeignKey(Child, on_delete=models.SET_NULL, null=True, blank=True, related_name='sponsorships')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    donation_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='monthly')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    transaction_id = models.CharField(max_length=100, blank=True, unique=True)
    receipt_number = models.CharField(max_length=100, blank=True, unique=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        if not self.receipt_number:
            import uuid
            self.receipt_number = f"RCP-{uuid.uuid4().hex[:8].upper()}"
        if not self.transaction_id:
            import uuid
            self.transaction_id = f"TXN-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)
    
    def __str__(self):
        child_name = self.child.first_name if self.child else "General Fund"
        return f"{self.donor.username} - ${self.amount} - {child_name}"
    
    class Meta:
        ordering = ['-created_at']