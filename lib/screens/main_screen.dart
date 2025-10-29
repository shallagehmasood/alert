// lib/screens/main_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

const List<String> PAIRS = [
  "EURUSD","GBPUSD","USDJPY","USDCHF",
  "AUDUSD","AUDJPY","CADJPY","EURJPY","BTCUSD",
  "USDCAD","GBPJPY","ADAUSD","BRENT","XAUUSD","XAGUSD",
  "ETHUSD","DowJones30","Nasdaq100"
];

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _timeframes = {};
  Map<String, bool> _modes = {};
  Map<String, bool> _sessions = {};
  List<Map<String, dynamic>> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    // Refresh Alerts هر 5 ثانیه
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _loadAlerts();
    });
  }

  Future<void> _loadAllData() async {
    final settings = await _api.getSettings(widget.userId);
    setState(() {
      _timeframes = Map<String, dynamic>.from(settings['timeframes'] ?? {});
      _modes = Map<String, bool>.from(settings['modes'] ?? {});
      _sessions = Map<String, bool>.from(settings['sessions'] ?? {});
      _loading = false;
    });
    await _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alerts = await _api.getAlerts(widget.userId);
    if (mounted) {
      setState(() => _alerts = alerts);
    }
  }

  Future<void> _saveSettings() async {
    await _api.saveSettings(widget.userId, {
      'timeframes': _timeframes,
      'modes': _modes,
      'sessions': _sessions,
    });
  }

  void _showBottomSheet(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildModeSessionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton("مود", _modes, (key, value) {
          setState(() => _modes[key] = value);
          _saveSettings();
        }),
        _buildActionButton("سشن", _sessions, (key, value) {
          setState(() => _sessions[key] = value);
          _saveSettings();
        }),
      ],
    );
  }

  Widget _buildActionButton(String title, Map<String, bool> map, Function(String, bool) onChanged) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
      onPressed: () {
        _showBottomSheet(title, Wrap(
          spacing: 8,
          children: map.keys.map((key) {
            final selected = map[key] ?? false;
            return FilterChip(
              label: Text(key),
              selected: selected,
              onSelected: (val) => onChanged(key, val),
              selectedColor: Colors.green,
            );
          }).toList(),
        ));
      },
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildPairCard(String pair) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(pair, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton("مود", _modes, (key, val) {
                  setState(() => _modes[key] = val);
                  _saveSettings();
                }),
                const SizedBox(width: 8),
                _buildActionButton("سشن", _sessions, (key, val) {
                  setState(() => _sessions[key] = val);
                  _saveSettings();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("Alert_X")),
        body: Column(
          children: [
            // نیمه بالا: جفت ارزها و دکمه‌ها
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildModeSessionButtons(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: PAIRS.length,
                        itemBuilder: (_, index) => _buildPairCard(PAIRS[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 2),
            // نیمه پایین: Alerts
            Expanded(
              flex: 1,
              child: _alerts.isEmpty
                  ? const Center(child: Text("سیگنالی دریافت نشده است"))
                  : ListView.builder(
                      itemCount: _alerts.length,
                      itemBuilder: (_, index) {
                        final alert = _alerts[index];
                        return Card(
                          margin: const EdgeInsets.all(6),
                          child: Column(
                            children: [
                              Image.network(
                                _api.getImageUrl(alert['filename']),
                                errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                loadingBuilder: (_, child, progress) =>
                                    progress == null ? child : const CircularProgressIndicator(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SelectableText(
                                  alert['caption'] ?? "",
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ],
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
}
