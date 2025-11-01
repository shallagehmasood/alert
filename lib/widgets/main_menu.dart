import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/pair_settings_screen.dart';
import '../screens/mode_selection_screen.dart';
import '../screens/session_selection_screen.dart';
import '../models/trading_pair.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('درباره ما'),
        content: const SingleChildScrollView(
          child: Text(
            'دوستانی که روی سیستم فرکتالی یا پرایس استاد امینو مسلط هستید '
            'حتما کلیپ های پین شده و کلا کانال رو مرور کنید اگه ارتباط گرفتید، '
            'تلگرام پیام بدید خبرای خوبی دارم\n\n'
            'https://t.me/avalinhidensignall/2703',
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showUsageGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نحوه استفاده از بات'),
        content: const SingleChildScrollView(
          child: Text(
            'جهت ران کردن ربات کلیپ زیر را تماشا کنید\n\n'
            'https://t.me/avalinhidensignall/2847\n\n'
            'آموزش نحوه بک تست گرفتن بات اولین هیدن\n\n'
            'به زودی...',
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _openChannel() async {
    const url = 'https://t.me/avalinhidensignall/1';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openVipBot() async {
    const url = 'https://t.me/Amino_First_Hidden_Alert_bot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openIchimokuBot() async {
    const url = 'https://t.me/Ichimoku_Alerts_bot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openFractalBot() async {
    const url = 'https://t.me/Fractal_Indicators_Alert_bot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildMenuButton(
    BuildContext context, // اضافه کردن context به پارامتر
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return Expanded(
      flex: isFullWidth ? 2 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget _buildPairButton(BuildContext context, String pairName) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PairSettingsScreen(pairName: pairName),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text(
            pairName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPairGrid(BuildContext context) {
    List<Widget> rows = [];
    
    for (int i = 0; i < TradingPair.pairs.length; i += 3) {
      List<Widget> rowPairs = [];
      
      for (int j = i; j < i + 3 && j < TradingPair.pairs.length; j++) {
        rowPairs.add(_buildPairButton(context, TradingPair.pairs[j]));
      }
      
      while (rowPairs.length < 3) {
        rowPairs.add(const Expanded(child: SizedBox()));
      }
      
      rows.add(Row(children: rowPairs));
    }
    
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuRow(context, [
            _buildMenuButton(
              context,
              'درباره ما',
              Icons.info,
              Colors.blue,
              () => _showAboutDialog(context),
            ),
            _buildMenuButton(
              context,
              'نحوه استفاده از بات',
              Icons.help,
              Colors.green,
              () => _showUsageGuide(context),
            ),
          ]),

          const SizedBox(height: 12),

          _buildMenuButton(
            context,
            'عضویت در کانال اولین هیدن',
            Icons.group,
            Colors.orange,
            _openChannel,
            isFullWidth: true,
          ),

          const SizedBox(height: 12),

          _buildMenuButton(
            context,
            'First_Hidden_bot VIP 👑',
            Icons.workspace_premium,
            Colors.purple,
            _openVipBot,
            isFullWidth: true,
          ),

          const SizedBox(height: 12),

          _buildMenuRow(context, [
            _buildMenuButton(
              context,
              'Ichimoku_bot',
              Icons.show_chart,
              Colors.red,
              _openIchimokuBot,
            ),
            _buildMenuButton(
              context,
              'Fractal_Indicators_bot',
              Icons.polyline,
              Colors.teal,
              _openFractalBot,
            ),
          ]),

          const SizedBox(height: 24),

          ..._buildPairGrid(context),

          const SizedBox(height: 24),

          _buildMenuRow(context, [
            _buildMenuButton(
              context,
              'انتخاب مود',
              Icons.settings,
              Colors.indigo,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeSelectionScreen(),
                  ),
                );
              },
            ),
            _buildMenuButton(
              context,
              'انتخاب سشن',
              Icons.access_time,
              Colors.deepOrange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SessionSelectionScreen(),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
