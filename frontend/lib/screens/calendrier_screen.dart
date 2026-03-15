// frontend/lib/screens/calendrier_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/date_conversion.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});
  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  DateTime _mois = DateTime.now();
  String _mode = 'Gregorien';
  int? _jourSel;
  DateConversion? _detail;
  bool _loading = false;

  // ── Données Hijri du mois courant ──
  Map<String, dynamic>? _hijriMois;
  bool _loadingHijri = false;

  // Noms des mois Hijri
  static const List<String> _moisHijriNoms = [
    'Mouharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
    'Joumada al-Oula', 'Joumada al-Thania', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Chawwal', 'Dhou al-Qi\'da', 'Dhou al-Hijja',
  ];

  static const List<String> _moisGregorienNoms = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  static const List<String> _moisWolofNoms = [
    'Samwiiye', 'Fewriye', 'Maars', 'Awril', 'Mee', 'Suwe',
    'Suliye', 'Uut', 'Septàmbar', 'Oktoobar', 'Nowàmbar', 'Desàmbar',
  ];

  static const List<String> _joursGregorien = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const List<String> _joursWolof     = ['Alt', 'Tal', 'Àla', 'Alx', 'Àj', 'Gaw', 'Dib'];
  static const List<String> _joursWolofFull = [
    'Altine', 'Talaata', 'Àlarba', 'Alxames', 'Àjjuma', 'Gaawu', 'Diber',
  ];

  int get _nbJours => DateTime(_mois.year, _mois.month + 1, 0).day;
  int get _debut   => DateTime(_mois.year, _mois.month, 1).weekday - 1;

  @override
  void initState() {
    super.initState();
    _chargerHijriDuMois();
  }

  // ── Charger la date Hijri du 1er du mois via l'API ──
  Future<void> _chargerHijriDuMois() async {
    setState(() => _loadingHijri = true);
    try {
      final conv = await ApiService.convertirDate(
        DateTime(_mois.year, _mois.month, 1),
      );
      final parsed = _parseHijri(conv.dateHijri);
      setState(() {
        _hijriMois = parsed;
        _loadingHijri = false;
      });
    } catch (e) {
      setState(() => _loadingHijri = false);
    }
  }

  // ── Parser "25 Ramadan 1447" → Map {jour, moisNom, moisIndex, annee} ──
  Map<String, dynamic>? _parseHijri(String texte) {
    if (texte == '--' || texte.isEmpty) return null;
    final parts = texte.trim().split(' ');
    if (parts.length < 3) return null;
    final jour    = int.tryParse(parts[0]) ?? 1;
    final moisNom = parts[1];
    final annee   = int.tryParse(parts[2]) ?? 1447;
    final moisIndex = _moisHijriNoms.indexWhere(
      (m) => m.toLowerCase().contains(moisNom.toLowerCase()) ||
             moisNom.toLowerCase().contains(m.split(' ')[0].toLowerCase()),
    );
    return {
      'jour': jour,
      'moisNom': moisNom,
      'moisIndex': moisIndex >= 0 ? moisIndex : 0,
      'annee': annee,
    };
  }

  // ── Calculer le jour Hijri pour un jour grégorien du mois affiché ──
  String _jourHijri(int jourGregorien) {
    if (_hijriMois == null) return '?';
    final jourBase      = _hijriMois!['jour'] as int;
    final moisIndexBase = _hijriMois!['moisIndex'] as int;
    final anneeBase     = _hijriMois!['annee'] as int;

    int jourHijri   = jourBase + (jourGregorien - 1);
    int moisHijri   = moisIndexBase;
    int anneeHijri  = anneeBase;

    // Nombre de jours dans le mois Hijri (mois impairs = 30j, pairs = 29j)
    int nbJoursMois = (moisHijri % 2 == 0) ? 30 : 29;

    if (jourHijri > nbJoursMois) {
      jourHijri -= nbJoursMois;
      moisHijri++;
      if (moisHijri >= 12) {
        moisHijri = 0;
        anneeHijri++;
      }
    }
    return '$jourHijri';
  }

  // ── Nom du mois Hijri pour un jour donné (pour détecter changement de mois) ──
  String _nomMoisHijriPourJour(int jourGregorien) {
    if (_hijriMois == null) return '';
    final jourBase      = _hijriMois!['jour'] as int;
    final moisIndexBase = _hijriMois!['moisIndex'] as int;
    int jourHijri       = jourBase + (jourGregorien - 1);
    int nbJoursMois     = (moisIndexBase % 2 == 0) ? 30 : 29;
    if (jourHijri > nbJoursMois) {
      return _moisHijriNoms[(moisIndexBase + 1) % 12];
    }
    return _hijriMois!['moisNom'] as String;
  }

  // ── Titre du mois selon le mode ──
  String get _titreMois {
    switch (_mode) {
      case 'Hijri':
        if (_loadingHijri) return '...';
        if (_hijriMois == null) return _moisGregorienNoms[_mois.month - 1];
        final moisDebut = _hijriMois!['moisNom'] as String;
        final moisFin   = _nomMoisHijriPourJour(_nbJours);
        if (moisFin != moisDebut) return '$moisDebut / $moisFin';
        return moisDebut;
      case 'Wolof':
        return _moisWolofNoms[_mois.month - 1];
      default:
        return _moisGregorienNoms[_mois.month - 1];
    }
  }

  String get _anneeAffichee {
    if (_mode == 'Hijri' && _hijriMois != null) {
      return '${_hijriMois!['annee']} H';
    }
    return '${_mois.year}';
  }

  List<String> get _enteteJours =>
      _mode == 'Wolof' ? _joursWolof : _joursGregorien;

  Color get _couleurMode {
    switch (_mode) {
      case 'Hijri':  return const Color(0xFF1B5E20);
      case 'Wolof':  return Colors.orange;
      default:       return Colors.blue;
    }
  }

  // ── Sélectionner un jour ──
  Future<void> _selectionner(int jour) async {
    setState(() { _jourSel = jour; _loading = true; });
    try {
      final d = await ApiService.convertirDate(
        DateTime(_mois.year, _mois.month, jour),
      );
      setState(() { _detail = d; _loading = false; });
      _popup(jour);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _popup(int jour) {
    if (_detail == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$jour / ${_mois.month} / ${_mois.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ligne(Icons.calendar_today, Colors.blue,
                'Grégorien', _detail!.dateGregorienne),
            const Divider(),
            _ligne(Icons.nightlight_round, const Color(0xFF1B5E20),
                'Hijri', _detail!.dateHijri),
            const Divider(),
            _ligne(Icons.language, Colors.orange,
                'Wolof', _detail!.nomJourWolof),
            if (_detail!.infoWolof.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _detail!.infoWolof,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _ligne(IconData ic, Color c, String lab, String val) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(ic, color: c, size: 20),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lab, style: TextStyle(
              color: c, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(val, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );

  void _moisPrecedent() {
    setState(() {
      _mois = DateTime(_mois.year, _mois.month - 1);
      _jourSel = null;
      _hijriMois = null;
    });
    _chargerHijriDuMois();
  }

  void _moisSuivant() {
    setState(() {
      _mois = DateTime(_mois.year, _mois.month + 1);
      _jourSel = null;
      _hijriMois = null;
    });
    _chargerHijriDuMois();
  }

  // ── Cellule d'un jour ──
  Widget _buildCellule(int j) {
    final auj = j == DateTime.now().day &&
        _mois.month == DateTime.now().month &&
        _mois.year == DateTime.now().year;
    final sel = _jourSel == j;

    String texte;
    String? sousTexte;

    switch (_mode) {
      case 'Hijri':
        texte = _loadingHijri ? '·' : _jourHijri(j);
        sousTexte = null;
        break;
      case 'Wolof':
        final js = DateTime(_mois.year, _mois.month, j).weekday - 1;
        texte = '$j';
        sousTexte = _joursWolofFull[js].substring(0, 3);
        break;
      default:
        texte = '$j';
        sousTexte = null;
    }

    return GestureDetector(
      onTap: () => _selectionner(j),
      child: Container(
        decoration: BoxDecoration(
          color: auj
              ? _couleurMode
              : sel
                  ? _couleurMode.withOpacity(0.15)
                  : _mode == 'Wolof'
                      ? Colors.orange.shade50.withOpacity(0.4)
                      : _mode == 'Hijri'
                          ? const Color(0xFFE8F5E9).withOpacity(0.5)
                          : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: sel && !auj
              ? Border.all(color: _couleurMode, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              texte,
              style: TextStyle(
                color: auj ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: sousTexte != null ? 10 : 13,
              ),
            ),
            if (sousTexte != null)
              Text(
                sousTexte,
                style: TextStyle(
                  color: auj ? Colors.white70 : _couleurMode.withOpacity(0.8),
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Sélecteur de mode ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Gregorien',
                  label: Text('Grégorien', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 'Hijri',
                  label: Text('Hijri', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: 'Wolof',
                  label: Text('Wolof', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {_mode},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return _couleurMode;
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return null;
                }),
              ),
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _jourSel = null;
              }),
            ),
          ),

          // ── Bandeau Hijri ──
          if (_mode == 'Hijri')
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF1B5E20).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _loadingHijri
                        ? const Text('Chargement du calendrier Hijri...',
                            style: TextStyle(
                                color: Color(0xFF1B5E20), fontSize: 12))
                        : Text(
                            _hijriMois != null
                                ? 'Mois de ${_hijriMois!['moisNom']} ${_hijriMois!['annee']} H'
                                : 'Calendrier lunaire islamique',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  if (_loadingHijri)
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF1B5E20)),
                    ),
                ],
              ),
            ),

          // ── Bandeau Wolof ──
          if (_mode == 'Wolof')
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Noms des jours en Wolof • Appuyez pour les 3 correspondances',
                      style: TextStyle(
                          color: Colors.orange.shade800, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

          // ── Navigation mois ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _moisPrecedent),
              Column(children: [
                Text(
                  _titreMois,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _couleurMode,
                  ),
                ),
                Text(
                  _anneeAffichee,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ]),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _moisSuivant),
            ],
          ),

          // ── En-tête jours ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(7, (i) {
                final isDim = i == 6;
                final couleur = _mode == 'Wolof'
                    ? (isDim ? Colors.orange.shade800 : Colors.orange.shade600)
                    : (isDim ? Colors.red : Colors.grey[700]);
                return Expanded(
                  child: Center(
                    child: Text(
                      _enteteJours[i],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: couleur,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),

          // ── Grille des jours ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: _debut + _nbJours,
                    itemBuilder: (_, i) {
                      if (i < _debut) return const SizedBox();
                      return _buildCellule(i - _debut + 1);
                    },
                  ),
          ),

          // ── Légende Wolof ──
          if (_mode == 'Wolof')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: _joursWolofFull
                    .map((j) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(j,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              )),
                        ))
                    .toList(),
              ),
            ),

          // ── Hint ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              _mode == 'Hijri'
                  ? '🌙 Jours Hijri via API • Appuyez sur un jour pour les détails'
                  : _mode == 'Wolof'
                      ? 'Noms des jours en Wolof • Appuyez pour les 3 correspondances'
                      : 'Appuyez sur un jour pour voir les 3 correspondances',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}