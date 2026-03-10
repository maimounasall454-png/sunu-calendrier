# backend/calendrier/admin.py
from django.contrib import admin
from .models import FeteIslamique, Evenement
 
@admin.register(FeteIslamique)
class FeteAdmin(admin.ModelAdmin):
    list_display = ['nom','nom_wolof','mois_hijri','jour_hijri']
 
@admin.register(Evenement)
class EvenementAdmin(admin.ModelAdmin):
    list_display = ['titre','date','type_event','est_public','utilisateur']
    list_filter  = ['type_event','est_public']
