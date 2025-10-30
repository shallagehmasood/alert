import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String _baseUrl = "ws://178.63.171.244:8000";
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _signalController = StreamController.broadcast();
  StreamController<bool> _connectionController = StreamController.broadcast();
  
  Stream<Map<String, dynamic>> get signalStream => _signalController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _channel != null && _channel!.closeCode == null;

  void connect(String userId) {
    try {
      // اگر اتصال قبلی وجود دارد، قطعش کن
      if (_channel != null) {
        _channel!.sink.close();
      }
      
      _channel = WebSocketChannel.connect(
        Uri.parse('$_baseUrl/ws/signals/$userId'),
      );

      // اطلاع‌رسانی اتصال موفق
      _connectionController.add(true);
      print('✅ WebSocket به کاربر $userId متصل شد');

      _channel!.stream.listen(
        (message) {
          print('📨 دریافت پیام WebSocket: $message');
          try {
            final data = json.decode(message);
            _signalController.add(data);
          } catch (e) {
            print('❌ خطا در parse پیام: $e');
          }
        },
        onError: (error) {
          print('❌ خطای WebSocket: $error');
          _connectionController.add(false);
          _reconnect(userId);
        },
        onDone: () {
          print('🔌 اتصال WebSocket بسته شد');
          _connectionController.add(false);
          _reconnect(userId);
        },
        cancelOnError: true,
      );
      
    } catch (e) {
      print('❌ خطا در اتصال WebSocket: $e');
      _connectionController.add(false);
      _reconnect(userId);
    }
  }

  void _reconnect(String userId) {
    Future.delayed(const Duration(seconds: 5), () {
      print('🔄 تلاش برای reconnect به کاربر $userId');
      connect(userId);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _signalController.close();
    _connectionController.close();
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(json.encode(message));
    }
  }
}
