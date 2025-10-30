import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/trading_pair.dart';

class PairSettingsScreen extends StatefulWidget {
  final String pairName;
  
  const PairSettingsScreen({
    super.key,
    required this.pairName,
  });

  @override
  State<PairSettingsScreen> createState() => _PairSettingsScreenState();
}

class _PairSettingsScreenState extends State<PairSettingsScreen> {
  late Map<String, bool> _timeframeStatus;
  late String _signalType;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final pairData = provider.userSettings?.timeframes[widget.pairName] ?? {};
    
    _timeframeStatus = {};
    for (var tf in TradingPair.timeframes) {
      _timeframeStatus[tf] = pairData[tf] ?? false;
    }
    
    _signalType = pairData['signal'] ?? 'BUYSELL';
  }

  void _toggleTimeframe(String timeframe) {
    setState(() {
      _timeframeStatus[timeframe] = !(_timeframeStatus[timeframe] ?? false);
    });
    _saveSettings();
  }

  void _setSignalType(String signalType) {
    setState(() {
      _signalType = signalType;
    });
    _saveSettings();
  }

  void _saveSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final currentSettings = provider.userSettings;
    
    if (currentSettings != null) {
      final newTimeframes = Map<String, dynamic>.from(currentSettings.timeframes);
      
      newTimeframes[widget.pairName] = {
        ..._timeframeStatus,
        'signal': _signalType,
      };
      
      final newSettings = currentSettings.copyWith(timeframes: newTimeframes);
      provider.updateUserSettings(newSettings);
    }
  }

  Widget _buildTimeframeButton(String timeframe) {
    final isActive = _timeframeStatus[timeframe] ?? false;
    
    return Container(
      margin: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => _toggleTimeframe(timeframe),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.green : Colors.grey.shade300,
          foregroundColor: isActive ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          '${isActive ? '🟢' : '🔴'} $timeframe',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSignalButton(String signalType, String displayText) {
    final isActive = _signalType == signalType;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _setSignalType(signalType),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.blue : Colors.grey.shade300,
            foregroundColor: isActive ? Colors.white : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '${isActive ? '🟢' : '🔴'} $displayText',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تنظیمات ${widget.pairName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تایم‌فریم‌ها:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              children: TradingPair.timeframes.map(_buildTimeframeButton).toList(),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'نوع سیگنال:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildSignalButton('BUY', 'BUY'),
                _buildSignalButton('SELL', 'SELL'),
                _buildSignalButton('BUYSELL', 'BUYSELL'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'راهنما:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🟢 = فعال\n🔴 = غیرفعال\n\n'
                    'تایم‌فریم‌های فعال برای این جفت ارز دریافت خواهند شد.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
