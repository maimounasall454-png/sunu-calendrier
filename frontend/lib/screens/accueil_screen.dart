// frontend/lib/screens/accueil_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/date_conversion.dart';
import '../main.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});
  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  DateConversion? _data;
  bool _loading = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  String _compteARebours() {
    final prochaineFete = [
      {'nom': 'Nuit du Destin', 'date': '2026-03-16'},
      {'nom': 'Korité',         'date': '2026-03-20'},
      {'nom': 'Tabaski',        'date': '2026-05-27'},
      {'nom': 'Tamkharit',      'date': '2026-06-25'},
      {'nom': 'Gamou',          'date': '2026-08-25'},
    ];

    final today = DateTime.now();
    for (final fete in prochaineFete) {
      final dateFete = DateTime.parse(fete['date']!);
      final diff = dateFete.difference(today).inDays;
      if (diff >= 0) {
        if (diff == 0) return '🎉 ${fete['nom']} c\'est aujourd\'hui !';
        if (diff == 1) return '⏳ ${fete['nom']} demain !';
        return '🌙 ${fete['nom']} dans $diff jours';
      }
    }
    return '';
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      final d = await ApiService.getDateDuJour();
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erreur = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
   appBar: AppBar(
      title: const Text('Sunu Calendrier'),
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () {
            SunuCalendrierApp.of(context)?.toggleDarkMode();
          },
        ),
      ],
    ),

    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _erreur != null
        ? _erreurWidget()
        : _contenu(),
  );

  Widget _erreurWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Serveur Django inaccessible',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Lancez: python manage.py runserver',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _charger, child: const Text('Réessayer')),
      ],
    ),
  );

  Widget _contenu() => RefreshIndicator(
    onRefresh: _charger,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Aujourd\'hui',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          // Compte à rebours
          if (_compteARebours().isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🕌', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _compteARebours(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          _carte(
            'Calendrier Grégorien',
            _data!.dateGregorienne,
            null,
            Icons.calendar_today,
            Colors.blue,
          ),
          _carte(
            'Calendrier Islamique (Hijri)',
            _data!.dateHijri,
            null,
            Icons.nightlight_round,
            const Color(0xFF1B5E20),
          ),
          _carte(
            'Calendrier Wolof',
            _data!.nomJourWolof,
            _data!.infoWolof,
            Icons.language,
            Colors.orange,
          ),
        ],
      ),
    ),
  );

  Widget _carte(
    String titre,
    String valeur,
    String? sub,
    IconData icone,
    Color c,
  ) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: c.withOpacity(0.12),
            child: Icon(icone, color: c),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
