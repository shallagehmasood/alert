import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://178.63.171.244:8000';
  
  // چک کردن آیا کاربر قبلاً لاگین کرده
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }
  
  // گرفتن کاربر فعلی
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  
  // لاگین کاربر
  static Future<Map<String, dynamic>> loginUser(String userId, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'user_id': userId,
        'fcm_token': fcmToken,
      },
    );
    
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      return json.decode(response.body);
    } else {
      throw Exception('خطا در ورود: ${response.body}');
    }
  }
  
  // لاگ اوت کاربر
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        body: {'user_id': userId},
      );
    }
    
    await prefs.remove('user_id');
  }
  
  // ارسال heartbeat
  static Future<void> sendHeartbeat(String userId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/heartbeat'),
        body: {'user_id': userId},
      );
    } catch (e) {
      print('Heartbeat error: $e');
    }
  }
}
