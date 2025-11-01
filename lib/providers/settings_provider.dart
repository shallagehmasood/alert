import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/user_settings.dart';

class SettingsProvider with ChangeNotifier {
  UserSettings? _userSettings;
  String? _userId;
  bool _isLoading = false;

  UserSettings? get userSettings => _userSettings;
  String? get userId => _userId;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  SettingsProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // استفاده از شناسه دستگاه به عنوان userId
      _userId = NotificationService.deviceId;
      
      if (_userId != null) {
        // بارگذاری تنظیمات کاربر
        _userSettings = await _apiService.getUserSettings(_userId!);
        await StorageService.saveUserId(_userId!);
        
        print('✅ کاربر با شناسه $_userId وارد شد');
      }
    } catch (e) {
      // اگر کاربر در وایت لیست نبود، از تنظیمات محلی استفاده کن
      final localSettings = await StorageService.getUserSettings();
      if (localSettings != null) {
        _userSettings = UserSettings.fromJson(localSettings);
        print('⚠️ استفاده از تنظیمات محلی');
      } else {
        // ایجاد تنظیمات پیش‌فرض
        _userSettings = UserSettings(
          timeframes: {},
          modes: {},
          sessions: {},
        );
        print('✅ ایجاد تنظیمات پیش‌فرض برای کاربر جدید');
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
