from django.contrib import admin
from .models import Donation

@admin.register(Donation)
class DonationAdmin(admin.ModelAdmin):
    list_display = ('donor', 'amount', 'donation_type', 'status', 'child', 'created_at')
    list_filter = ('status', 'donation_type', 'created_at')
    search_fields = ('donor__username', 'donor__email', 'receipt_number')
    readonly_fields = ('transaction_id', 'receipt_number', 'created_at')
    
    fieldsets = (
        ('Donor Information', {
            'fields': ('donor',)
        }),
        ('Donation Details', {
            'fields': ('amount', 'donation_type', 'status', 'child')
        }),
        ('Transaction Information', {
            'fields': ('transaction_id', 'receipt_number', 'notes')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )