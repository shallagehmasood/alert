
### lib/screens/pair_settings_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

const List<String> TIMEFRAMES = [
  "M1",
  "M2",
  "M3",
  "M4",
  "M5",
  "M6",
  "M10",
  "M12",
  "M15",
  "M20",
  "M30",
  "H1",
  "H2",
  "H3",
  "H4",
  "H6",
  "H8",
  "H12",
  "D1",
  "W1"
];

class PairSettingsScreen extends StatefulWidget {
  final String userId;
  final String pair;
  final Future<void> Function(Map<String, dynamic> timeframes, String signal)? onSave;
  const PairSettingsScreen({super.key, required this.userId, required this.pair, this.onSave});

  @override
  _PairSettingsScreenState createState() => _PairSettingsScreenState();
}

class _PairSettingsScreenState extends State<PairSettingsScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic> _pairData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPairData();
  }

  Future<void> _loadPairData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'settings_${widget.userId}';
      final saved = prefs.getString(key);
      if (saved != null) {
        final map = jsonDecode(saved) as Map<String, dynamic>;
        final timeframes = Map<String, dynamic>.from(map['timeframes'] ?? {});
        _pairData = Map<String, dynamic>.from(timeframes[widget.pair] ?? {'signal': 'BUYSELL'});
      }

      // also try server
      final data = await _api.getSettings(widget.userId);
      final timeframesServer = Map<String, dynamic>.from(data['timeframes'] ?? {});
      _pairData = Map<String, dynamic>.from(timeframesServer[widget.pair] ?? _pairData);

      setState(() => _loading = false);
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطا در بارگذاری تنظیمات');
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleTimeframe(String tf) async {
    _pairData[tf] = !(_pairData[tf] ?? false);
    await _save();
  }

  Future<void> _setSignal(String signal) async {
    _pairData['signal'] = signal;
    await _save();
  }

  Future<void> _save() async {
    try {
      final fullData = await _api.getSettings(widget.userId);
      final timeframes = Map<String, dynamic>.from(fullData['timeframes'] ?? {});
      timeframes[widget.pair] = _pairData;

      final payload = {
        'timeframes': timeframes,
        'modes': fullData['modes'] ?? {},
        'sessions': fullData['sessions'] ?? {},
      };

      // save to server
      try {
        await _api.saveSettings(widget.userId, payload);
        Fluttertoast.showToast(msg: 'ذخیره شد');
      } catch (e) {
        Fluttertoast.showToast(msg: 'ذخیره در سرور نشد');
      }

      // save locally
      final prefs = await SharedPreferences.getInstance();
      final key = 'settings_${widget.userId}';
      final saved = prefs.getString(key);
      Map<String, dynamic> root = {};
      if (saved != null) {
        try {
          root = jsonDecode(saved) as Map<String, dynamic>;
        } catch (_) {}
      }
      root['timeframes'] = timeframes;
      await prefs.setString(key, jsonEncode(root));

      if (widget.onSave != null) await widget.onSave!(timeframes, _pairData['signal'] ?? 'BUYSELL');
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطا در ذخیره');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('تنظیمات ${widget.pair}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var tf in TIMEFRAMES)
                    FilterChip(
                      label: Text(tf),
                      selected: _pairData[tf] == true,
                      onSelected: (_) => _toggleTimeframe(tf),
                      selectedColor: Colors.blue,
                      checkmarkColor: Colors.white,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('نوع سیگنال:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  _buildSignalChip('BUY', _pairData['signal'] == 'BUY'),
                  _buildSignalChip('SELL', _pairData['signal'] == 'SELL'),
                  _buildSignalChip('BUYSELL', _pairData['signal'] == 'BUYSELL'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _setSignal(label),
      selectedColor: Colors.green,
      checkmarkColor: Colors.white,
    );
  }
}
