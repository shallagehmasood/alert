// lib/models/signal_model.dart
import 'dart:typed_data';
import 'dart:convert';

class Signal {
  final String pair;
  final String timeframe;
  final String signalType;
  final String modeBits;
  final DateTime timestamp;
  final Uint8List? imageData;

  Signal({
    required this.pair,
    required this.timeframe,
    required this.signalType,
    required this.modeBits,
    required this.timestamp,
    this.imageData,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;
    if (json['image_data'] != null) {
      try {
        imageData = base64.decode(json['image_data']);
      } catch (e) {
        print('خطا در decode تصویر: $e');
      }
    }

    return Signal(
      pair: json['pair'],
      timeframe: json['timeframe'],
      signalType: json['signal_type'],
      modeBits: json['mode_bits'],
      timestamp: DateTime.parse(json['timestamp']),
      imageData: imageData,
    );
  }

  String get displaySignalType {
    return signalType == 'BUY' ? '🟢 BUY' : '🔴 SELL';
  }

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'همین الان';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقیقه قبل';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعت قبل';
    } else {
      return '${difference.inDays} روز قبل';
    }
  }
}
