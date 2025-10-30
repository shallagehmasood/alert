import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_hidden_app/services/api_service.dart';
import 'package:first_hidden_app/services/notification_service.dart';
import 'package:first_hidden_app/pages/login_page.dart';
import 'package:first_hidden_app/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => UserSettings()),
      ],
      child: MaterialApp(
        title: 'اولین هیدن',
        theme: ThemeData(
          primaryColor: Color(0xFF2196F3),
          primaryColorDark: Color(0xFF1976D2),
          accentColor: Color(0xFFFF9800),
          backgroundColor: Color(0xFF121212),
          scaffoldBackgroundColor: Color(0xFF121212),
          cardColor: Color(0xFF1E1E1E),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
            bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Vazir'),
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Vazir'),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
        ),
        home: LoginPage(),
      ),
    );
  }
}
