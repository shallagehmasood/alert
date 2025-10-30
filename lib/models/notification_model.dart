// models/notification_model.dart
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.data,
    this.isRead = false,
  });

  factory AppNotification.fromSignal(Signal signal) {
    return AppNotification(
      id: 'signal_${signal.timestamp}',
      title: 'سیگنال ${signal.signalType} جدید',
      body: '${signal.pair} - ${signal.timeframe} - ${signal.modeName}',
      type: 'SIGNAL',
      timestamp: DateTime.now(),
      data: signal.toJson(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
      isRead: json['isRead'] ?? false,
    );
  }
}
