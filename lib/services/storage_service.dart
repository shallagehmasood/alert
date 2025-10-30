import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // اضافه کردن این import

class StorageService {
  static const String _userIdKey = 'user_id';
  static const String _userSettingsKey = 'user_settings';

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSettingsKey, json.encode(settings));
  }

  static Future<Map<String, dynamic>?> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_userSettingsKey);
    if (settingsString != null) {
      return json.decode(settingsString);
    }
    return null;
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
