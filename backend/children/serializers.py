from rest_framework import serializers
from .models import Child, CaseNote

class ChildSerializer(serializers.ModelSerializer):
    age = serializers.ReadOnlyField()
    
    class Meta:
        model = Child
        fields = '__all__'
        read_only_fields = ['enrollment_date', 'reported_by']

class CaseNoteSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    child_name = serializers.CharField(source='child.first_name', read_only=True)
    
    class Meta:
        model = CaseNote
        fields = ['id', 'child', 'child_name', 'note', 'author', 'author_name', 'created_at', 'updated_at']
        read_only_fields = ['author', 'created_at', 'updated_at']