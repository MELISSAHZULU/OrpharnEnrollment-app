from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChildViewSet, CaseNoteViewSet

router = DefaultRouter()
router.register(r'', ChildViewSet)
router.register(r'case-notes', CaseNoteViewSet, basename='case-note')

urlpatterns = [
    path('', include(router.urls)),
]