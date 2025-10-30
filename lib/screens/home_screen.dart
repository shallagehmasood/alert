import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/signal_provider.dart';
import 'login_screen.dart';
import 'signals_screen.dart';
import '../widgets/main_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainMenu(),
    const SignalsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final settingsProvider = context.read<SettingsProvider>();
    final signalProvider = context.read<SignalProvider>();
    
    if (settingsProvider.userId != null) {
      signalProvider.connect(settingsProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (settingsProvider.userId == null || settingsProvider.userSettings == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Hidden Bot'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final signalProvider = context.read<SignalProvider>();
              signalProvider.disconnect();
              settingsProvider.logout();
            },
            tooltip: 'خروج',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'منوی اصلی',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'سیگنال‌ها',
          ),
        ],
      ),
    );
  }
}
