from rest_framework import serializers
from .models import Child, CaseNote

class CaseNoteSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source='author.username', read_only=True)
    
    class Meta:
        model = CaseNote
        fields = ['id', 'child', 'note', 'author', 'author_name', 'created_at']
        read_only_fields = ['author', 'created_at']

class ChildSerializer(serializers.ModelSerializer):
    age = serializers.ReadOnlyField()
    case_notes = CaseNoteSerializer(many=True, read_only=True)
    
    class Meta:
        model = Child
        fields = '__all__'
        read_only_fields = ['enrollment_date', 'reported_by']