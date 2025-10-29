import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<Map<String, dynamic>> loadSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'settings_$userId';
    final raw = prefs.getString(key);
    if (raw == null) return {'timeframes': {}, 'modes': {}, 'sessions': {}};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'timeframes': map['timeframes'] ?? {},
        'modes': map['modes'] ?? {},
        'sessions': map['sessions'] ?? {},
      };
    } catch (_) {
      return {'timeframes': {}, 'modes': {}, 'sessions': {}};
    }
  }

  static Future<void> saveSettings(String userId, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'settings_$userId';
    await prefs.setString(key, jsonEncode(payload));
  }
}
