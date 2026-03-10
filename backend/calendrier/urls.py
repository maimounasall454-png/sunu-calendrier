# backend/calendrier/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
 
router = DefaultRouter()
router.register(r'evenements', views.EvenementViewSet, basename='evenement')
router.register(r'fetes', views.FeteIslomiqueViewSet)
 
urlpatterns = [
    path("", include(router.urls)),
    path("convertir/",   views.convertir_date, name="convertir"),
    path("aujourd-hui/", views.date_du_jour,   name="aujourd-hui"),
]
