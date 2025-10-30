import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/websocket_service.dart';
import '../models/signal_model.dart';

class SignalProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  List<Signal> _signals = [];
  bool _isConnected = false;
  Signal? _latestSignal;
  bool _hasNewNotifications = false;

  List<Signal> get signals => _signals;
  bool get isConnected => _isConnected;
  Signal? get latestSignal => _latestSignal;
  bool get hasNewNotifications => _hasNewNotifications;

  static const String baseUrl = "http://178.63.171.244:8000";

  void clearLatestSignal() {
    _latestSignal = null;
    notifyListeners();
  }

  Future<void> loadQueuedMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/queued_messages'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = data['messages'] as List;
        
        for (var msg in messages) {
          final signal = Signal.fromJson(msg);
          _addSignal(signal);
        }
        
        print('✅ ${messages.length} پیام از صف دریافت شد');
      }
    } catch (e) {
      print('خطا در دریافت پیام‌های صف: $e');
    }
  }

  Future<void> checkPendingNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/pending_notifications'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hasNew = data['has_new_notifications'] ?? false;
        final count = data['notification_count'] ?? 0;
        
        _hasNewNotifications = hasNew;
        notifyListeners();
        
        if (hasNew) {
          print('🔔 $count نوتیفیکیشن جدید موجود است');
          _showNotificationAlert(count);
        }
      }
    } catch (e) {
      print('خطا در بررسی نوتیفیکیشن‌ها: $e');
    }
  }

  void _showNotificationAlert(int count) {
    print('🎯 کاربر $count نوتیفیکیشن جدید دارد');
  }

  Future<void> markNotificationsAsRead(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/$userId/mark_notifications_read'),
      );

      if (response.statusCode == 200) {
        _hasNewNotifications = false;
        notifyListeners();
        print('✅ نوتیفیکیشن‌ها خوانده شده علامت‌گذاری شدند');
      }
    } catch (e) {
      print('خطا در علامت‌گذاری نوتیفیکیشن‌ها: $e');
    }
  }

  void connect(String userId) {
    _webSocketService.connect(userId);
    
    checkPendingNotifications(userId);
    loadQueuedMessages(userId);
    
    _webSocketService.signalStream.listen((data) {
      final signal = Signal.fromJson(data);
      _addSignal(signal);
    }, onError: (error) {
      _isConnected = false;
      notifyListeners();
    });
    
    _isConnected = true;
    notifyListeners();
  }

  void _addSignal(Signal signal) {
    _signals.insert(0, signal);
    _latestSignal = signal;
    
    if (_signals.length > 100) {
      _signals = _signals.sublist(0, 100);
    }
    notifyListeners();
  }

  void clearSignals() {
    _signals.clear();
    _latestSignal = null;
    notifyListeners();
  }

  void disconnect() {
    _webSocketService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
