# backend/calendrier/serializers.py
from rest_framework import serializers
from .models import FeteIslamique, Evenement
 
class FeteIslomiqueSerializer(serializers.ModelSerializer):
    class Meta: model = FeteIslamique; fields = '__all__'
 
class EvenementSerializer(serializers.ModelSerializer):
    utilisateur_nom = serializers.SerializerMethodField()
    def get_utilisateur_nom(self, obj):
        return obj.utilisateur.username if obj.utilisateur else 'Anonyme'
    class Meta:
        model  = Evenement
        fields = ['id','titre','description','date','type_event',
                  'est_public','utilisateur','utilisateur_nom','cree_le','modifie_le']
        read_only_fields = ['cree_le','modifie_le','utilisateur']
