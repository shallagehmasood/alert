import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/signal_provider.dart';
import '../models/signal_model.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signalProvider = Provider.of<SignalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سیگنال‌های لحظه‌ای'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(signalProvider.isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {},
            tooltip: signalProvider.isConnected ? 'متصل' : 'قطع',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: signalProvider.clearSignals,
            tooltip: 'پاک کردن همه',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: signalProvider.isConnected ? Colors.green.shade50 : Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  signalProvider.isConnected ? Icons.check_circle : Icons.error,
                  color: signalProvider.isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  signalProvider.isConnected ? 'اتصال برقرار' : 'اتصال قطع',
                  style: TextStyle(
                    color: signalProvider.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: signalProvider.signals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'هنوز سیگنالی دریافت نشده',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: signalProvider.signals.length,
                    itemBuilder: (context, index) {
                      final signal = signalProvider.signals[index];
                      return _buildSignalCard(signal);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalCard(Signal signal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: signal.signalType == 'BUY' ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            signal.signalType == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward,
            color: signal.signalType == 'BUY' ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              signal.pair,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              signal.timeframe,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                backgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(signal.displaySignalType),
            const SizedBox(height: 4),
            Text(
              signal.displayTime,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            _copySignalInfo(signal);
          },
          tooltip: 'کپی اطلاعات',
        ),
      ),
    );
  }

  void _copySignalInfo(Signal signal) {
    final copyText = '${signal.pair} - ${signal.timeframe} - ${signal.signalType}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('اطلاعات $copyText کپی شد'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
