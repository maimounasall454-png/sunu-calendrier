# backend/calendrier/views.py
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.utils import timezone
from .models import FeteIslamique, Evenement
from .serializers import FeteIslomiqueSerializer, EvenementSerializer
from .utils import gregorien_vers_wolof, gregorien_vers_hijri
 
class FeteIslomiqueViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = FeteIslamique.objects.all()
    serializer_class = FeteIslomiqueSerializer
    permission_classes = [AllowAny]
 
class EvenementViewSet(viewsets.ModelViewSet):
    serializer_class = EvenementSerializer
    def get_queryset(self):
        qs = Evenement.objects.filter(est_public=True)
        if self.request.user.is_authenticated:
            qs = (qs | Evenement.objects.filter(utilisateur=self.request.user)).distinct()
        return qs
    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        serializer.save(utilisateur=user)
 
@api_view(["GET"])
@permission_classes([AllowAny])
def convertir_date(request):
    from datetime import datetime
    date_str = request.query_params.get("date")
    today = timezone.now().date() if not date_str else datetime.strptime(date_str, "%Y-%m-%d").date()
    JOURS = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"]
    MOIS  = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"]
    return Response({'gregorien': {'date': str(today), 'jour': today.day,
        'mois': today.month, 'annee': today.year,
        'jour_semaine': JOURS[today.weekday()], 'mois_nom': MOIS[today.month-1]},
        'hijri': gregorien_vers_hijri(today), 'wolof': gregorien_vers_wolof(today)})
 
@api_view(["GET"])
@permission_classes([AllowAny])
def date_du_jour(request):
    today = timezone.now().date()
    JOURS = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"]
    MOIS  = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"]
    return Response({'gregorien': {'date': str(today), 'jour': today.day,
        'mois': today.month, 'annee': today.year,
        'jour_semaine': JOURS[today.weekday()], 'mois_nom': MOIS[today.month-1]},
        'hijri': gregorien_vers_hijri(today), 'wolof': gregorien_vers_wolof(today)})
