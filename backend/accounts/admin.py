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
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'get_role')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'profile__role')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    
    def get_role(self, obj):
        return obj.profile.role if hasattr(obj, 'profile') else 'No role'
    get_role.short_description = 'Role'

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'role', 'phone_number', 'orphanage_name')
    list_filter = ('role',)
    search_fields = ('user__username', 'user__email', 'orphanage_name')

# Re-register UserAdmin
admin.site.unregister(User)
admin.site.register(User, CustomUserAdmin)