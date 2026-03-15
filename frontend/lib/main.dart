import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunu_calendrier/screens/calendrier_screen.dart';
import 'screens/accueil_screen.dart';
import 'screens/conversion_screen.dart';
import 'screens/evenements_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/prieres_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  runApp(SunuCalendrierApp(isDarkMode: isDark));
}

class SunuCalendrierApp extends StatefulWidget {
  final bool isDarkMode;
  const SunuCalendrierApp({super.key, required this.isDarkMode});

  static _SunuCalendrierAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SunuCalendrierAppState>();

  @override
  State<SunuCalendrierApp> createState() => _SunuCalendrierAppState();
}

class _SunuCalendrierAppState extends State<SunuCalendrierApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleDarkMode() async {
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('dark_mode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunu Calendrier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // ── Routes ──────────────────────────────────
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/main':   (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

    // AJOUTER dans _MainScreenState
  static _MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScreenState>(); 

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void allerVers(int index) => setState(() => _currentIndex = index);

  final List<Widget> _screens = [
    const AccueilScreen(),
    const PrieresScreen(),
    const CalendrierScreen(),
    const ConversionScreen(),
    const EvenementsScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home),           label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.mosque), label: 'Prières'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendrier'),
          NavigationDestination(icon: Icon(Icons.swap_horiz),     label: 'Convertir'),
          NavigationDestination(icon: Icon(Icons.event),          label: 'Événement'),
          NavigationDestination(icon: Icon(Icons.person),         label: 'Profil'),
        ],
      ),
    );
  }
}