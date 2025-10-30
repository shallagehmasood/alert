class Signal {
  final String pair;
  final String timeframe;
  final String signalType;
  final String modeBits;
  final DateTime timestamp;
  final String? imageUrl;

  Signal({
    required this.pair,
    required this.timeframe,
    required this.signalType,
    required this.modeBits,
    required this.timestamp,
    this.imageUrl,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      pair: json['pair'],
      timeframe: json['timeframe'],
      signalType: json['signal_type'],
      modeBits: json['mode_bits'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
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
