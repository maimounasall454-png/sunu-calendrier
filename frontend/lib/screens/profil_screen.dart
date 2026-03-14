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
            content: Text('Identifiants incorrects', style: TextStyle(color: Colors.white),),
            backgroundColor: Color(0xFF1B5E20),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mon Profil'),
      backgroundColor: Color(0xFF1B5E20),
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: _connecte ? _profil() : _connexionForm(),
    ),
  );

  Widget _profil() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircleAvatar(
        radius: 48,
        backgroundColor: Color(0xFFFFEBEE),
        child: Icon(Icons.person, size: 48, color: Color(0xFF1B5E20)),
      ),
      const SizedBox(height: 16),
      Text(
        _username,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const Text('Connecté', style: TextStyle(color: Color(0xFF1B5E20))),
      const SizedBox(height: 40),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Se déconnecter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
          ),
          onPressed: () async {
            await ApiService.deconnexion();
            _verifier();
          },
        ),
      ),
    ],
  );

  Widget _connexionForm() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.lock_outline, size: 64, color: Color(0xFF1B5E20)),
      const SizedBox(height: 16),
      const Text(
        'Connexion',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 28),
      TextField(
        controller: _uCtrl,
        decoration: const InputDecoration(
          labelText: 'Nom d\'utilisateur',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _pCtrl,
        obscureText: !_showPass,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: const Icon(Icons.lock),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPass = !_showPass),
          ),
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _connexion,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF33691E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
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
      const SizedBox(height: 12),
      const Text(
        'Utilisez le compte créé par M1 (admin / admin123)',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ],
  );
}
