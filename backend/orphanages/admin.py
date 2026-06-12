from django.contrib import admin
from .models import Orphanage

@admin.register(Orphanage)
class OrphanageAdmin(admin.ModelAdmin):
    list_display = ('name', 'registration_number', 'type', 'city', 'district', 'current_children', 'capacity', 'is_active')
    list_filter = ('type', 'is_active', 'district', 'city')
    search_fields = ('name', 'registration_number', 'director_name', 'phone')
    list_editable = ('is_active',)
    readonly_fields = ('created_at',)
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'registration_number', 'type', 'is_active')
        }),
        ('Location', {
            'fields': ('address', 'city', 'district')
        }),
        ('Contact Information', {
            'fields': ('phone', 'email', 'director_name')
        }),
        ('Capacity Information', {
            'fields': ('capacity', 'current_children', 'staff_count')
        }),
        ('Additional Info', {
            'fields': ('established_date', 'created_at'),
            'classes': ('collapse',)
        }),
    )
    
    def get_queryset(self, request):
        return super().get_queryset(request).select_related()