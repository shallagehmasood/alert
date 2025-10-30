import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_settings.dart';

class ApiService {
  static const String baseUrl = "http://178.63.171.244:8000";

  Future<UserSettings> getUserSettings(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/settings'),
    );

    if (response.statusCode == 200) {
      return UserSettings.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user settings');
    }
  }

  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/$userId/settings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(settings.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update settings');
    }
  }
}
