from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from accounts.views import RegisterView, CurrentUserView, ChangePasswordView, UserListView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/register/', RegisterView.as_view(), name='register'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/users/me/', CurrentUserView.as_view(), name='current_user'),
    path('api/users/', UserListView.as_view(), name='user_list'),
    path('api/users/change-password/', ChangePasswordView.as_view(), name='change_password'),
    path('api/children/', include('children.urls')),
    path('api/resources/', include('resources.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/orphanages/', include('orphanages.urls')),
    path('api/staff/', include('staff.urls')),
    path('api/donations/', include('donations.urls')),
    path('api/reports/', include('reports.urls')),
]