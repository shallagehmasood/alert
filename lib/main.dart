import 'package:flutter/material.dart';
import 'screens/main_screen.dart';


// 👇 شناسه کاربری ثابت (همان عددی که در whitelist.json سرور است)
const String FIXED_USER_ID = "123456789"; // ← اینجا شناسه واقعی خودت را بگذار


void main() {
runApp(const MyApp());
}


class MyApp extends StatelessWidget {
const MyApp({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Alert_X',
debugShowCheckedModeBanner: false,
theme: ThemeData(
useMaterial3: true,
brightness: Brightness.light,
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
textTheme: const TextTheme(
bodyMedium: TextStyle(color: Colors.black),
titleLarge: TextStyle(color: Colors.black),
),
),
darkTheme: ThemeData(
useMaterial3: true,
brightness: Brightness.dark,
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
),
themeMode: ThemeMode.light,
home: MainScreen(userId: FIXED_USER_ID),
locale: const Locale('fa', 'IR'),
supportedLocales: const [Locale('fa', 'IR')],
);
}
}
