import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import '../utils/local_storage.dart';
import '../widgets/mode_bottom_sheet.dart';
import '../widgets/session_bottom_sheet.dart';
import '../widgets/timeframe_bottom_sheet.dart';

const List<String> PAIRS = [
  "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "AUDJPY", 
  "CADJPY", "EURJPY", "BTCUSD", "USDCAD", "GBPJPY", "ADAUSD", 
  "BRENT", "XAUUSD", "XAGUSD", "ETHUSD", "DowJones30", "Nasdaq100"
];

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _api = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> _timeframes = {};
  Map<String, bool> _modes = {};
  Map<String, bool> _sessions = {};

  List<dynamic> _alerts = [];
  bool _loadingAlerts = true;
  Timer? _alertsTimer;
  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadLocalThenServerSettings();
    _startAlertsPolling();
  }

  @override
  void dispose() {
    _alertsTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalThenServerSettings() async {
    try {
      final local = await LocalStorage.loadSettings(widget.userId);
      setState(() {
        _timeframes = Map<String, dynamic>.from(local['timeframes'] ?? {});
        _modes = Map<String, bool>.from((local['modes'] ?? {}).map((k, v) => MapEntry(k as String, v == true)));
        _sessions = Map<String, bool>.from((local['sessions'] ?? {}).map((k, v) => MapEntry(k as String, v == true)));
      });

      final server = await _api.getSettings(widget.userId);
      if (mounted) {
        setState(() {
          _timeframes = Map<String, dynamic>.from(server['timeframes'] ?? _timeframes);
          _modes = Map<String, bool>.from((server['modes'] ?? _modes).map((k, v) => MapEntry(k as String, v == true)));
          _sessions = Map<String, bool>.from((server['sessions'] ?? _sessions).map((k, v) => MapEntry(k as String, v == true)));
          _loadingSettings = false;
        });
      }
      await LocalStorage.saveSettings(widget.userId, {
        'timeframes': _timeframes,
        'modes': _modes,
        'sessions': _sessions,
      });
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) setState(() => _loadingSettings = false);
    }
  }

  Future<void> _saveSettings() async {
    final payload = {
      'timeframes': _timeframes,
      'modes': _modes,
      'sessions': _sessions,
    };
    await LocalStorage.saveSettings(widget.userId, payload);

    try {
      await _api.saveSettings(widget.userId, payload);
      Fluttertoast.showToast(msg: 'تنظیمات ذخیره شد');
    } catch (e) {
      print('Save to server failed: $e');
      Fluttertoast.showToast(msg: 'ذخیره در سرور نشد (آفلاین)');
    }
    if (mounted) setState(() {});
  }

  Future<void> _startAlertsPolling() async {
    await _loadAlerts();
    _alertsTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (mounted) await _loadAlerts();
    });
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await _api.getAlerts(widget.userId);
      if (mounted) {
        setState(() {
          _alerts = alerts;
          _loadingAlerts = false;
        });
      }
    } catch (e) {
      print('Error loading alerts: $e');
      if (mounted) setState(() => _loadingAlerts = false);
    }
  }

  Color _buttonColorActive(bool active) {
    return active ? Colors.green.shade600 : Colors.white;
  }

  Color _buttonTextColor(bool active) {
    return active ? Colors.white : Colors.black;
  }

  // 🔥 اصلاح شده - بدون mounted check
  void _openModesSheet() {
    print("🚀 دکمه مود فشرده شده است!");
    showModalBottomSheet(
      context: _scaffoldKey.currentContext!,
      isScrollControlled: true,
      builder: (_) {
        return ModeBottomSheet(
          initial: _modes,
          onSave: (result) async {
            setState(() => _modes = result);
            await _saveSettings();
          },
        );
      },
    );
  }

  // 🔥 اصلاح شده - بدون mounted check
  void _openSessionsSheet() {
    print("🚀 دکمه سشن فشرده شده است!");
    showModalBottomSheet(
      context: _scaffoldKey.currentContext!,
      isScrollControlled: true,
      builder: (_) {
        return SessionBottomSheet(
          initial: _sessions,
          onSave: (result) async {
            setState(() => _sessions = result);
            await _saveSettings();
          },
        );
      },
    );
  }

  // 🔥 اصلاح شده - بدون mounted check
  void _openTimeframeForPair(String pair) {
    print("🚀 دکمه $pair فشرده شده است!");
    final initialPair = Map<String, dynamic>.from(_timeframes[pair] ?? {'signal': 'BUYSELL'});
    
    showModalBottomSheet(
      context: _scaffoldKey.currentContext!,
      isScrollControlled: true,
      builder: (_) {
        return TimeframeBottomSheet(
          initialPairData: initialPair,
          onSave: (pairData) async {
            setState(() => _timeframes[pair] = pairData);
            await _saveSettings();
          },
        );
      },
    );
  }

  Widget _buildTopArea(BoxConstraints constraints) {
    final topHeight = constraints.maxHeight * 0.5;
    return SizedBox(
      height: topHeight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // دکمه‌های مود و سشن
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openModesSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColorActive(_modes.values.any((v) => v)),
                      foregroundColor: _buttonTextColor(_modes.values.any((v) => v)),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('مود', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openSessionsSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColorActive(_sessions.values.any((v) => v)),
                      foregroundColor: _buttonTextColor(_sessions.values.any((v) => v)),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('سشن', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('جفت ارزها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: PAIRS.length,
                itemBuilder: (context, index) {
                  final pair = PAIRS[index];
                  final active = (_timeframes[pair] ?? {}).values.any((v) => v == true);
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: active ? Colors.green.shade600 : Colors.white,
                      foregroundColor: active ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _openTimeframeForPair(pair),
                    child: Text(pair, 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
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
      key: _scaffoldKey, // 🔥 اضافه شده
      appBar: AppBar(
        title: const Text("تنظیمات"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLocalThenServerSettings,
          ),
        ],
      ),
      body: _loadingSettings 
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTopArea(constraints),
                      // نمایش آلرت‌ها
                      _buildAlertsSection(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('آلرت‌های فعال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _loadingAlerts 
              ? Center(child: CircularProgressIndicator())
              : _alerts.isEmpty
                  ? Text('هیچ آلرتی یافت نشد')
                  : Column(
                      children: _alerts.map((alert) => Card(
                        child: ListTile(
                          title: Text(alert['pair'] ?? 'Unknown'),
                          subtitle: Text(alert['signal'] ?? 'Unknown'),
                          trailing: Text(alert['timeframe'] ?? ''),
                        ),
                      )).toList(),
                    ),
        ],
      ),
    );
  }
}
