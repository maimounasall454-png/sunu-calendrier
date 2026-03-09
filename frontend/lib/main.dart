// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/accueil_screen.dart';
import 'screens/calendrier_screen.dart';
import 'screens/conversion_screen.dart';
import 'screens/evenements_screen.dart';
import 'screens/profil_screen.dart';
 
void main() => runApp(const SunuCalendrierApp());
 
class SunuCalendrierApp extends StatelessWidget {
  const SunuCalendrierApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sunu_Calendrier',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0553B1)),
      useMaterial3: true,
    ),
    home: const MainNavigation(),
  );
}
 
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
 
class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  final _screens = const [
    AccueilScreen(),
    CalendrierScreen(),
    ConversionScreen(),
    EvenementsScreen(),
    ProfilScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_idx],
    bottomNavigationBar: NavigationBar(
      selectedIndex: _idx,
      onDestinationSelected: (i) => setState(() => _idx = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home),           label: 'Accueil'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendrier'),
        NavigationDestination(icon: Icon(Icons.swap_horiz),     label: 'Convertir'),
        NavigationDestination(icon: Icon(Icons.event),          label: 'Evenements'),
        NavigationDestination(icon: Icon(Icons.person),         label: 'Profil'),
      ],
    ),
  );
}

