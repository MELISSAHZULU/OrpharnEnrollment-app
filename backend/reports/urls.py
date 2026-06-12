from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import VillageReportViewSet, ComplianceReportViewSet

router = DefaultRouter()
router.register(r'village', VillageReportViewSet, basename='village-report')
router.register(r'compliance', ComplianceReportViewSet, basename='compliance-report')

urlpatterns = [
    path('', include(router.urls)),
]