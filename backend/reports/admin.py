from django.contrib import admin
from .models import VillageReport, ComplianceReport

@admin.register(VillageReport)
class VillageReportAdmin(admin.ModelAdmin):
    list_display = ('child_name', 'village', 'status', 'reported_by', 'urgent', 'created_at')
    list_filter = ('status', 'urgent', 'created_at')
    search_fields = ('child_name', 'village', 'guardian_name')
    readonly_fields = ('created_at', 'updated_at')
    
    fieldsets = (
        ('Child Information', {
            'fields': ('child_name', 'age', 'gender', 'village', 'district')
        }),
        ('Guardian Information', {
            'fields': ('guardian_name', 'guardian_contact')
        }),
        ('Report Details', {
            'fields': ('situation_description', 'urgent')
        }),
        ('Status Tracking', {
            'fields': ('status', 'assigned_to', 'resolution_notes')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

@admin.register(ComplianceReport)
class ComplianceReportAdmin(admin.ModelAdmin):
    list_display = ('month', 'year', 'compliance_score', 'generated_by', 'created_at')
    list_filter = ('year', 'month')
    readonly_fields = ('created_at',)