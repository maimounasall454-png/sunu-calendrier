// frontend/lib/screens/evenements_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/evenement.dart';
 
class EvenementsScreen extends StatefulWidget {
  const EvenementsScreen({super.key});
  @override State<EvenementsScreen> createState() => _EvenementsScreenState();
}
class _EvenementsScreenState extends State<EvenementsScreen> {
  List<Evenement> _evts = []; bool _loading = true;
  @override void initState() { super.initState(); _charger(); }
 
  Future<void> _charger() async {
    setState(() => _loading = true);
    try { final d = await ApiService.getEvenements(); setState(() { _evts = d; _loading = false; }); }
    catch (e) { setState(() => _loading = false); }
  }
 
  Color _couleur(String t) {
    switch(t) { case 'islamique': return const Color(0xFF1B5E20);
      case 'wolof': return Colors.orange; case 'national': return Colors.blue;
      default: return Colors.grey; }
  }
 
  Future<void> _ajouter() async {
    final tCtrl = TextEditingController();
    final dCtrl = TextEditingController();
    DateTime dateChoisie = DateTime.now();
    String type = 'personnel';
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setL) => AlertDialog(
        title: const Text('Nouvel événement'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: tCtrl,
            decoration: const InputDecoration(labelText:'Titre *', border: OutlineInputBorder())),
          const SizedBox(height:10),
          TextField(controller: dCtrl, maxLines:2,
            decoration: const InputDecoration(labelText:'Description', border: OutlineInputBorder())),
          const SizedBox(height:10),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text('${dateChoisie.day}/${dateChoisie.month}/${dateChoisie.year}'),
            subtitle: const Text('Date de l\'événement'),
            onTap: () async {
              final d = await showDatePicker(context: ctx,
                initialDate: dateChoisie, firstDate: DateTime(2000), lastDate: DateTime(2050));
              if (d != null) setL(() => dateChoisie = d);
            }),
          DropdownButtonFormField<String>(value: type,
            decoration: const InputDecoration(labelText:'Type'),
            onChanged: (v) => setL(() => type = v!),
            items: const [
              DropdownMenuItem(value:'islamique', child:Text('Islamique')),
              DropdownMenuItem(value:'wolof',     child:Text('Wolof')),
              DropdownMenuItem(value:'personnel', child:Text('Personnel')),
              DropdownMenuItem(value:'national',  child:Text('National')),
            ]),
        ])),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(onPressed: () async {
            if (tCtrl.text.trim().isEmpty) return;
            final ok = await ApiService.creerEvenement(Evenement(titre: tCtrl.text.trim(), description: dCtrl.text.trim(), date: '${dateChoisie.year}-${dateChoisie.month.toString().padLeft(2,'0')}-${dateChoisie.day.toString().padLeft(2,'0')}', typeEvent: type));
            if (ok) { Navigator.pop(ctx); _charger(); }
          }, child: const Text('Créer')),
        ])));
  }
 
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Événements'),
      backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _ajouter, icon: const Icon(Icons.add), label: const Text('Ajouter'),
      backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _evts.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.event_busy, size:64, color:Colors.grey),
            SizedBox(height:12),
            Text('Aucun événement', style: TextStyle(color:Colors.grey, fontSize:16)),
            Text('Appuyez sur + pour en créer un', style: TextStyle(color:Colors.grey, fontSize:12)),
          ]))
        : RefreshIndicator(onRefresh: _charger, child: ListView.builder(
            itemCount: _evts.length,
            itemBuilder: (_, i) {
              final e = _evts[i]; final c = _couleur(e.typeEvent);
              return Card(margin: const EdgeInsets.symmetric(horizontal:12, vertical:4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: c.withOpacity(0.1),
                    child: Icon(Icons.event, color:c, size:20)),
                  title: Text(e.titre, style: const TextStyle(fontWeight:FontWeight.bold)),
                  subtitle: Text('${e.date} — ${e.typeEvent}'),
                  trailing: e.id != null ? IconButton(
                    icon: const Icon(Icons.delete_outline, color:Colors.red),
                    onPressed: () async { await ApiService.supprimerEvenement(e.id!); _charger(); }) : null,
                ));
            })),
  );
}

