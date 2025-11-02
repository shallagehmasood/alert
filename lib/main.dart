import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // راه‌اندازی نوتیفیکیشن‌های محلی
  await _initializeNotifications();
  
  runApp(MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  await FlutterLocalNotificationsPlugin().initialize(settings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Alert',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: MainWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainWrapper extends StatefulWidget {
  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('در حال بارگذاری...'),
            ],
          ),
        ),
      );
    }

    return _userId == null ? LoginPage() : HomePage();
  }
}

// صفحات
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;

  _login() async {
    if (_userIdController.text.isEmpty) {
      _showError('لطفاً شناسه را وارد کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userIdController.text);
      
      // راه‌اندازی نوتیفیکیشن‌ها پس از لاگین
      await NotificationService.initialize();
      
      // اطلاع به سرور
      final fcmToken = await NotificationService.getFcmToken();
      if (fcmToken != null) {
        await http.post(
          Uri.parse('http://178.63.171.244:8000/login'),
          body: {
            'user_id': _userIdController.text,
            'fcm_token': fcmToken,
          },
        );
      }

      // رفرش صفحه اصلی
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('خطا در ورود: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text('Photo Alert', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('ورود به سیستم', style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 40),
              TextField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'شناسه ۳ رقمی',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.security),
                ),
                maxLength: 3,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('ورود', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<dynamic> _images = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifyServerOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _notifyServerOffline();
    } else if (state == AppLifecycleState.resumed) {
      _notifyServerOnline();
    }
  }

  _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    
    if (_userId != null) {
      await _notifyServerOnline();
      await _loadImages();
      _startHeartbeat();
      
      // تنظیم callbacks برای نوتیفیکیشن
      NotificationService.setCallbacks(
        newImageCallback: (data) {
          _refreshImages();
        },
        forceLogoutCallback: () {
          _logout();
        },
      );
    }
    
    setState(() => _isLoading = false);
  }

  _loadImages() async {
    try {
      final response = await http.get(
        Uri.parse('http://178.63.171.244:8000/pending-images/$_userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _images = data['pending_images'] ?? []);
      }
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  _notifyServerOnline() async {
    if (_userId != null) {
      try {
        final fcmToken = await NotificationService.getFcmToken();
        await http.post(
          Uri.parse('http://178.63.171.244:8000/login'),
          body: {
            'user_id': _userId!,
            'fcm_token': fcmToken ?? 'unknown',
          },
        );
      } catch (e) {
        print('Error notifying online: $e');
      }
    }
  }

  _notifyServerOffline() async {
    if (_userId != null) {
      try {
        await http.post(
          Uri.parse('http://178.63.171.244:8000/logout'),
          body: {'user_id': _userId!},
        );
      } catch (e) {
        print('Error notifying offline: $e');
      }
    }
  }

  _startHeartbeat() {
    Future.delayed(Duration(seconds: 30), () {
      if (_userId != null && mounted) {
        http.post(
          Uri.parse('http://178.63.171.244:8000/heartbeat'),
          body: {'user_id': _userId!},
        );
        _startHeartbeat();
      }
    });
  }

  _logout() async {
    await _notifyServerOffline();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  _refreshImages() async {
    setState(() => _isLoading = true);
    await _loadImages();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Alert'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshImages),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(child: Text('تصویری موجود نیست'))
              : ListView.builder(
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Image.network(image['image_url'], height: 200, width: double.infinity, fit: BoxFit.cover),
                          ListTile(
                            title: Text(image['filename']),
                            subtitle: Text(_formatTime(image['timestamp'])),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }
}
