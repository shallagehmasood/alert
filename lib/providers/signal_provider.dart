import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../models/signal_model.dart';

class SignalProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  List<Signal> _signals = [];
  bool _isConnected = false;
  Signal? _latestSignal;

  List<Signal> get signals => _signals;
  bool get isConnected => _isConnected;
  Signal? get latestSignal => _latestSignal;

  void clearLatestSignal() {
    _latestSignal = null;
    notifyListeners();
  }

  void connect(String userId) {
    _webSocketService.connect(userId);
    
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
