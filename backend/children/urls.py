from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChildViewSet
from .views import test_connection

router = DefaultRouter()
router.register(r'', ChildViewSet)

urlpatterns = [
    path('test/', test_connection, name='test'),
    path('', include(router.urls)),
]