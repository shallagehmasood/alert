// pages/login_page.dart
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // لوگو
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up, size: 60, color: Colors.white),
                ),
                
                SizedBox(height: 32),
                
                Text(
                  'به اولین هیدن خوش آمدید',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'سامانه هوشمند سیگنال‌دهی فارکس',
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontFamily: 'Vazir',
                  ),
                ),
                
                SizedBox(height: 48),
                
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'شناسه کاربری',
                    labelStyle: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Vazir'),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2196F3)),
                  ),
                  style: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
                ),
                
                SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'شروع کنید',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'قبلاً ثبت‌نام کرده‌اید؟',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontFamily: 'Vazir',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفاً شناسه کاربری را وارد کنید', style: TextStyle(fontFamily: 'Vazir'))),
      );
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.registerUser(_userIdController.text);
    
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ثبت‌نام', style: TextStyle(fontFamily: 'Vazir'))),
      );
    }
  }
}
