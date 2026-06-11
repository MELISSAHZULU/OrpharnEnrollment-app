from django.contrib import admin
from .models import BedSpace, TransportRequest

@admin.register(BedSpace)
class BedSpaceAdmin(admin.ModelAdmin):
    list_display = ('orphanage_name', 'total_beds', 'occupied_beds', 'available_beds', 'last_updated')
    list_editable = ('total_beds', 'occupied_beds')
    readonly_fields = ('last_updated',)
    
    def available_beds(self, obj):
        return obj.available_beds
    available_beds.short_description = 'Available Beds'

@admin.register(TransportRequest)
class TransportRequestAdmin(admin.ModelAdmin):
    list_display = ('child', 'pickup_location', 'destination', 'status', 'request_date')
    list_filter = ('status', 'request_date')
    search_fields = ('child__first_name', 'child__last_name', 'pickup_location')
    readonly_fields = ('request_date',)