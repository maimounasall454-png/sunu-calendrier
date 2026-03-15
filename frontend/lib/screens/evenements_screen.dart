import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/evenement.dart';
import '../main.dart';


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
  bool _dejaCherche = false; // ── AJOUTER CETTE LIGNE ──

  @override
 void initState() {
    super.initState();
    _chargerDonnees(afficherSnackbar: false); // pas de snackbar au 1er chargement
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger quand on revient sur la page (ex: après connexion)
        if (_dejaCherche) {
          _chargerDonnees(afficherSnackbar: false);
        }
        _dejaCherche = true;
      }

      // APRÈS
  Future<void> _chargerDonnees({bool afficherSnackbar = true}) async {
        setState(() => _loading = true);
        try {
          final fetes = await ApiService.getFetesAutomatiques();
          final connecte = await ApiService.estConnecte();

          if (!connecte) {
        setState(() {
          _fetes = fetes;
          _evenementsPerso = [];
          _loading = false;
        });
        // Snackbar seulement si demandé ET si la page est active
        if (afficherSnackbar && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connectez-vous pour voir vos événements personnels'),
              backgroundColor: const Color(0xFF33691E),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Se connecter',
                textColor: Colors.white,
                onPressed: () {
                  MainScreen.of(context)?.allerVers(5);
                },
              ),
            ),
          );
        }
        return;
      }

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
    final persoMapped = _evenementsPerso.map((e) {
      // Supporte à la fois un objet Evenement et une Map JSON
      if (e is Evenement) {
        return {
          'id':    e.id,
          'titre': e.titre,
          'date': e.date,
          'type': e.typeEvent ?? 'personnel',
          'auto': false,
        };
      }
      // Fallback Map (réponse JSON brute de l'API)
      return {
        'id':    e.id,
        'titre': (e as Map)['titre'] ?? e['title'] ?? '',
        'date': e['date'] ?? '',
        'type': 'personnel',
        'auto': false,
      };
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
            onPressed: () => _chargerDonnees(afficherSnackbar: true),
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
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
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
                                trailing: evt['auto'] == false
                                    // ── Événement personnel : bouton supprimer ──
                                    ? IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _confirmerSuppression(evt),
                                      )
                                    // ── Fête auto : badge type ──
                                    : Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
 
  void _confirmerSuppression(Map evt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer'),
          ],
        ),
        content: Text('Supprimer "${evt['titre']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final id = evt['id'];
              if (id != null) {
                await ApiService.supprimerEvenement(id);
                _chargerDonnees();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  // ── CORRECTION : date picker natif au lieu du champ texte ──
  void _ajouterEvenement() {
    final titreCtrl = TextEditingController();
    DateTime? dateSelectionnee;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.event_note, color: Color(0xFF33691E)),
              SizedBox(width: 8),
              Text('Nouvel événement'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Champ Titre
              TextField(
                controller: titreCtrl,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF33691E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF33691E), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Sélecteur de date natif ──
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dateSelectionnee ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF33691E),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setStateDialog(() => dateSelectionnee = picked);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: dateSelectionnee != null
                          ? const Color(0xFF33691E)
                          : Colors.grey.shade400,
                      width: dateSelectionnee != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: dateSelectionnee != null
                            ? const Color(0xFF33691E)
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dateSelectionnee != null
                            ? '${dateSelectionnee!.day.toString().padLeft(2, '0')} / '
                              '${dateSelectionnee!.month.toString().padLeft(2, '0')} / '
                              '${dateSelectionnee!.year}'
                            : 'Choisir une date',
                        style: TextStyle(
                          fontSize: 15,
                          color: dateSelectionnee != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titreCtrl.text.isNotEmpty && dateSelectionnee != null) {
                  final dateStr =
                      '${dateSelectionnee!.year}-'
                      '${dateSelectionnee!.month.toString().padLeft(2, '0')}-'
                      '${dateSelectionnee!.day.toString().padLeft(2, '0')}';
                  await ApiService.creerEvenement(
                    Evenement(
                      titre: titreCtrl.text,
                      description: '',
                      date: dateStr,
                      typeEvent: 'personnel',
                      estPublic: false,
                    ),
                  );
                  Navigator.pop(ctx);
                  _chargerDonnees();
                } else {
                  // Feedback si champs vides
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir le titre et choisir une date'),
                      backgroundColor: Color(0xFF33691E),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF33691E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}