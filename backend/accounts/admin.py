from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from .models import UserProfile

class UserProfileInline(admin.StackedInline):
    model = UserProfile
    can_delete = False
    verbose_name_plural = 'Profile'

class CustomUserAdmin(UserAdmin):
    inlines = (UserProfileInline,)
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'get_role', 'get_orphanage')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'profile__role')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    
    def get_role(self, obj):
        return obj.profile.role if hasattr(obj, 'profile') else 'No role'
    get_role.short_description = 'Role'
    
    def get_orphanage(self, obj):
        if hasattr(obj, 'profile') and obj.profile.orphanage:
            return obj.profile.orphanage.name
        return 'None'
    get_orphanage.short_description = 'Orphanage'

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'role', 'phone_number', 'get_orphanage_name')
    list_filter = ('role',)
    search_fields = ('user__username', 'user__email')
    
    def get_orphanage_name(self, obj):
        return obj.orphanage.name if obj.orphanage else 'None'
    get_orphanage_name.short_description = 'Orphanage'

# Re-register UserAdmin
admin.site.unregister(User)
admin.site.register(User, CustomUserAdmin)