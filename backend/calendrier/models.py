# backend/calendrier/models.py
from django.db import models
from django.contrib.auth.models import User
 
class FeteIslamique(models.Model):
    nom        = models.CharField(max_length=100)
    nom_wolof  = models.CharField(max_length=100, blank=True)
    mois_hijri = models.IntegerField()
    jour_hijri = models.IntegerField()
    description = models.TextField(blank=True)
 
    def __str__(self): return self.nom
 
    class Meta:
        ordering = ['mois_hijri', 'jour_hijri']
        verbose_name = 'Fête islamique'
 
 
class Evenement(models.Model):
    TYPE_CHOICES = [
        ('islamique', 'Islamique'),
        ('wolof',     'Wolof'),
        ('personnel', 'Personnel'),
        ('national',  'National'),
    ]
    titre       = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    date        = models.DateField()
    type_event  = models.CharField(max_length=20, choices=TYPE_CHOICES, default='personnel')
    est_public  = models.BooleanField(default=False)
    utilisateur = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    cree_le     = models.DateTimeField(auto_now_add=True)
    modifie_le  = models.DateTimeField(auto_now=True)
 
    def __str__(self): return f'{self.titre} ({self.date})'
    class Meta: ordering = ['date']
