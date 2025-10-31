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
  
  // متد جدید برای ارسال توکن پس از لاگین - بدون بررسی محدودیت
  static Future<void> sendTokenAfterLogin(String userId) async {
    _currentUserId = userId;
    
    if (_fcmToken != null && _deviceId != null) {
      try {
        final response = await http.post(
          Uri.parse('http://178.63.171.244:8000/user/$userId/fcm_token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fcm_token': _fcmToken!,
            'device_id': _deviceId!,
            'platform': 'android',
            'app_version': '1.0.0',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
        
        if (response.statusCode == 200) {
          print('✅ FCM Token با موفقیت ثبت شد');
        } else {
          print('❌ خطا در ارسال FCM Token: ${response.statusCode}');
          // ادامه می‌دهیم حتی اگر خطا داشته باشد - کاربر می‌تواند از برنامه استفاده کند
        }
      } catch (e) {
        print('❌ خطا در ارسال FCM Token: $e');
        // ادامه می‌دهیم حتی اگر خطا داشته باشد
      }
    } else {
      print('⚠️ FCM Token یا Device ID موجود نیست');
    }
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
