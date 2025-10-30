import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 🔥 این import رو اضافه کنید
import 'dart:convert'; // 🔥 برای jsonEncode

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // دریافت FCM Token
    _fcmToken = await _messaging.getToken();
    print('🎯 FCM Token: $_fcmToken');
    
    // ذخیره token در سرور 
    await _sendTokenToServer(_fcmToken); // 🔥 این حالا کار می‌کنه
    
    // تنظیم دسترسی‌ها
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    
    print('🔔 دسترسی نوتیفیکیشن: ${settings.authorizationStatus}');
    
    // مدیریت نوتیفیکیشن‌های foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // وقتی کاربر روی نوتیفیکیشن کلیک می‌کند
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // نوتیفیکیشن وقتی اپ بسته است
    FirebaseMessaging.instance.getInitialMessage().then(_handleBackgroundMessage);
  }
  
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 نوتیفیکیشن دریافتی (Foreground): ${message.notification?.title}');
    _showLocalNotification(message);
  }
  
  static void _handleBackgroundMessage(RemoteMessage? message) {
    if (message != null) {
      print('📨 نوتیفیکیشن دریافتی (Background): ${message.notification?.title}');
      _navigateToSignalScreen(message.data);
    }
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    // برای سادگی از SnackBar استفاده می‌کنیم
  }
  
  static void _navigateToSignalScreen(Map<String, dynamic> data) {
    // هدایت کاربر به صفحه سیگنال مربوطه
  }
  
  static Future<void> _sendTokenToServer(String? token) async {
    if (token != null) {
      try {
        print('🚀 ارسال FCM Token به سرور: ${token.substring(0, 20)}...');
        
        final response = await http.post(
          Uri.parse('http://178.63.171.244:8000/user/2/fcm_token'), // 🔥 آدرس سرور رو اصلاح کنید
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcm_token': token}),
        );
        
        if (response.statusCode == 200) {
          print('✅ FCM Token با موفقیت به سرور ارسال شد');
        } else {
          print('❌ خطا در ارسال FCM Token: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('❌ خطا در ارسال FCM Token به سرور: $e');
      }
    }
  }
  
  static String? get fcmToken => _fcmToken;
  
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('📢 عضویت در تاپیک: $topic');
  }
  
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('📢 لغو عضویت از تاپیک: $topic');
  }
}
