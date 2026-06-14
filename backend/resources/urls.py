from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BedSpaceViewSet, TransportRequestViewSet, RoomViewSet

router = DefaultRouter()
router.register(r'beds', BedSpaceViewSet)
router.register(r'transport', TransportRequestViewSet)
router.register(r'rooms', RoomViewSet)

urlpatterns = [
    path('', include(router.urls)),
]