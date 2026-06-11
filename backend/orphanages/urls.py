from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import OrphanageViewSet

router = DefaultRouter()
router.register(r'', OrphanageViewSet, basename='orphanage')

urlpatterns = [
    path('', include(router.urls)),
]