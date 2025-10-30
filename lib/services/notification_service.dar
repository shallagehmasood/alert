import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // دریافت FCM Token
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');
    
    // ذخیره token در سرور (اختیاری)
    await _sendTokenToServer(_fcmToken);
    
    // تنظیم دسترسی‌ها
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    
    print('دسترسی نوتیفیکیشن: ${settings.authorizationStatus}');
    
    // مدیریت نوتیفیکیشن‌های foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // وقتی کاربر روی نوتیفیکیشن کلیک می‌کند
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // نوتیفیکیشن وقتی اپ بسته است
    FirebaseMessaging.instance.getInitialMessage().then(_handleBackgroundMessage);
  }
  
  static void _handleForegroundMessage(RemoteMessage message) {
    print('نوتیفیکیشن دریافتی (Foreground): ${message.notification?.title}');
    
    // نمایش نوتیفیکیشن محلی
    _showLocalNotification(message);
  }
  
  static void _handleBackgroundMessage(RemoteMessage? message) {
    if (message != null) {
      print('نوتیفیکیشن دریافتی (Background): ${message.notification?.title}');
      
      // هدایت کاربر به صفحه مربوطه
      _navigateToSignalScreen(message.data);
    }
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    // اینجا می‌تونی از flutter_local_notifications استفاده کنی
    // برای سادگی از SnackBar استفاده می‌کنیم
  }
  
  static void _navigateToSignalScreen(Map<String, dynamic> data) {
    // هدایت کاربر به صفحه سیگنال مربوطه
    // Navigator.push(context, MaterialPageRoute(...))
  }
  
  static Future<void> _sendTokenToServer(String? token) async {
    if (token != null) {
      // ارسال token به سرور برای ذخیره
      print('ارسال FCM Token به سرور: $token');
      // await http.post(...);
    }
  }
  
  static String? get fcmToken => _fcmToken;
  
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('عضویت در تاپیک: $topic');
  }
  
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('لغو عضویت از تاپیک: $topic');
  }
}
