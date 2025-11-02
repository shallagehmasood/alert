import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // راه‌اندازی نوتیفیکیشن‌ها
  static Future<void> initialize() async {
    // درخواست مجوز
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // راه‌اندازی local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(settings);
    
    // دریافت FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // مدیریت نوتیفیکیشن در foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });
    
    // مدیریت وقتی کاربر روی نوتیفیکیشن کلیک می‌کنه
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }
  
  // مدیریت پیام‌های دریافتی
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'force_logout':
        _handleForceLogout(data);
        break;
      case 'new_image':
        _handleNewImage(data);
        break;
      default:
        _showNotification(
          message.notification?.title ?? 'پیام جدید',
          message.notification?.body ?? '',
          data,
        );
    }
  }
  
  // نمایش نوتیفیکیشن محلی
  static Future<void> _showNotification(String title, String body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'image_channel',
      'Image Notifications',
      channelDescription: 'Channel for image alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: json.encode(data),
    );
  }
  
  // مدیریت خروج اجباری
  static void _handleForceLogout(Map<String, dynamic> data) {
    // اینجا باید کاربر رو به صفحه لاگین هدایت کنی
    // می‌تونی از Provider یا Navigator استفاده کنی
    print('Force logout: ${data['message']}');
  }
  
  // مدیریت تصویر جدید
  static void _handleNewImage(Map<String, dynamic> data) {
    final filename = data['filename'];
    final imageUrl = data['image_url'];
    
    _showNotification(
      '📸 تصویر جدید',
      'تصویر $filename آماده است',
      data,
    );
    
    // اینجا می‌تونی تصویر رو به لیست اضافه کنی
    print('New image: $filename - $imageUrl');
  }
  
  // گرفتن FCM token
  static Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }
}
