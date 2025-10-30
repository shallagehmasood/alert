// lib/services/notification_service.dart
import 'dart:async';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Initialize notifications
    print('Notification service initialized');
  }

  void showNotification(String title, String body) {
    // Implementation for showing local notifications
    print('Notification: $title - $body');
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Vazir')),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
