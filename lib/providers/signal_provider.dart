// اضافه کردن این متد به کلاس SignalProvider
void removeSignalFromApp(Signal signal) {
  _signals.remove(signal);
  notifyListeners();
  print('🗑️ سیگنال از اپلیکیشن حذف شد: ${signal.pair} - ${signal.timeframe}');
}
