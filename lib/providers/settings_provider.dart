import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user_settings.dart';

class SettingsProvider with ChangeNotifier {
  UserSettings? _userSettings;
  String? _userId;
  bool _isLoading = false;

  UserSettings? get userSettings => _userSettings;
  String? get userId => _userId;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> loadUserSettings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userId = userId;
      _userSettings = await _apiService.getUserSettings(userId);
      await StorageService.saveUserId(userId);
    } catch (e) {
      final localSettings = await StorageService.getUserSettings();
      if (localSettings != null) {
        _userSettings = UserSettings.fromJson(localSettings);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserSettings(UserSettings newSettings) async {
    _userSettings = newSettings;
    notifyListeners();

    try {
      if (_userId != null) {
        await _apiService.updateUserSettings(_userId!, newSettings);
      }
      await StorageService.saveUserSettings(newSettings.toJson());
    } catch (e) {
      // خطا در بروزرسانی - تنظیمات محلی ذخیره شد
    }
  }

  Future<void> logout() async {
    _userSettings = null;
    _userId = null;
    await StorageService.clearAllData();
    notifyListeners();
  }
}
