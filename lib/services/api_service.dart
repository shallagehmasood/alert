import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://178.63.171.244:8000';

class ApiService {
  Future<Map<String, dynamic>> getSettings(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/settings?user_id=$userId'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'timeframes': {},
      'modes': {},
      'sessions': {},
    };
  }

  Future<void> saveSettings(String userId, Map<String, dynamic> data) async {
    final payload = {
      'user_id': userId,
      'timeframes': data['timeframes'] ?? {},
      'modes': data['modes'] ?? {},
      'sessions': data['sessions'] ?? {},
    };
    final uri = Uri.parse('$_baseUrl/settings');
    try {
      final response = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        throw Exception('Save failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAlerts(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/alerts?user_id=$userId'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<dynamic>.from(body['alerts'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  String getImageUrl(String filename) {
    return '$_baseUrl/image/$filename';
  }
}
