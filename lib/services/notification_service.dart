import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;
  static String? _currentUserId;
  static String? _deviceId;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // تولید شناسه دستگاه
    _deviceId = await _getOrCreateDeviceId();
    print('📱 Device ID: $_deviceId');
    
    // دریافت FCM Token
    _fcmToken = await _messaging.getToken();
    print('🎯 FCM Token: $_fcmToken');
    
    // دریافت userId از SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
    
    // اگر کاربر لاگین کرده، وضعیت را چک کن
    if (_currentUserId != null && _fcmToken != null) {
      await _checkAndUpdateToken(_currentUserId!);
    }
    
    // تنظیم دسترسی‌ها
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    print('🔔 دسترسی نوتیفیکیشن: ${settings.authorizationStatus}');
    
    // مدیریت نوتیفیکیشن‌ها
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.instance.getInitialMessage().then(_handleBackgroundMessage);
  }
  
  // تولید یا دریافت شناسه دستگاه
  static Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      await prefs.setString('device_id', deviceId);
    }
    
    return deviceId;
  }
  
  // چک کردن و آپدیت توکن
  static Future<void> _checkAndUpdateToken(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://178.63.171.244:8000/user/$userId/device_status'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final registeredDeviceId = data['device_id'];
        
        if (registeredDeviceId == _deviceId) {
          // همین دستگاه - آپدیت توکن
          await _sendTokenToServer(userId, _fcmToken!);
        } else {
          // دستگاه متفاوت - کاربر باید مجدد لاگین کند
          await _logoutLocally();
        }
      }
    } catch (e) {
      print('❌ خطا در چک کردن وضعیت دستگاه: $e');
    }
  }
  
  // متد جدید برای ارسال توکن پس از لاگین
  static Future<void> sendTokenAfterLogin(String userId) async {
    _currentUserId = userId;
    
    if (_fcmToken != null) {
      await _sendTokenToServer(userId, _fcmToken!);
    } else {
      // اگر توکن موجود نیست، مجدد دریافت کن
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _sendTokenToServer(userId, _fcmToken!);
      }
    }
  }
  
  static Future<void> _sendTokenToServer(String userId, String token) async {
    try {
      print('🚀 ارسال FCM Token برای کاربر $userId از دستگاه $_deviceId');
      
      final response = await http.post(
        Uri.parse('http://178.63.171.244:8000/user/$userId/fcm_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcm_token': token,
          'device_id': _deviceId,
          'platform': 'android',
          'app_version': '1.0.0',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ FCM Token با موفقیت ثبت شد');
      } else if (response.statusCode == 409) {
        print('❌ کاربر از قبل در دستگاه دیگری فعال است');
        throw Exception('User already active on another device');
      } else {
        print('❌ خطا در ارسال FCM Token: ${response.statusCode}');
        throw Exception('Failed to send FCM token');
      }
    } catch (e) {
      print('❌ خطا در ارسال FCM Token: $e');
      throw e;
    }
  }
  
  // لاگاوت محلی
  static Future<void> _logoutLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _currentUserId = null;
  }
  
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 نوتیفیکیشن دریافتی: ${message.notification?.title}');
    _showLocalNotification(message);
  }
  
  static void _handleBackgroundMessage(RemoteMessage? message) {
    if (message != null) {
      print('📨 نوتیفیکیشن در background: ${message.notification?.title}');
    }
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    // نمایش نوتیفیکیشن محلی
  }
  
  static String? get fcmToken => _fcmToken;
  static String? get currentUserId => _currentUserId;
  static String? get deviceId => _deviceId;
}
