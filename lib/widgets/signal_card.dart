// widgets/signal_card.dart
class SignalCard extends StatelessWidget {
  final Signal signal;

  const SignalCard({Key? key, required this.signal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: signal.signalColor,
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هدر سیگنال
            Row(
              children: [
                Icon(
                  signal.signalType == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  '${signal.pair} • ${signal.timeframe}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // مود
            Text(
              _getModeName(signal.modeBits),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontFamily: 'Vazir',
              ),
            ),
            
            SizedBox(height: 4),
            
            // زمان
            Text(
              _formatTime(signal.timestamp),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontFamily: 'Vazir',
              ),
            ),
            
            SizedBox(height: 12),
            
            // دکمه مشاهده تصویر
            ElevatedButton(
              onPressed: () => _showImageDialog(context, signal),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text(
                'مشاهده تصویر',
                style: TextStyle(
                  color: signal.signalColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeName(String modeBits) {
    // منطق تبدیل بیت‌ها به نام مود
    if (modeBits[1] == '0') return 'هیدن اول';
    return 'همه هیدن‌ها';
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  void _showImageDialog(BuildContext context, Signal signal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: 'http://178.63.171.244:8000/screenshots/${signal.filename}',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 16),
            Text(
              signal.caption,
              style: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('بستن', style: TextStyle(fontFamily: 'Vazir')),
          ),
        ],
      ),
    );
  }
}
