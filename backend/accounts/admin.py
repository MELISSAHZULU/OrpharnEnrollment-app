from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from .models import UserProfile

class UserProfileInline(admin.StackedInline):
    model = UserProfile
    can_delete = False
    verbose_name_plural = 'Profile'
    extra = 0

class CustomUserAdmin(UserAdmin):
    inlines = (UserProfileInline,)
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'get_role', 'get_orphanage')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'profile__role')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    
    def get_role(self, obj):
        if hasattr(obj, 'profile') and obj.profile:
            return obj.profile.get_role_display()
        return 'No role'
    get_role.short_description = 'Role'
    
    def get_orphanage(self, obj):
        if hasattr(obj, 'profile') and obj.profile and obj.profile.orphanage:
            return obj.profile.orphanage.name
        return 'None'
    get_orphanage.short_description = 'Orphanage'

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_role_display', 'get_orphanage_name', 'phone_number')
    list_filter = ('role',)
    search_fields = ('user__username', 'user__email', 'phone_number')
    
    def get_role_display(self, obj):
        return obj.get_role_display()
    get_role_display.short_description = 'Role'
    
    def get_orphanage_name(self, obj):
        return obj.orphanage.name if obj.orphanage else 'None'
    get_orphanage_name.short_description = 'Orphanage'

# Re-register UserAdmin
admin.site.unregister(User)
admin.site.register(User, CustomUserAdmin)