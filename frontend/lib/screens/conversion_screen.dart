
// frontend/lib/screens/conversion_screen.dart 

import 'package:flutter/material.dart'; 

import '../services/api_service.dart'; 

import '../models/date_conversion.dart'; 

  

class ConversionScreen extends StatefulWidget { 

  const ConversionScreen({super.key}); 

  @override State<ConversionScreen> createState() => _ConversionScreenState(); 

} 

class _ConversionScreenState extends State<ConversionScreen> { 

  DateTime _date = DateTime.now(); 

  DateConversion? _res; 

  bool _loading = false; 

  String? _erreur; 

  

  @override void initState() { super.initState(); _convertir(_date); } 

  

  Future<void> _convertir(DateTime date) async { 

    setState(() { _loading = true; _erreur = null; }); 

    try { 

      final r = await ApiService.convertirDate(date); 

      setState(() { _res = r; _loading = false; }); 

    } catch (e) { 

      setState(() { _erreur = 'Vérifiez que M6 a lancé le serveur Django.'; _loading = false; }); 

    } 

  } 

  

  Future<void> _choisir() async { 

    final d = await showDatePicker(context: context, initialDate: _date, 

      firstDate: DateTime(1900), lastDate: DateTime(2100), helpText: 'Choisissez une date'); 

    if (d != null) { setState(() => _date = d); _convertir(d); } 


  } 

  

  @override 

  Widget build(BuildContext context) => Scaffold( 

    appBar: AppBar(title: const Text('Conversion de Dates'), 

      backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white), 

    body: Padding(padding: const EdgeInsets.all(16), 

      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ 

        Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [ 

          Row(children: [ 

            const Icon(Icons.calendar_today, color: Color(0xFF4A148C)), 

            const SizedBox(width: 12), 

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ 

              const Text('Date sélectionnée', style: TextStyle(color: Colors.grey, fontSize: 12)), 

              Text('${_date.day.toString().padLeft(2,'0')} / ${_date.month.toString().padLeft(2,'0')} / ${_date.year}', 

                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), 

            ]), 

          ]), 

          const SizedBox(height: 12), 

          SizedBox(width: double.infinity, child: ElevatedButton.icon( 

            onPressed: _choisir, 

            icon: const Icon(Icons.edit_calendar), 

            label: const Text('Changer la date'), 

            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white), 

          )), 

        ]))), 

        const SizedBox(height: 20), 

        if (_loading) const Center(child: Column(children: [ 

          SizedBox(height:30), CircularProgressIndicator(), SizedBox(height:12), 

          Text('Conversion en cours...', style: TextStyle(color: Colors.grey))])) 

        else if (_erreur != null) Card(color: Colors.red[50], child: Padding( 

          padding: const EdgeInsets.all(16), child: Row(children: [ 

            const Icon(Icons.error, color: Colors.red), 

            const SizedBox(width: 12), 

            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ 

              Text(_erreur!, style: const TextStyle(color: Colors.red)), 

              ElevatedButton(onPressed: () => _convertir(_date), child: const Text('Réessayer')), 

            ])), 

          ]))) 

        else if (_res != null) ...[ 

          const Text('Résultats', style: TextStyle(fontSize:16, fontWeight:FontWeight.bold, color:Colors.grey)), 

          const SizedBox(height:12), 

          _carte('Grégorien', _res!.dateGregorienne, Icons.calendar_today, Colors.blue, 'Calendrier international'), 


          _carte('Islamique (Hijri)', _res!.dateHijri, Icons.nightlight_round, const Color(0xFF1B5E20), 'Calendrier lunaire'), 

          _carte('Wolof', _res!.nomJourWolof, Icons.language, Colors.deepOrange, _res!.infoWolof), 

        ], 

      ]), 

    ), 

  ); 

  

  Widget _carte(String titre, String val, IconData ic, Color c, String desc) => 

    Card(margin: const EdgeInsets.only(bottom:12), elevation:2, 

      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [ 

        CircleAvatar(radius:24, backgroundColor: c.withOpacity(0.12), child: Icon(ic, color:c, size:22)), 

        const SizedBox(width:14), 

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ 

          Text(titre, style: TextStyle(color:c, fontWeight:FontWeight.bold, fontSize:11)), 

          Text(val, style: const TextStyle(fontSize:18, fontWeight:FontWeight.w700)), 

          if (desc.isNotEmpty) Text(desc, style: TextStyle(color:Colors.grey[500], fontSize:11)), 

        ])), 

      ]))); 

} 

