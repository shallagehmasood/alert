class UserImage {
  final String filename;
  final String pair;
  final String timeframe;
  final String signalType;
  final String modeBits;
  final DateTime timestamp;
  final int fileSize;
  final String created_at;
  final bool isSavedLocally;

  UserImage({
    required this.filename,
    required this.pair,
    required this.timeframe,
    required this.signalType,
    required this.modeBits,
    required this.timestamp,
    required this.fileSize,
    required this.created_at,
    this.isSavedLocally = false,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      filename: json['filename'],
      pair: json['pair'],
      timeframe: json['timeframe'],
      signalType: json['signal_type'],
      modeBits: json['mode_bits'],
      timestamp: DateTime.parse(json['timestamp']),
      fileSize: json['file_size'] ?? 0,
      created_at: json['created_at'] ?? json['timestamp'],
    );
  }

  String get imageUrl => 'http://178.63.171.244:8000/user/{user_id}/image/$filename';

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

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize بایت';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} کیلوبایت';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} مگابایت';
    }
  }
}
