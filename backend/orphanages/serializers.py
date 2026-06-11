from rest_framework import serializers
from .models import Orphanage

class OrphanageSerializer(serializers.ModelSerializer):
    available_space = serializers.ReadOnlyField()
    
    class Meta:
        model = Orphanage
        fields = '__all__'