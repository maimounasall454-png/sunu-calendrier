# backend/calendrier/views.py
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.utils import timezone
from .models import FeteIslamique, Evenement
from .serializers import FeteIslomiqueSerializer, EvenementSerializer
from .utils import gregorien_vers_wolof, gregorien_vers_hijri
from hijridate import Hijri
import requests as req

# ── VIEWSETS ───────────────────────────────────────────────────────────────
class FeteIslomiqueViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = FeteIslamique.objects.all()
    serializer_class = FeteIslomiqueSerializer
    permission_classes = [AllowAny]

class EvenementViewSet(viewsets.ModelViewSet):
    serializer_class = EvenementSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        qs = Evenement.objects.filter(est_public=True)
        if self.request.user.is_authenticated:
            qs = (qs | Evenement.objects.filter(utilisateur=self.request.user)).distinct()
        return qs

    def perform_create(self, serializer):
        user = self.request.user if self.request.user.is_authenticated else None
        serializer.save(utilisateur=user)

# ── CONVERTIR UNE DATE ──────────────────────────────────────────────────────
@api_view(["GET"])
@permission_classes([AllowAny])
def convertir_date(request):
    from datetime import datetime
    date_str = request.query_params.get("date")
    today = timezone.now().date() if not date_str else datetime.strptime(date_str, "%Y-%m-%d").date()
    JOURS = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"]
    MOIS  = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août",
             "Septembre","Octobre","Novembre","Décembre"]
    return Response({
        'gregorien': {
            'date': str(today),
            'jour': today.day,
            'mois': today.month,
            'annee': today.year,
            'jour_semaine': JOURS[today.weekday()],
            'mois_nom': MOIS[today.month-1]
        },
        'hijri': gregorien_vers_hijri(today),
        'wolof': gregorien_vers_wolof(today)
    })

# ── DATE DU JOUR ───────────────────────────────────────────────────────────
@api_view(["GET"])
@permission_classes([AllowAny])
def date_du_jour(request):
    today = timezone.now().date()
    JOURS = ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi","Dimanche"]
    MOIS  = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août",
             "Septembre","Octobre","Novembre","Décembre"]
    return Response({
        'gregorien': {
            'date': str(today),
            'jour': today.day,
            'mois': today.month,
            'annee': today.year,
            'jour_semaine': JOURS[today.weekday()],
            'mois_nom': MOIS[today.month-1]
        },
        'hijri': gregorien_vers_hijri(today),
        'wolof': gregorien_vers_wolof(today)
    })

# ── FÊTES AUTOMATIQUES ─────────────────────────────────────────────────────
@api_view(["GET"])
@permission_classes([AllowAny])
def fetes_automatiques(request):
    annee = int(request.query_params.get("annee", "2026"))
    resultats = []

    # Jours fériés
    jours_feries = [
        {"nom": "Jour de l'An", "date": f"{annee}-01-01"},
        {"nom": "Fête de l'Indépendance", "date": f"{annee}-04-04"},
        {"nom": "Fête du Travail", "date": f"{annee}-05-01"},
        {"nom": "Assomption", "date": f"{annee}-08-15"},
        {"nom": "Toussaint", "date": f"{annee}-11-01"},
        {"nom": "Noël", "date": f"{annee}-12-25"},
    ]
    for f in jours_feries:
        resultats.append({
            "nom": f["nom"],
            "date": f["date"],
            "type": "national",
            "source": "Jours fériés officiels Sénégal"
        })

    # Fêtes islamiques (plus fiable)
    fetes_hijri = [
        {"nom": "Aïd el-Fitr (Korité)",  "mois": 10, "jour": 1},
        {"nom": "Aïd el-Adha (Tabaski)", "mois": 12, "jour": 10},
        {"nom": "Mawlid (Gamou)",        "mois": 3,  "jour": 12},
        {"nom": "Tamkharit",             "mois": 1,  "jour": 10},
        {"nom": "Nuit du Destin",        "mois": 9,  "jour": 27},
        {"nom": "Isra wal Mi'raj",       "mois": 7,  "jour": 27},
        {"nom": "Grand Magal de Touba",  "mois": 2,  "jour": 18},
        {"nom": "Gamou Médina Baye",     "mois": 3,  "jour": 14},
        {"nom": "Tamkharit (Nouvel An)", "mois": 1,  "jour": 1 },
    ]

    for fete in fetes_hijri:
        # On parcourt plusieurs années Hijri pour être sûr
        for y in range(1400, 1460):  # plage large pour couvrir l'année grégorienne
            try:
                g = Hijri(y, fete["mois"], fete["jour"]).to_gregorian()
                if g.year == annee:
                    resultats.append({
                        "nom": fete["nom"],
                        "date": f"{g.year}-{g.month:02d}-{g.day:02d}",
                        "type": "islamique",
                        "source": "Hijridate"
                    })
                    break  # une seule correspondance par fête suffit
            except:
                continue

    resultats_tries = sorted(resultats, key=lambda x: x["date"])
    return Response({
        "annee": annee,
        "total": len(resultats_tries),
        "evenements": resultats_tries
    })

# ── HORAIRES DE PRIÈRE ─────────────────────────────────────────────────────
@api_view(["GET"])
@permission_classes([AllowAny])
def horaires_priere(request):
    from datetime import datetime
    today = datetime.now()
    url = (
        f"http://api.aladhan.com/v1/timingsByCity"
        f"?city=Dakar&country=Senegal&method=2"
        f"&date={today.day}-{today.month}-{today.year}"
    )
    try:
        r = req.get(url, timeout=5)
        if r.status_code == 200:
            data = r.json().get("data", {})
            timings = data.get("timings", {})
            return Response({
                "date": str(today.date()),
                "ville": "Dakar, Sénégal",
                "prieres": {
                    "Fajr (Fadjr)":    timings.get("Fajr"),
                    "Dhuhr (Tisbar)":  timings.get("Dhuhr"),
                    "Asr (Takusaan)":  timings.get("Asr"),
                    "Maghrib (Timis)": timings.get("Maghrib"),
                    "Isha (Gudd)":     timings.get("Isha"),
                }
            })
    except Exception as e:
        return Response({"erreur": str(e)}, status=500)
    