import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String _baseUrl = "ws://178.63.171.244:8000";
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _signalController = StreamController.broadcast();
  
  Stream<Map<String, dynamic>> get signalStream => _signalController.stream;

  void connect(String userId) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$_baseUrl/ws/signals/$userId'),
      );

      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _signalController.add(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnect(userId);
        },
        onDone: () {
          print('WebSocket disconnected');
          _reconnect(userId);
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _reconnect(String userId) {
    Future.delayed(const Duration(seconds: 5), () {
      connect(userId);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _signalController.close();
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }
}
