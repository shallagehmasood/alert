import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  final String userId;
  const AlertsScreen({super.key, required this.userId});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) _loadAlerts();
      return true;
    });
  }

  Future<void> _loadAlerts() async {
    final alerts = await _api.getAlerts(widget.userId);
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    final codeMatch = RegExp(r'<code>(.*?)</code>').firstMatch(text);
    if (codeMatch != null) {
      Clipboard.setData(ClipboardData(text: codeMatch.group(1)!));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کپی شد!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _alerts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_alerts.isEmpty) {
      return const Center(child: Text('سیگنالی دریافت نشده است.'));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final caption = alert['caption'] as String;
          final filename = alert['filename'] as String;

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
                      ElevatedButton(
                        onPressed: () => _copyToClipboard(caption),
                        child: const Text('کپی متن'),
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
}
