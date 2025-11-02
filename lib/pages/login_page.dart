import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initialize();
    _checkExistingUser();
  }

  _initialize() async {
    await NotificationService.initialize();
    _fcmToken = await NotificationService.getFcmToken();
  }

  _checkExistingUser() async {
    if (await AuthService.isUserLoggedIn()) {
      final userId = await AuthService.getCurrentUser();
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  _login() async {
    if (_userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفاً شناسه را وارد کنید')),
      );
      return;
    }

    if (_fcmToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در دریافت توکن نوتیفیکیشن')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.loginUser(_userIdController.text, _fcmToken!);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ورود: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
              // آیکون یا لوگو
              Icon(
                Icons.photo_library,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              
              // عنوان
              Text(
                'Photo Alert',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              
              Text(
                'ورود به سیستم',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 40),
              
              // فیلد ورود شناسه
              TextField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'شناسه ۳ رقمی',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.security),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                maxLength: 3,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              
              // دکمه ورود
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'ورود',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
