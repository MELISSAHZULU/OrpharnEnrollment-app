from rest_framework import serializers
from .models import Child
from datetime import date

class ChildSerializer(serializers.ModelSerializer):
    age = serializers.SerializerMethodField()
    
    class Meta:
        model = Child
        fields = '__all__'
        read_only_fields = ['enrollment_date', 'reported_by']
    
    def get_age(self, obj):
        today = date.today()
        return today.year - obj.date_of_birth.year - ((today.month, today.day) < (obj.date_of_birth.month, obj.date_of_birth.day))