// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "http://YOUR_SERVER_IP:8000";

  // دریافت تنظیمات کاربر
  Future<Map<String, dynamic>> getSettings(String userId) async {
    try {
      final uri = Uri.parse("$baseUrl/settings?user_id=$userId");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    // fallback به حافظه محلی
    final prefs = await SharedPreferences.getInstance();
    return {
      'timeframes': jsonDecode(prefs.getString('timeframes_$userId') ?? '{}'),
      'modes': jsonDecode(prefs.getString('modes_$userId') ?? '{}'),
      'sessions': jsonDecode(prefs.getString('sessions_$userId') ?? '{}'),
    };
  }

  // ذخیره تنظیمات کاربر
  Future<void> saveSettings(String userId, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse("$baseUrl/settings");
      final payload = {
        'user_id': userId,
        'timeframes': data['timeframes'] ?? {},
        'modes': data['modes'] ?? {},
        'sessions': data['sessions'] ?? {},
      };
      final response = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Server error');
      }
    } catch (_) {}
    // ذخیره در حافظه محلی
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timeframes_$userId', jsonEncode(data['timeframes'] ?? {}));
    await prefs.setString('modes_$userId', jsonEncode(data['modes'] ?? {}));
    await prefs.setString('sessions_$userId', jsonEncode(data['sessions'] ?? {}));
  }

  // دریافت Alerts (تصاویر و متن)
  Future<List<Map<String, dynamic>>> getAlerts(String userId) async {
    try {
      final uri = Uri.parse("$baseUrl/alerts?user_id=$userId");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['alerts'] as List<dynamic>).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  // ساخت URL تصویر
  String getImageUrl(String filename) {
    return "$baseUrl/image/$filename";
  }
}
