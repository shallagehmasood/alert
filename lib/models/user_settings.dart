class UserSettings {
  final Map<String, dynamic> timeframes;
  final Map<String, bool> modes;
  final Map<String, bool> sessions;

  UserSettings({
    required this.timeframes,
    required this.modes,
    required this.sessions,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      timeframes: Map<String, dynamic>.from(json['timeframes'] ?? {}),
      modes: Map<String, bool>.from(json['modes'] ?? {}),
      sessions: Map<String, bool>.from(json['sessions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeframes': timeframes,
      'modes': modes,
      'sessions': sessions,
    };
  }

  UserSettings copyWith({
    Map<String, dynamic>? timeframes,
    Map<String, bool>? modes,
    Map<String, bool>? sessions,
  }) {
    return UserSettings(
      timeframes: timeframes ?? this.timeframes,
      modes: modes ?? this.modes,
      sessions: sessions ?? this.sessions,
    );
  }
}
