// models/signal_model.dart
class Signal {
  final String pair;
  final String timeframe;
  final String modeBits;
  final String filename;
  final String timestamp;
  final String caption;

  Signal({
    required this.pair,
    required this.timeframe,
    required this.modeBits,
    required this.filename,
    required this.timestamp,
    required this.caption,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      pair: json['pair'] ?? '',
      timeframe: json['timeframe'] ?? '',
      modeBits: json['mode_bits'] ?? '',
      filename: json['filename'] ?? '',
      timestamp: json['timestamp'] ?? '',
      caption: json['caption'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pair': pair,
      'timeframe': timeframe,
      'mode_bits': modeBits,
      'filename': filename,
      'timestamp': timestamp,
      'caption': caption,
    };
  }

  String get signalType => modeBits[0] == '0' ? 'BUY' : 'SELL';
  
  Color get signalColor => signalType == 'BUY' ? Color(0xFF4CAF50) : Color(0xFFF44336);
  
  String get modeName {
    if (modeBits.length > 1) {
      if (modeBits[1] == '0') return 'هیدن اول';
      return 'همه هیدن‌ها';
    }
    return 'نامشخص';
  }

  String get formattedTime {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
