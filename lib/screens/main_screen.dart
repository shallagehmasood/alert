import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/api_service.dart';
import '../utils/local_storage.dart';
import '../widgets/mode_bottom_sheet.dart';
import '../widgets/session_bottom_sheet.dart';
import '../widgets/timeframe_bottom_sheet.dart';
import 'pair_settings_screen.dart';

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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _api = ApiService();

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
    final local = await LocalStorage.loadSettings(widget.userId);
    setState(() {
      _timeframes = Map<String, dynamic>.from(local['timeframes'] ?? {});
      _modes = Map<String, bool>.from((local['modes'] ?? {}).map((k, v) => MapEntry(k as String, v == true)));
      _sessions = Map<String, bool>.from((local['sessions'] ?? {}).map((k, v) => MapEntry(k as String, v == true)));
    });

    try {
      final server = await _api.getSettings(widget.userId);
      setState(() {
        _timeframes = Map<String, dynamic>.from(server['timeframes'] ?? _timeframes);
        _modes = Map<String, bool>.from((server['modes'] ?? _modes).map((k, v) => MapEntry(k as String, v == true)));
        _sessions = Map<String, bool>.from((server['sessions'] ?? _sessions).map((k, v) => MapEntry(k as String, v == true)));
        _loadingSettings = false;
      });
      await LocalStorage.saveSettings(widget.userId, {
        'timeframes': _timeframes,
        'modes': _modes,
        'sessions': _sessions,
      });
    } catch (_) {
      setState(() => _loadingSettings = false);
    }
  }

  Future<void> _saveSettings() async {
    final payload = {
      'timeframes': _timeframes,
      'modes': _modes,
      'sessions': _sessions,
    };
    // save local
    await LocalStorage.saveSettings(widget.userId, payload);

    // try server
    try {
      await _api.saveSettings(widget.userId, payload);
      Fluttertoast.showToast(msg: 'تنظیمات ذخیره شد');
    } catch (_) {
      Fluttertoast.showToast(msg: 'ذخیره در سرور نشد (آفلاین?)');
    }
    setState(() {});
  }

  Future<void> _startAlertsPolling() async {
    await _loadAlerts();
    _alertsTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _loadAlerts();
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
    } catch (_) {
      if (mounted) setState(() => _loadingAlerts = false);
    }
  }

  Color _buttonColorActive(bool active) {
    return active ? Colors.green.shade600 : Colors.white;
  }

  Color _buttonTextColor(bool active) {
    return active ? Colors.white : Colors.black;
  }

  // Open mode sheet (widget)
  void _openModesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ModeBottomSheet(
          initial: _modes,
          onSave: (result) async {
            _modes = {for (var e in result.entries) e.key: e.value};
            await _saveSettings();
          },
        );
      },
    );
  }

  // Open session sheet (widget)
  void _openSessionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SessionBottomSheet(
          initial: _sessions,
          onSave: (result) async {
            _sessions = {for (var e in result.entries) e.key: e.value};
            await _saveSettings();
          },
        );
      },
    );
  }

  // Open timeframe sheet for a pair (widget)
  void _openTimeframeForPair(String pair) {
    final initialPair = Map<String, dynamic>.from(_timeframes[pair] ?? {'signal': 'BUYSELL'});
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TimeframeBottomSheet(
          initialPairData: initialPair,
          onSave: (pairData) async {
            _timeframes[pair] = pairData;
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
            // mode & session buttons (same style as pair buttons)
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
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () async {
                      // open timeframe bottom sheet for this pair
                      _openTimeframeForPair(pair);
                    },
                    child: Text(pair, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1);

  Widget _buildAlertsArea(BoxConstraints constraints) {
    final bottomHeight = constraints.maxHeight * 0.5;
    if (_loadingAlerts && _alerts.isEmpty) {
      return SizedBox(height: bottomHeight, child: const Center(child: CircularProgressIndicator()));
    }
    if (_alerts.isEmpty) {
      return SizedBox(height: bottomHeight, child: const Center(child: Text('سیگنالی دریافت نشده است.')));
    }

    return SizedBox(
      height: bottomHeight,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final caption = alert['caption'] as String? ?? '';
          final filename = alert['filename'] as String? ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  _api.getImageUrl(filename),
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        caption.replaceAll('<code>', '').replaceAll('</code>', ''),
                        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final codeMatch = RegExp(r'<code>(.*?)</code>').firstMatch(caption);
                              if (codeMatch != null) {
                                final copy = codeMatch.group(1)!;
                                Clipboard.setData(ClipboardData(text: copy));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کپی شد!')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('متنی برای کپی موجود نیست')));
                              }
                            },
                            child: const Text('کپی متن'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('Alert_X')),
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              _buildTopArea(constraints),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildDivider()),
              Expanded(child: _buildAlertsArea(constraints)),
            ],
          );
        }),
      ),
    );
  }
}
