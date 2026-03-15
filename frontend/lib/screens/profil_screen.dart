// frontend/lib/screens/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _connecte = false;
  String _username = '';
  bool _loading = false;
  final _uCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    _verifier();
  }

  Future<void> _verifier() async {
    final ok = await ApiService.estConnecte();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _connecte = ok;
      _username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _connexion() async {
    if (_uCtrl.text.isEmpty || _pCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    final ok = await ApiService.connexion(_uCtrl.text, _pCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      _verifier();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Identifiants incorrects',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mon Profil'),
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: _connecte ? _profil() : _connexionForm(),
    ),
  );

  // ── Page profil connecté ──
  Widget _profil() {
    final initiale = _username.isNotEmpty
        ? _username[0].toUpperCase()
        : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar avec initiale
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF33691E), Color(0xFF1B5E20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initiale,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Nom d'utilisateur
        Text(
          _username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        // Statut connecté
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF33691E)),
              SizedBox(width: 6),
              Text(
                'Connecté',
                style: TextStyle(
                  color: Color(0xFF33691E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Carte infos
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoTile(
                  Icons.person_outline,
                  'Nom d\'utilisateur',
                  _username,
                ),
                const Divider(height: 24),
                _infoTile(
                  Icons.shield_outlined,
                  'Rôle',
                  'Administrateur',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Bouton déconnexion
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () async {
              await ApiService.deconnexion();
              _verifier();
            },
          ),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String valeur) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF33691E), size: 20),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          Text(valeur, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    ],
  );

  // ── Formulaire de connexion ──
  Widget _connexionForm() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Icône + titre
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE8F5E9),
        ),
        child: const Icon(
          Icons.lock_outline,
          size: 48,
          color: Color(0xFF1B5E20),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Connexion',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Connectez-vous pour accéder à votre profil',
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),

      // Champ utilisateur
      TextField(
        controller: _uCtrl,
        decoration: InputDecoration(
          labelText: 'Nom d\'utilisateur',
          prefixIcon: const Icon(Icons.person_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 14),

      // Champ mot de passe
      TextField(
        controller: _pCtrl,
        obscureText: !_showPass,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: const Icon(Icons.lock_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _showPass ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _showPass = !_showPass),
          ),
        ),
      ),
      const SizedBox(height: 24),

      // Bouton connexion
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _connexion,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF33691E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Se connecter', style: TextStyle(fontSize: 16)),
        ),
      ),
      // ── SUPPRIMÉ : hint "admin / admin123" ──
    ],
  );
}