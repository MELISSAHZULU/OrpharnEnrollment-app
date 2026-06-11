from django.contrib import admin
from .models import Child

@admin.register(Child)
class ChildAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'last_name', 'age', 'village', 'district', 'status', 'enrollment_date')
    list_filter = ('status', 'gender', 'district', 'enrollment_date')
    search_fields = ('first_name', 'last_name', 'village', 'guardian_name')
    readonly_fields = ('enrollment_date',)
    fieldsets = (
        ('Personal Information', {
            'fields': ('first_name', 'last_name', 'date_of_birth', 'gender', 'photo')
        }),
        ('Location', {
            'fields': ('village', 'district')
        }),
        ('Guardian Information', {
            'fields': ('guardian_name', 'guardian_contact')
        }),
        ('Enrollment Details', {
            'fields': ('reason_for_care', 'status', 'reported_by', 'reporter_role')
        }),
        ('Medical Information', {
            'fields': ('medical_notes', 'special_needs'),
            'classes': ('collapse',)
        }),
    )