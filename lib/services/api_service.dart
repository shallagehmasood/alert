### lib/services/api_service.dart

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
} catch (e) {
// ignore and return empty
}
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
try {
final response = await http
.post(Uri.parse('$_baseUrl/settings'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode(payload))
}
