// models/app_state_model.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class AppState with ChangeNotifier {
  bool _isLoading = false;
  String _error = '';
  ConnectivityResult _connectivity = ConnectivityResult.none;
  bool _isRegistered = false;

  bool get isLoading => _isLoading;
  String get error => _error;
  ConnectivityResult get connectivity => _connectivity;
  bool get isOnline => _connectivity != ConnectivityResult.none;
  bool get isRegistered => _isRegistered;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void setConnectivity(ConnectivityResult result) {
    _connectivity = result;
    notifyListeners();
  }

  void setRegistered(bool registered) {
    _isRegistered = registered;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
