# backend/utilisateurs/views.py
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.contrib.auth.models import User
 
@api_view(["POST"])
@permission_classes([AllowAny])
def inscription(request):
    username = request.data.get("username","").strip()
    password = request.data.get("password","")
    email    = request.data.get("email","")
    if not username or not password:
        return Response({'erreur':'username et password obligatoires'}, status=400)
    if User.objects.filter(username=username).exists():
        return Response({'erreur':'Nom d utilisateur déjà pris'}, status=409)
    user = User.objects.create_user(username=username, password=password, email=email)
    return Response({'message': f'Compte {username} créé', 'id': user.id}, status=201)
 
@api_view(["GET"])
def mon_profil(request):
    u = request.user
    return Response({'id':u.id,'username':u.username,'email':u.email})
