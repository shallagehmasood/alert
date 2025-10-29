import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'pair_settings_screen.dart';
import 'modes_screen.dart';
import 'sessions_screen.dart';
import 'alerts_screen.dart';

const List<String> PAIRS = [
  "EURUSD", "GBPUSD", "USDJPY", "USDCHF",
  "AUDUSD", "AUDJPY", "CADJPY", "EURJPY", "BTCUSD",
  "USDCAD", "GBPJPY", "ADAUSD", "BRENT", "XAUUSD", "XAGUSD",
  "ETHUSD", "DowJones30", "Nasdaq100"
];

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _api = ApiService();

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alert_X'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'سیگنال‌ها'),
              Tab(text: 'تنظیمات'),
              Tab(text: 'درباره ما'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AlertsScreen(userId: widget.userId),
            _buildSettingsTab(),
            _buildAboutTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لطفاً یک جفت ارز، مود یا سشن انتخاب کنید:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildButton('انتخاب مود', () => _navigateTo(context, ModesScreen(userId: widget.userId))),
                _buildButton('انتخاب سشن', () => _navigateTo(context, SessionsScreen(userId: widget.userId))),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: PAIRS.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PairSettingsScreen(
                            userId: widget.userId,
                            pair: PAIRS[index],
                          ),
                        ),
                      );
                    },
                    child: Text(PAIRS[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildAboutTab() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'دوستانی که روی سیستم فرکتالی یا پرایس استاد امینو مسلط هستند '
              'حتما کلیپ های پین شده و کانال را مرور کنند. اگر ارتباط گرفتید، '
              'تلگرام پیام بدید — خبرهای خوبی دارم.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildLinkButton('مشاهده کانال اولین هیدن', 'https://t.me/avalinhidensignall/2703'),
            const SizedBox(height: 16),
            _buildLinkButton('آموزش نحوه بک‌تست', 'https://t.me/avalinhidensignall/2847'),
            const SizedBox(height: 16),
            _buildLinkButton('بات اولین هیدن VIP', 'https://t.me/Amino_First_Hidden_Alert_bot'),
            const SizedBox(height: 16),
            _buildLinkButton('بات اندیکاتورهای فرکتالی', 'https://t.me/Fractal_Indicators_Alert_bot'),
            const SizedBox(height: 16),
            _buildLinkButton('بات ایچیموکو', 'https://t.me/Ichimoku_Alerts_bot'),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(String label, String url) {
    return ElevatedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url.trim());
        if (!await launchUrl(uri)) {
          Fluttertoast.showToast(msg: 'عدم توانایی در باز کردن لینک');
        }
      },
      icon: const Icon(Icons.link, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade400),
    );
  }
}
