// services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService with ChangeNotifier {
  static const String baseUrl = 'http://178.63.171.244:8000';
  String? _userId;
  List<Signal> _signals = [];

  String? get userId => _userId;
  List<Signal> get signals => _signals;

  Future<bool> registerUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/$userId'),
      );
      
      if (response.statusCode == 200) {
        _userId = userId;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    if (_userId == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$_userId/settings'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  Future<List<Signal>> getSignals() async {
    if (_userId == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$_userId/signals'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> signalsJson = data['signals'];
        _signals = signalsJson.map((json) => Signal.fromJson(json)).toList();
        notifyListeners();
        return _signals;
      }
      return [];
    } catch (e) {
      print('Error getting signals: $e');
      return [];
    }
  }
}
