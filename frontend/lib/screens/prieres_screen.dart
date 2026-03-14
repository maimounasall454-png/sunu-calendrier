import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrieresScreen extends StatefulWidget {
  const PrieresScreen({super.key});
  @override
  State<PrieresScreen> createState() => _PrieresScreenState();
}

class _PrieresScreenState extends State<PrieresScreen> {
  Map<String, dynamic> _horaires = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerHoraires();
  }

  Future<void> _chargerHoraires() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getHorairesPriere();
      setState(() {
        _horaires = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prieres = _horaires['prieres'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horaires de Prière'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerHoraires,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Bannière date ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('🕌',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(
                          _horaires['ville'] ?? 'Dakar, Sénégal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _horaires['date'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Cartes prières ─────────────────────
                  ...prieres.entries.map((entry) {
                    final infos = _infosPriere(entry.key);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              infos['icone']!,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          infos['description']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.value ?? '--:--',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 8),
                  Text(
                    'Source : Aladhan API — Méthode ISNA',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, String> _infosPriere(String nom) {
    if (nom.contains('Fajr'))    return {'icone': '🌅', 'description': 'Prière de l\'aube'};
    if (nom.contains('Dhuhr'))   return {'icone': '☀️', 'description': 'Prière du midi'};
    if (nom.contains('Asr'))     return {'icone': '🌤️', 'description': 'Prière de l\'après-midi'};
    if (nom.contains('Maghrib')) return {'icone': '🌇', 'description': 'Prière du coucher du soleil'};
    if (nom.contains('Isha'))    return {'icone': '🌙', 'description': 'Prière du soir'};
    return {'icone': '🕌', 'description': ''};
  }
}