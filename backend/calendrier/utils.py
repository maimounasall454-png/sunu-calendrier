# backend/calendrier/utils.py
JOURS_WOLOF = {
    0: {'nom': 'Àlten',   'info': 'Lundi - Début de semaine'},
    1: {'nom': 'Talaata', 'info': 'Mardi - Jour des marchés'},
    2: {'nom': 'Àllarba', 'info': 'Mercredi - Jour des voyages'},
    3: {'nom': 'Alxames', 'info': 'Jeudi - Réunions familiales'},
    4: {'nom': 'Àjjuma',  'info': 'Vendredi - Jour saint'},
    5: {'nom': 'Gaawu',   'info': 'Samedi - Jour de repos'},
    6: {'nom': 'Dibéer',  'info': 'Dimanche - Jour de fête'},
}
 
MOIS_HIJRI = [
    'Muharram','Safar',"Rabi' al-Awwal","Rabi' al-Thani",
    'Jumada al-Awwal','Jumada al-Thani','Rajab',"Sha'ban",
    'Ramadan','Shawwal',"Dhu al-Qi'da",'Dhu al-Hijja'
]
 
def gregorien_vers_wolof(date_obj):
    return JOURS_WOLOF.get(date_obj.weekday(), {})
 
def gregorien_vers_hijri(date_obj):
    try:
        from hijri_converter import convert
        h = convert.Gregorian(date_obj.year, date_obj.month, date_obj.day).to_hijri()
        return {'jour': h.day, 'mois': MOIS_HIJRI[h.month-1], 'annee': h.year,
                'texte': f'{h.day} {MOIS_HIJRI[h.month-1]} {h.year}'}
    except Exception as e:
        return {'texte': f'Erreur: {e}', 'jour': 0, 'mois': '', 'annee': 0}
