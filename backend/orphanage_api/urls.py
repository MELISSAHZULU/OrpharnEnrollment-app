from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/register/', include('accounts.urls')),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/users/', include('accounts.urls')),  # This makes /api/users/me/ work
    path('api/children/', include('children.urls')),
    path('api/resources/', include('resources.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/orphanages/', include('orphanages.urls')),
    path('api/staff/', include('staff.urls')),
]