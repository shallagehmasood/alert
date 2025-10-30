// models/user_settings_model.dart
import 'package:flutter/material.dart';

class UserSettings with ChangeNotifier {
  Map<String, PairSettings> _pairs = {};
  Map<String, bool> _modes = {
    'A1': true,
    'A2': false,
    'B': false,
    'C': false,
    'D': false,
    'E': false,
    'F': false,
    'G': false,
  };
  Map<String, bool> _sessions = {
    'TOKYO': false,
    'LONDON': true,
    'NEWYORK': true,
    'SYDNEY': false,
  };
  NotificationSettings _notificationSettings = NotificationSettings();

  Map<String, PairSettings> get pairs => _pairs;
  Map<String, bool> get modes => _modes;
  Map<String, bool> get sessions => _sessions;
  NotificationSettings get notificationSettings => _notificationSettings;

  void updatePairSettings(String pair, PairSettings settings) {
    _pairs[pair] = settings;
    notifyListeners();
  }

  void toggleMode(String mode, bool value) {
    _modes[mode] = value;
    notifyListeners();
  }

  void toggleSession(String session, bool value) {
    _sessions[session] = value;
    notifyListeners();
  }

  void updateNotificationSettings(NotificationSettings settings) {
    _notificationSettings = settings;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'pairs': _pairs.map((key, value) => MapEntry(key, value.toJson())),
      'modes': _modes,
      'sessions': _sessions,
      'notificationSettings': _notificationSettings.toJson(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final settings = UserSettings();
    
    if (json['pairs'] != null) {
      settings._pairs = (json['pairs'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, PairSettings.fromJson(value)),
      );
    }
    
    if (json['modes'] != null) {
      settings._modes = Map<String, bool>.from(json['modes']);
    }
    
    if (json['sessions'] != null) {
      settings._sessions = Map<String, bool>.from(json['sessions']);
    }
    
    if (json['notificationSettings'] != null) {
      settings._notificationSettings = NotificationSettings.fromJson(json['notificationSettings']);
    }
    
    return settings;
  }
}

class PairSettings {
  final Map<String, bool> timeframes;
  final String signal;

  PairSettings({
    required this.timeframes,
    required this.signal,
  });

  factory PairSettings.defaultSettings() {
    return PairSettings(
      timeframes: {
        'M1': false, 'M5': true, 'M15': true, 'M30': false,
        'H1': true, 'H4': false, 'D1': false, 'W1': false,
      },
      signal: 'BUYSELL',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframes': timeframes,
      'signal': signal,
    };
  }

  factory PairSettings.fromJson(Map<String, dynamic> json) {
    return PairSettings(
      timeframes: Map<String, bool>.from(json['timeframes'] ?? {}),
      signal: json['signal'] ?? 'BUYSELL',
    );
  }

  PairSettings copyWith({
    Map<String, bool>? timeframes,
    String? signal,
  }) {
    return PairSettings(
      timeframes: timeframes ?? this.timeframes,
      signal: signal ?? this.signal,
    );
  }
}

class NotificationSettings {
  bool enabled;
  bool vibration;
  bool sound;
  bool led;

  NotificationSettings({
    this.enabled = true,
    this.vibration = true,
    this.sound = false,
    this.led = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'vibration': vibration,
      'sound': sound,
      'led': led,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      vibration: json['vibration'] ?? true,
      sound: json['sound'] ?? false,
      led: json['led'] ?? true,
    );
  }
}
