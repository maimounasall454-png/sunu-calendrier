// frontend/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evenement.dart';
import '../models/date_conversion.dart';

class ApiService {
  // 10.0.2.2 = votre PC depuis l'emulateur Android
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // CALENDRIER
  static Future<DateConversion> getDateDuJour() async {
    final r = await http.get(
      Uri.parse('$baseUrl/calendrier/aujourd-hui/'),
      headers: await _headers(),
    );
    if (r.statusCode == 200)
      return DateConversion.fromJson(json.decode(utf8.decode(r.bodyBytes)));
    throw Exception('Erreur ${r.statusCode}');
  }

  static Future<DateConversion> convertirDate(DateTime date) async {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final r = await http.get(
      Uri.parse('$baseUrl/calendrier/convertir/?date=$d'),
      headers: await _headers(),
    );
    if (r.statusCode == 200)
      return DateConversion.fromJson(json.decode(utf8.decode(r.bodyBytes)));
    throw Exception('Erreur conversion');
  }

  // EVENEMENTS
  static Future<List<Evenement>> getEvenements() async {
    final r = await http.get(
      Uri.parse('$baseUrl/calendrier/evenements/'),
      headers: await _headers(auth: true),
    );
    if (r.statusCode == 200) {
      final List data = json.decode(utf8.decode(r.bodyBytes));
      return data.map((e) => Evenement.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement');
  }

  static Future<bool> creerEvenement(Evenement e) async {
    final r = await http.post(
      Uri.parse('$baseUrl/calendrier/evenements/'),
      headers: await _headers(auth: true),
      body: json.encode(e.toJson()),
    );
    return r.statusCode == 201;
  }

  static Future<bool> supprimerEvenement(int id) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/calendrier/evenements/$id/'),
      headers: await _headers(auth: true),
    );
    return r.statusCode == 204;
  }

  // AUTH
  static Future<bool> connexion(String username, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (r.statusCode == 200) {
      final data = json.decode(r.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      await prefs.setString('username', username);
      return true;
    }
    return false;
  }

  static Future<void> deconnexion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
  }

  static Future<bool> estConnecte() async => (await _getToken()) != null;
}
