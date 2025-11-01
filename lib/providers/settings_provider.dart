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

  Widget _buildSignalItem(BuildContext context, Signal signal, SignalProvider signalProvider) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          // هدر آیتم
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: signal.signalType == 'BUY' ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: signal.signalType == 'BUY' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    signal.signalType == 'BUY' ? '🟢 BUY' : '🔴 SELL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  signal.pair,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  signal.timeframe,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  signal.displayTime,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // تصویر
          GestureDetector(
            onTap: () => _showImagePopup(context, signal),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
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
                              'خطا در بارگذاری تصویر',
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
                        Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
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
          
          // دکمه حذف
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, signal, signalProvider);
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('حذف از اپ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          // وضعیت اتصال
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
          
          // تعداد تصاویر
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
          
          // لیست تصاویر
          Expanded(
            child: signalProvider.signals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: signalProvider.signals.length,
                    itemBuilder: (context, index) {
                      final signal = signalProvider.signals[index];
                      return _buildSignalItem(context, signal, signalProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Signal signal, SignalProvider signalProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تصویر'),
        content: const Text('آیا می‌خواهید این تصویر فقط از اپلیکیشن حذف شود؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              // حذف فقط از اپلیکیشن
              signalProvider.removeSignalFromApp(signal);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تصویر از اپلیکیشن حذف شد'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
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
        content: const Text('آیا از پاک کردن تمام تصاویر از اپلیکیشن اطمینان دارید؟'),
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
                  content: Text('همه تصاویر از اپلیکیشن پاک شدند'),
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
