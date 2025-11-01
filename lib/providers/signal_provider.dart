// lib/providers/signal_provider.dart
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
  String? _currentUserId;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;

  List<Signal> get signals => _signals;
  bool get isConnected => _isConnected;
  Signal? get latestSignal => _latestSignal;
  bool get hasNewNotifications => _hasNewNotifications;
  bool get isConnecting => _isConnecting;
  String? get currentUserId => _currentUserId;

  static const String baseUrl = "http://178.63.171.244:8000";

  SignalProvider() {
    print('✅ SignalProvider initialized');
  }

  void clearLatestSignal() {
    _latestSignal = null;
    notifyListeners();
  }

  Future<void> loadQueuedMessages(String userId) async {
    try {
      print('📨 در حال دریافت پیام‌های آفلاین برای کاربر $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/queued_messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = data['messages'] as List;
        
        print('✅ ${messages.length} پیام آفلاین دریافت شد');
        
        for (var msg in messages) {
          try {
            final signal = Signal.fromJson(msg);
            _addSignal(signal);
          } catch (e) {
            print('❌ خطا در پردازش پیام آفلاین: $e');
          }
        }
        
        if (messages.isNotEmpty) {
          _showMessage('${messages.length} پیام آفلاین دریافت شد');
        }
      } else {
        print('❌ خطا در دریافت پیام‌های آفلاین: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در اتصال برای دریافت پیام‌های آفلاین: $e');
    }
  }

  Future<void> checkPendingNotifications(String userId) async {
    try {
      print('🔔 بررسی نوتیفیکیشن‌های pending برای کاربر $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/pending_notifications'),
        headers: {'Content-Type': 'application/json'},
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
      } else {
        print('❌ خطا در بررسی نوتیفیکیشن‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در بررسی نوتیفیکیشن‌ها: $e');
    }
  }

  void _showNotificationAlert(int count) {
    print('🎯 کاربر $count نوتیفیکیشن جدید دارد');
    // می‌توانید از SnackBar یا Dialog استفاده کنید
  }

  void _showMessage(String message) {
    print('💬 $message');
    // می‌توانید از SnackBar استفاده کنید
  }

  Future<void> markNotificationsAsRead(String userId) async {
    try {
      print('📝 علامت‌گذاری نوتیفیکیشن‌ها به عنوان خوانده شده');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/$userId/mark_notifications_read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _hasNewNotifications = false;
        notifyListeners();
        print('✅ نوتیفیکیشن‌ها خوانده شده علامت‌گذاری شدند');
      } else {
        print('❌ خطا در علامت‌گذاری نوتیفیکیشن‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطا در علامت‌گذاری نوتیفیکیشن‌ها: $e');
    }
  }

  void connect(String userId) {
    if (_isConnecting) {
      print('⏳ در حال اتصال... صبر کنید');
      return;
    }

    _currentUserId = userId;
    _isConnecting = true;
    _reconnectAttempts = 0;
    notifyListeners();

    print('🚀 شروع اتصال WebSocket برای کاربر $userId');

    try {
      // اتصال WebSocket
      _webSocketService.connect(userId);
      
      // گوش دادن به تغییرات وضعیت اتصال
      _webSocketService.connectionStream.listen(
        (connected) {
          print(connected ? '✅ اتصال WebSocket برقرار شد' : '❌ اتصال WebSocket قطع شد');
          _isConnected = connected;
          _isConnecting = false;
          
          if (connected) {
            _reconnectAttempts = 0; // reset counter on successful connection
            _showMessage('اتصال برقرار شد - دریافت لحظه‌ای سیگنال‌ها');
          } else {
            _scheduleReconnect(userId);
          }
          
          notifyListeners();
        },
        onError: (error) {
          print('❌ خطا در وضعیت اتصال: $error');
          _isConnected = false;
          _isConnecting = false;
          _scheduleReconnect(userId);
          notifyListeners();
        }
      );

      // گوش دادن به پیام‌های دریافتی
      _webSocketService.signalStream.listen(
        (data) {
          print('📨 دریافت پیام جدید از WebSocket');
          try {
            final signal = Signal.fromJson(data);
            _addSignal(signal);
            _showMessage('سیگنال جدید دریافت شد: ${signal.pair}');
          } catch (e) {
            print('❌ خطا در پردازش پیام WebSocket: $e');
          }
        },
        onError: (error) {
          print('❌ خطا در دریافت پیام WebSocket: $error');
        },
        onDone: () {
          print('🔌 جریان پیام‌های WebSocket بسته شد');
          _isConnected = false;
          _isConnecting = false;
          _scheduleReconnect(userId);
          notifyListeners();
        }
      );

      // بارگذاری پیام‌های آفلاین و نوتیفیکیشن‌ها
      _loadOfflineData(userId);

    } catch (e) {
      print('❌ خطا در راه‌اندازی اتصال WebSocket: $e');
      _isConnected = false;
      _isConnecting = false;
      _scheduleReconnect(userId);
      notifyListeners();
    }
  }

  Future<void> _loadOfflineData(String userId) async {
    try {
      await Future.wait([
        loadQueuedMessages(userId),
        checkPendingNotifications(userId),
      ]);
      print('✅ داده‌های آفلاین با موفقیت بارگذاری شدند');
    } catch (e) {
      print('❌ خطا در بارگذاری داده‌های آفلاین: $e');
    }
  }

  void _scheduleReconnect(String userId) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('🛑 توقف تلاش برای reconnect - بیشینه تعداد تلاش‌ها');
      _showMessage('اتصال قطع شد. لطفا صفحه را رفرش کنید.');
      return;
    }

    _reconnectAttempts++;
    final delaySeconds = _calculateReconnectDelay(_reconnectAttempts);
    
    print('🔄 تلاش برای reconnect بعد از $delaySeconds ثانیه (تلاش $_reconnectAttempts)');
    
    Future.delayed(Duration(seconds: delaySeconds), () {
      if (_currentUserId == userId && !_isConnected && !_isConnecting) {
        print('🔄 اجرای reconnect برای کاربر $userId');
        connect(userId);
      }
    });
  }

  int _calculateReconnectDelay(int attempt) {
    // Exponential backoff با محدودیت 60 ثانیه
    return [1, 2, 5, 10, 15, 30, 45, 60, 60, 60][attempt - 1];
  }

  void _addSignal(Signal signal) {
    // جلوگیری از اضافه کردن سیگنال تکراری
    final isDuplicate = _signals.any((s) => 
      s.pair == signal.pair &&
      s.timeframe == signal.timeframe &&
      s.timestamp.difference(signal.timestamp).inSeconds.abs() < 10
    );

    if (!isDuplicate) {
      _signals.insert(0, signal);
      _latestSignal = signal;
      
      // محدود کردن تعداد سیگنال‌ها برای جلوگیری از overload حافظه
      if (_signals.length > 100) {
        _signals = _signals.sublist(0, 100);
      }
      
      notifyListeners();
      print('✅ سیگنال جدید اضافه شد: ${signal.pair} - ${signal.timeframe}');
    } else {
      print('⚠️ سیگنال تکراری نادیده گرفته شد: ${signal.pair} - ${signal.timeframe}');
    }
  }

  void removeSignalFromApp(Signal signal) {
    _signals.remove(signal);
    notifyListeners();
    print('🗑️ سیگنال از اپلیکیشن حذف شد: ${signal.pair} - ${signal.timeframe}');
  }

  void clearSignals() {
    _signals.clear();
    _latestSignal = null;
    notifyListeners();
    print('🧹 تمام سیگنال‌ها پاک شدند');
  }

  void disconnect() {
    print('🔌 قطع کردن اتصال WebSocket');
    _webSocketService.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _currentUserId = null;
    _reconnectAttempts = 0;
    notifyListeners();
  }

  // متد برای تست دستی اتصال
  void testConnection(String userId) {
    print('🧪 تست دستی اتصال برای کاربر $userId');
    connect(userId);
  }

  // متد برای دریافت وضعیت دقیق
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'reconnectAttempts': _reconnectAttempts,
      'maxReconnectAttempts': _maxReconnectAttempts,
      'signalCount': _signals.length,
      'currentUserId': _currentUserId,
    };
  }

  // متد برای فیلتر کردن سیگنال‌ها
  List<Signal> getFilteredSignals({String? pair, String? signalType}) {
    var filtered = _signals;
    
    if (pair != null) {
      filtered = filtered.where((signal) => signal.pair == pair).toList();
    }
    
    if (signalType != null) {
      filtered = filtered.where((signal) => signal.signalType == signalType).toList();
    }
    
    return filtered;
  }

  // متد برای بارگذاری تصاویر از سرور
  Future<List<Signal>> loadImagesFromServer(String userId, {int skip = 0, int limit = 50}) async {
    try {
      print('🖼️ در حال دریافت تصاویر از سرور برای کاربر $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/images?skip=$skip&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imagesData = data['images'] as List;
        
        print('✅ ${imagesData.length} تصویر از سرور دریافت شد');
        
        List<Signal> serverSignals = [];
        
        for (var imgData in imagesData) {
          try {
            // ساخت Signal از داده‌های تصویر سرور
            final signal = Signal(
              pair: imgData['pair'] ?? '',
              timeframe: imgData['timeframe'] ?? '',
              signalType: imgData['signal_type'] ?? 'BUY',
              modeBits: imgData['mode_bits'] ?? '',
              timestamp: DateTime.parse(imgData['created_at'] ?? DateTime.now().toIso8601String()),
              imageData: null, // داده تصویر بعداً لود می‌شود
            );
            
            serverSignals.add(signal);
          } catch (e) {
            print('❌ خطا در پردازش تصویر از سرور: $e');
          }
        }
        
        return serverSignals;
      } else {
        print('❌ خطا در دریافت تصاویر از سرور: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ خطا در اتصال برای دریافت تصاویر از سرور: $e');
      return [];
    }
  }

  // متد برای دریافت تصویر خاص از سرور
  Future<Uint8List?> loadImageData(String userId, String filename) async {
    try {
      print('📥 در حال دریافت داده تصویر: $filename');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/image/$filename'),
      );

      if (response.statusCode == 200) {
        print('✅ داده تصویر دریافت شد: $filename');
        return response.bodyBytes;
      } else {
        print('❌ خطا در دریافت داده تصویر: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ خطا در اتصال برای دریافت داده تصویر: $e');
      return null;
    }
  }

  // متد برای حذف تصویر از سرور (فقط از لیست)
  Future<bool> deleteImageFromServer(String userId, String filename) async {
    try {
      print('🗑️ در حال حذف تصویر از سرور: $filename');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId/image/$filename'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ تصویر از سرور حذف شد: $filename');
        return data['status'] == 'success';
      } else {
        print('❌ خطا در حذف تصویر از سرور: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطا در اتصال برای حذف تصویر از سرور: $e');
      return false;
    }
  }

  // متد برای همگام‌سازی سیگنال‌ها با سرور
  Future<void> syncWithServer(String userId) async {
    try {
      print('🔄 شروع همگام‌سازی با سرور برای کاربر $userId');
      
      // دریافت تصاویر از سرور
      final serverSignals = await loadImagesFromServer(userId, limit: 100);
      
      // پیدا کردن سیگنال‌های جدید از سرور که در اپلیکیشن نیستند
      final newSignals = serverSignals.where((serverSignal) {
        return !_signals.any((localSignal) =>
          localSignal.pair == serverSignal.pair &&
          localSignal.timeframe == serverSignal.timeframe &&
          localSignal.timestamp.difference(serverSignal.timestamp).inSeconds.abs() < 10
        );
      }).toList();
      
      // اضافه کردن سیگنال‌های جدید
      for (var signal in newSignals) {
        _addSignal(signal);
      }
      
      print('✅ همگام‌سازی کامل شد. ${newSignals.length} سیگنال جدید اضافه شد');
      
    } catch (e) {
      print('❌ خطا در همگام‌سازی با سرور: $e');
    }
  }

  // متد برای بررسی سلامت اتصال
  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ سرور در دسترس نیست: $e');
      return false;
    }
  }

  // متد برای دریافت اطلاعات دیباگ
  Future<Map<String, dynamic>> getDebugInfo(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/debug/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed to get debug info'};
      }
    } catch (e) {
      return {'error': 'Connection failed: $e'};
    }
  }

  @override
  void dispose() {
    print('♻️ SignalProvider dispose شد');
    disconnect();
    super.dispose();
  }
}
