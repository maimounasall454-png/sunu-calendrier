# backend/utilisateurs/urls.py
from django.urls import path
from . import views
 
urlpatterns = [
    path('inscription/', views.inscription, name='inscription'),
    path('moi/',         views.mon_profil,  name='profil'),
]
