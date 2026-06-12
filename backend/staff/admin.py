from django.contrib import admin
from .models import Staff

@admin.register(Staff)
class StaffAdmin(admin.ModelAdmin):
    list_display = ('get_full_name', 'staff_id', 'role', 'orphanage', 'department', 'is_active', 'hire_date')
    list_filter = ('role', 'is_active', 'department', 'orphanage')
    search_fields = ('user__first_name', 'user__last_name', 'user__email', 'staff_id', 'phone_number')
    list_editable = ('is_active',)
    readonly_fields = ('hire_date',)
    
    def get_full_name(self, obj):
        return obj.user.get_full_name() if obj.user else 'N/A'
    get_full_name.short_description = 'Full Name'
    get_full_name.admin_order_field = 'user__first_name'
    
    fieldsets = (
        ('Personal Information', {
            'fields': ('user', 'staff_id')
        }),
        ('Employment Details', {
            'fields': ('role', 'department', 'orphanage', 'hire_date')
        }),
        ('Contact Information', {
            'fields': ('emergency_contact', 'address')
        }),
        ('Status', {
            'fields': ('is_active',)
        }),
    )