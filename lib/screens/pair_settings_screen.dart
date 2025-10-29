import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/local_storage.dart';

const List<String> TIMEFRAMES = [
  "M1", "M2", "M3", "M4", "M5", "M6",
  "M10", "M12", "M15", "M20", "M30", "H1",
  "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1"
];

class PairSettingsScreen extends StatefulWidget {
  final String userId;
  final String pair;
  final Future<void> Function(Map<String, dynamic> timeframes, String signal)? onSave;

  const PairSettingsScreen({super.key, required this.userId, required this.pair, this.onSave});

  @override
  State<PairSettingsScreen> createState() => _PairSettingsScreenState();
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
      final local = await LocalStorage.loadSettings(widget.userId);
      _pairData = Map<String, dynamic>.from(local['timeframes'] ?? {});
      _pairData = Map<String, dynamic>.from(_pairData[widget.pair] ?? {'signal': 'BUYSELL'});

      final server = await _api.getSettings(widget.userId);
      final serverTfs = Map<String, dynamic>.from(server['timeframes'] ?? {});
      _pairData = Map<String, dynamic>.from(serverTfs[widget.pair] ?? _pairData);

      setState(() => _loading = false);
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطا در بارگذاری تنظیمات');
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      final full = await _api.getSettings(widget.userId);
      final timeframes = Map<String, dynamic>.from(full['timeframes'] ?? {});
      timeframes[widget.pair] = _pairData;

      final payload = {
        'timeframes': timeframes,
        'modes': full['modes'] ?? {},
        'sessions': full['sessions'] ?? {},
      };

      // try server
      try {
        await _api.saveSettings(widget.userId, payload);
        Fluttertoast.showToast(msg: 'ذخیره شد');
      } catch (_) {
        Fluttertoast.showToast(msg: 'ذخیره در سرور نشد');
      }

      // save locally (merge)
      final root = {
        'timeframes': timeframes,
        'modes': full['modes'] ?? {},
        'sessions': full['sessions'] ?? {},
      };
      await LocalStorage.saveSettings(widget.userId, root);

      if (widget.onSave != null) await widget.onSave!(timeframes, _pairData['signal'] ?? 'BUYSELL');
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطا در ذخیره');
    }
  }

  Future<void> _toggleTf(String tf) async {
    setState(() {
      _pairData[tf] = !(_pairData[tf] == true);
    });
    await _save();
  }

  Future<void> _setSignal(String s) async {
    setState(() {
      _pairData['signal'] = s;
    });
    await _save();
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
                      onSelected: (_) => _toggleTf(tf),
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
                  ChoiceChip(label: const Text('BUY'), selected: _pairData['signal'] == 'BUY', onSelected: (_) => _setSignal('BUY')),
                  ChoiceChip(label: const Text('SELL'), selected: _pairData['signal'] == 'SELL', onSelected: (_) => _setSignal('SELL')),
                  ChoiceChip(label: const Text('BUYSELL'), selected: _pairData['signal'] == 'BUYSELL', onSelected: (_) => _setSignal('BUYSELL')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
