import 'package:flutter/material.dart';
import 'screens/accueil_screen.dart';

void main() {
  runApp(const SunucladrierApp());
}

class SunucladrierApp extends StatelessWidget {
  const SunucladrierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunu calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0553B1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0553B1),
          foregroundColor: Colors.white,
        ),
      ),

      home: const AccueilScreen(),
    );
  }
}
