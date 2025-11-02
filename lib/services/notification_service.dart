import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Function(Map<String, dynamic>)? onNewImage;
  static Function()? onForceLogout;

  // راه‌اندازی کامل نوتیفیکیشن‌ها
  static Future<void> initialize() async {
    try {
      // درخواست مجوزهای لازم
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );
      
      print('Notification permissions: ${settings.authorizationStatus}');

      // راه‌اندازی local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationClick(response.payload);
        },
      );

      // ایجاد کانال برای اندروید
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'image_channel',
        'Image Notifications',
        description: 'Channel for image alerts',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      // تنظیم foreground handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // تنظیم background handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      // تنظیم terminated app handler
      _firebaseMessaging.getInitialMessage().then(_handleTerminatedMessage);

      // دریافت token و ذخیره در سرور
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        _sendTokenToServer(token);
      }

      // گوش دادن به refresh token
      _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);

      print('✅ Notification service initialized successfully');

    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  // مدیریت پیام در foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message received: ${message.messageId}');
    _processMessage(message);
  }

  // مدیریت پیام در background
  static void _handleBackgroundMessage(RemoteMessage message) {
    print('📨 Background message received: ${message.messageId}');
    _processMessage(message);
  }

  // مدیریت پیام وقتی اپ بسته است
  static void _handleTerminatedMessage(RemoteMessage? message) {
    if (message != null) {
      print('📨 Terminated app message received: ${message.messageId}');
      _processMessage(message);
    }
  }

  // پردازش پیام دریافتی
  static void _processMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? 'unknown';

    print('Processing message type: $type');

    switch (type) {
      case 'force_logout':
        _handleForceLogout(data);
        break;
      
      case 'new_image':
      case 'direct_image':
        _handleNewImage(data);
        break;
      
      default:
        _showBasicNotification(message);
    }
  }

  // مدیریت خروج اجباری
  static void _handleForceLogout(Map<String, dynamic> data) {
    print('🚪 Force logout received');
    
    // نمایش نوتیفیکیشن
    _showNotification(
      'خروج اجباری',
      data['message'] ?? 'از دستگاه دیگری با این حساب وارد شدید',
      data,
    );

    // فراخوانی callback
    onForceLogout?.call();
  }

  // مدیریت تصویر جدید
  static void _handleNewImage(Map<String, dynamic> data) {
    final filename = data['filename'] ?? 'Unknown';
    final imageUrl = data['image_url'];
    
    print('🖼️ New image received: $filename');

    // نمایش نوتیفیکیشن
    _showNotification(
      '📸 تصویر جدید',
      'تصویر $filename آماده است',
      data,
    );

    // فراخوانی callback برای آپدیت UI
    onNewImage?.call(data);
  }

  // نمایش نوتیفیکیشن پایه
  static void _showBasicNotification(RemoteMessage message) {
    _showNotification(
      message.notification?.title ?? 'پیام جدید',
      message.notification?.body ?? '',
      message.data,
    );
  }

  // نمایش نوتیفیکیشن محلی
  static Future<void> _showNotification(String title, String body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'image_channel',
      'Image Notifications',
      channelDescription: 'Channel for image alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: json.encode(data),
      );
      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // مدیریت کلیک روی نوتیفیکیشن
  static void _onNotificationClick(String? payload) {
    if (payload == null) return;
    
    try {
      final data = json.decode(payload);
      final type = data['type'];
      
      if (type == 'new_image') {
        onNewImage?.call(data);
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }

  // ارسال FCM token به سرور
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        await http.post(
          Uri.parse('http://178.63.171.244:8000/login'),
          body: {
            'user_id': userId,
            'fcm_token': token,
          },
        );
        print('✅ FCM token sent to server for user: $userId');
      }
    } catch (e) {
      print('❌ Error sending FCM token to server: $e');
    }
  }

  // گرفتن FCM token
  static Future<String?> getFcmToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // تنظیم توابع callback
  static void setCallbacks({
    Function(Map<String, dynamic>)? newImageCallback,
    Function()? forceLogoutCallback,
  }) {
    onNewImage = newImageCallback;
    onForceLogout = forceLogoutCallback;
  }

  // پاک کردن همه نوتیفیکیشن‌ها
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // تنظیم موضوع نوتیفیکیشن
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  // لغو موضوع نوتیفیکیشن
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('✅ Unsubscribed from topic: $topic');
  }
}
