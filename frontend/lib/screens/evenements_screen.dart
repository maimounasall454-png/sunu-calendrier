import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/evenement.dart';

class EvenementsScreen extends StatefulWidget {
  const EvenementsScreen({super.key});
  @override
  State<EvenementsScreen> createState() => _EvenementsScreenState();
}

class _EvenementsScreenState extends State<EvenementsScreen> {
  List<dynamic> _fetes = [];
  List<dynamic> _evenementsPerso = [];
  bool _loading = true;
  String _filtre = 'tous';

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _loading = true);
    try {
      // Fêtes automatiques depuis l'API
      final fetes = await ApiService.getFetesAutomatiques();
      // Événements personnels depuis l'API
      final evts = await ApiService.getEvenements();
      setState(() {
        _fetes = fetes;
        _evenementsPerso = evts;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> get _tousEvenements {
    final fetesMapped = _fetes.map((f) => {
      'titre': f['nom'],
      'date': f['date'],
      'type': f['type'],
      'source': f['source'],
      'auto': true,
    }).toList();
    final persoMapped = _evenementsPerso.map((e) => {
      'titre': e['titre'] ?? e['title'] ?? '',
      'date': e['date'] ?? '',
      'type': 'personnel',
      'auto': false,
    }).toList();
    final tous = [...fetesMapped, ...persoMapped];
    tous.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
    return tous;
  }

  List<dynamic> get _evenementsFiltres {
    if (_filtre == 'tous') return _tousEvenements;
    return _tousEvenements.where((e) => e['type'] == _filtre).toList();
  }

  Color _couleurType(String type) {
    switch (type) {
      case 'islamique': return const Color(0xFF1B5E20);
      case 'national':  return const Color(0xFF0553B1);
      case 'personnel': return const Color(0xFF6A1B9A);
      default:          return Colors.grey;
    }
  }

  Color _bgType(String type) {
    switch (type) {
      case 'islamique': return const Color(0xFFE8F5E9);
      case 'national':  return const Color(0xFFE3F2FD);
      case 'personnel': return const Color(0xFFF3E5F5);
      default:          return Colors.grey.shade100;
    }
  }

  String _labelType(String type) {
    switch (type) {
      case 'islamique': return 'Islamique';
      case 'national':  return 'National';
      case 'personnel': return 'Personnel';
      default:          return type;
    }
  }

  String _iconeType(String type) {
    switch (type) {
      case 'islamique': return '🌙';
      case 'national':  return '🇸🇳';
      case 'personnel': return '👤';
      default:          return '📌';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        backgroundColor: const Color(0xFF33691E),        
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDonnees,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filtres ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['tous', 'islamique', 'national', 'personnel']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                                    label: Text(
                                      _filtre == 'tous' && f == 'tous'
                                          ? 'Tous (${_tousEvenements.length})'
                                          : _labelType(f),
                                      style: TextStyle(
                                        color: _filtre == f
                                            ? _couleurType(f == 'tous' ? 'national' : f)
                                            : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: _filtre == f
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    selected: _filtre == f,
                                    onSelected: (_) => setState(() => _filtre = f),
                                    selectedColor: Theme.of(context).brightness == Brightness.dark
                                        ? _couleurType(f == 'tous' ? 'national' : f).withOpacity(0.3)
                                        : _bgType(f == 'tous' ? 'national' : f),
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                    side: BorderSide(
                                      color: _filtre == f
                                          ? _couleurType(f == 'tous' ? 'national' : f)
                                          : Colors.transparent,
                                    ),
                                  ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // ── Liste ────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _evenementsFiltres.isEmpty
                    ? const Center(child: Text('Aucun événement'))
                    : RefreshIndicator(
                        onRefresh: _chargerDonnees,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _evenementsFiltres.length,
                          itemBuilder: (context, index) {
                            final evt = _evenementsFiltres[index];
                            final type = evt['type'] ?? 'personnel';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _bgType(type),
                                  child: Text(
                                    _iconeType(type),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                title: Text(
                                  evt['titre'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(evt['date'] ?? ''),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _bgType(type),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _labelType(type),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _couleurType(type),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterEvenement,
        backgroundColor: const Color(0xFF33691E),        
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _ajouterEvenement() {
    final titreCtrl = TextEditingController();
    final dateCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvel événement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titreCtrl,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Date (AAAA-MM-JJ)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titreCtrl.text.isNotEmpty && dateCtrl.text.isNotEmpty) {
                await ApiService.creerEvenement(
                  Evenement(
                    titre: titreCtrl.text,
                    description: '',
                    date: dateCtrl.text,
                    typeEvent: 'personnel',
                    estPublic: false,
                  ),
                );
                Navigator.pop(ctx);
                _chargerDonnees();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}