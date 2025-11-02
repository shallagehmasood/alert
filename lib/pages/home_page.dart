import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<dynamic> _images = [];
  List<dynamic> _pendingImages = [];
  bool _isLoading = true;
  String? _userId;
  List<String> _userPairs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logout();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // اپ به پس‌زمینه رفت
      _notifyServerOffline();
    } else if (state == AppLifecycleState.resumed) {
      // اپ به پیش‌زمینه برگشت
      _notifyServerOnline();
      _loadPendingImages();
    }
  }

  _initialize() async {
    _userId = await AuthService.getCurrentUser();
    if (_userId == null) {
      _goToLogin();
      return;
    }
    
    await _notifyServerOnline();
    await _loadUserData();
    await _loadPendingImages();
    
    setState(() => _isLoading = false);
    
    // شروع ارسال heartbeat
    _startHeartbeat();
  }

  _loadUserData() async {
    // در اینجا می‌تونی اطلاعات کاربر رو از سرور بگیری
    // فعلاً از localStorage استفاده می‌کنیم
  }

  _loadPendingImages() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/pending-images/$_userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pendingImages = data['pending_images'] ?? [];
          _images = _pendingImages;
        });
      }
    } catch (e) {
      print('Error loading pending images: $e');
    }
  }

  _startHeartbeat() {
    // ارسال heartbeat هر 30 ثانیه
    Future.delayed(Duration(seconds: 30), () {
      if (_userId != null && mounted) {
        AuthService.sendHeartbeat(_userId!);
        _startHeartbeat();
      }
    });
  }

  _notifyServerOnline() async {
    final fcmToken = await NotificationService.getFcmToken();
    if (_userId != null && fcmToken != null) {
      try {
        await http.post(
          Uri.parse('${AuthService.baseUrl}/login'),
          body: {
            'user_id': _userId!,
            'fcm_token': fcmToken,
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
          Uri.parse('${AuthService.baseUrl}/logout'),
          body: {'user_id': _userId!},
        );
      } catch (e) {
        print('Error notifying offline: $e');
      }
    }
  }

  _logout() async {
    await _notifyServerOffline();
    await AuthService.logout();
    _goToLogin();
  }

  _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  _refreshImages() async {
    setState(() => _isLoading = true);
    await _loadPendingImages();
    setState(() => _isLoading = false);
  }

  _buildImageItem(Map<String, dynamic> image) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Column(
        children: [
          // نمایش تصویر
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(image['image_url']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // اطلاعات تصویر
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.image, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    image['filename'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  _formatTimestamp(image['timestamp']),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Photo Alert',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // دکمه رفرش
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshImages,
          ),
          
          // دکمه خروج
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'تصویری موجود نیست',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'تصاویر جدید به صورت خودکار نمایش داده می‌شوند',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _refreshImages(),
                  child: ListView.builder(
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return _buildImageItem(_images[index]);
                    },
                  ),
                ),

      // نمایش وضعیت کاربر
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(top: BorderSide(color: Colors.blue[100]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 16, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'کاربر: $_userId',
              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 16),
            Icon(Icons.circle, size: 12, color: Colors.green),
            SizedBox(width: 4),
            Text(
              'آنلاین',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
