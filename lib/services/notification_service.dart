import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static Function(Map<String, dynamic>)? onNewImage;
  static Function()? onForceLogout;

  // راه‌اندازی نوتیفیکیشن‌ها - فقط FCM
  static Future<void> initialize() async {
    try {
      // درخواست مجوزهای لازم
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      print('Notification permissions: ${settings.authorizationStatus}');

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
    }
  }

  // مدیریت خروج اجباری
  static void _handleForceLogout(Map<String, dynamic> data) {
    print('🚪 Force logout received');
    onForceLogout?.call();
  }

  // مدیریت تصویر جدید
  static void _handleNewImage(Map<String, dynamic> data) {
    final filename = data['filename'] ?? 'Unknown';
    print('🖼️ New image received: $filename');
    onNewImage?.call(data);
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
}
