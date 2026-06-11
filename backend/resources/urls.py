from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BedSpaceViewSet, TransportRequestViewSet

router = DefaultRouter()
router.register(r'beds', BedSpaceViewSet)
router.register(r'transport', TransportRequestViewSet)

urlpatterns = [
    path('', include(router.urls)),
]