import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

const Map<String, String> DISPLAY_SESSIONS = {
  "TOKYO": "سشن توکیو \u200E( 03:00-10:00)",
  "LONDON": "سشن لندن \u200E(19:00 - 22:00)",
  "NEWYORK": "سشن نیویورک \u200E(15:00 - 00:00)",
  "SYDNEY": "سشن سیدنی \u200E(01:00 - 10:00)"
};

class SessionsScreen extends StatefulWidget {
  final String userId;
  const SessionsScreen({super.key, required this.userId});

  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final ApiService _api = ApiService();
  Map<String, bool> _sessions = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final data = await _api.getSettings(widget.userId);
      final sessions = (data['sessions'] as Map?) ?? {};
      setState(() {
        _sessions = {
          for (var s in ['TOKYO', 'LONDON', 'NEWYORK', 'SYDNEY'])
            s: sessions[s] == true
        };
        _loading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'خطا در بارگذاری سشن‌ها');
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSession(String session) async {
    setState(() {
      _sessions[session] = !(_sessions[session] ?? false);
    });

    try {
      await _api.saveSettings(widget.userId, {
        'timeframes': {},
        'modes': {},
        'sessions': _sessions,
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'ذخیره نشد');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('انتخاب سشن')),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (var session in ['TOKYO', 'LONDON', 'NEWYORK', 'SYDNEY'])
              ListTile(
                title: Text(DISPLAY_SESSIONS[session]!),
                leading: Icon(
                  (_sessions[session] ?? false)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: (_sessions[session] ?? false) ? Colors.green : Colors.grey,
                ),
                onTap: () => _toggleSession(session),
              ),
          ],
        ),
      ),
    );
  }
}
