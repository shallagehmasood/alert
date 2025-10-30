import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/signal_provider.dart';
import '../models/signal_model.dart';
import '../widgets/signal_popup.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  void _showImagePopup(BuildContext context, Signal signal) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SignalPopup(
        signal: signal,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<Signal> signals) {
    if (signals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'هنوز تصویری دریافت نشده',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'تصاویر سیگنال‌ها اینجا نمایش داده می‌شوند',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        return _buildImageCard(context, signal);
      },
    );
  }

  Widget _buildImageCard(BuildContext context, Signal signal) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showImagePopup(context, signal),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بخش تصویر
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: signal.imageData != null
                    ? Image.memory(
                        signal.imageData!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'خطا در بارگذاری',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, 
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'بدون تصویر',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            // اطلاعات پایین کارت
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        signal.pair,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: signal.signalType == 'BUY' 
                              ? Colors.green.shade100 
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          signal.timeframe,
                          style: TextStyle(
                            fontSize: 10,
                            color: signal.signalType == 'BUY' 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        signal.signalType == 'BUY' ? '🟢 BUY' : '🔴 SELL',
                        style: TextStyle(
                          fontSize: 12,
                          color: signal.signalType == 'BUY' 
                              ? Colors.green 
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        signal.displayTime,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'گالری تصاویر',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'تصاویر سیگنال‌هایی که دریافت می‌کنید در اینجا نمایش داده می‌شوند',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signalProvider = Provider.of<SignalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('گالری تصاویر'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              signalProvider.isConnected 
                  ? Icons.wifi 
                  : Icons.wifi_off,
              color: signalProvider.isConnected 
                  ? Colors.white 
                  : Colors.yellow,
            ),
            onPressed: () {},
            tooltip: signalProvider.isConnected ? 'متصل' : 'قطع',
          ),
          
          if (signalProvider.signals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                _showClearConfirmationDialog(context);
              },
              tooltip: 'پاک کردن همه',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: signalProvider.isConnected 
                ? Colors.green.shade50 
                : Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  signalProvider.isConnected 
                      ? Icons.check_circle 
                      : Icons.error,
                  color: signalProvider.isConnected 
                      ? Colors.green 
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  signalProvider.isConnected 
                      ? 'اتصال برقرار - آماده دریافت تصاویر' 
                      : 'اتصال قطع',
                  style: TextStyle(
                    color: signalProvider.isConnected 
                        ? Colors.green 
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          if (signalProvider.signals.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${signalProvider.signals.length} تصویر',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: signalProvider.signals.isEmpty
                ? _buildEmptyState()
                : _buildImageGrid(context, signalProvider.signals),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن همه تصاویر'),
        content: const Text('آیا از پاک کردن تمام تصاویر اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              context.read<SignalProvider>().clearSignals();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('همه تصاویر پاک شدند'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }
}
