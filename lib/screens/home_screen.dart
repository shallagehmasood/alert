import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/signal_provider.dart';
import '../widgets/signal_popup.dart';
import '../models/signal_model.dart'; // ← این خط رو اضافه کن
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

  void _showSignalNotification(Signal signal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              signal.signalType == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'سیگنال جدید: ${signal.pair}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${signal.timeframe} - ${signal.displaySignalType}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: signal.signalType == 'BUY' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'مشاهده',
          textColor: Colors.white,
          onPressed: () {
            _showSignalPopup(signal);
          },
        ),
      ),
    );
  }

  void _showSignalPopup(Signal signal) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SignalPopup(
        signal: signal,
        onClose: () {
          Navigator.of(context).pop();
          context.read<SignalProvider>().clearLatestSignal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final signalProvider = Provider.of<SignalProvider>(context);

    if (signalProvider.latestSignal != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSignalNotification(signalProvider.latestSignal!);
      });
    }

    if (settingsProvider.userId == null || settingsProvider.userSettings == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('First Hidden Bot'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (signalProvider.latestSignal != null)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            icon: Icon(Icons.photo_library),
            label: 'گالری تصاویر',
          ),
        ],
      ),
    );
  }
}
