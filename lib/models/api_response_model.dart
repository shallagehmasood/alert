// models/api_response_model.dart
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class SignalResponse {
  final List<Signal> signals;

  SignalResponse({required this.signals});

  factory SignalResponse.fromJson(Map<String, dynamic> json) {
    final signalsJson = json['signals'] as List<dynamic>?;
    return SignalResponse(
      signals: signalsJson?.map((item) => Signal.fromJson(item)).toList() ?? [],
    );
  }
}

class UserSettingsResponse {
  final Map<String, dynamic> settings;

  UserSettingsResponse({required this.settings});

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UserSettingsResponse(settings: Map<String, dynamic>.from(json));
  }
}
