// models/constants_model.dart
class TradingPair {
  final String symbol;
  final String name;
  final String category;

  const TradingPair({
    required this.symbol,
    required this.name,
    required this.category,
  });

  static const List<TradingPair> allPairs = [
    TradingPair(symbol: 'EURUSD', name: 'یورو/دلار', category: 'Major'),
    TradingPair(symbol: 'GBPUSD', name: 'پوند/دلار', category: 'Major'),
    TradingPair(symbol: 'USDJPY', name: 'دلار/ین', category: 'Major'),
    TradingPair(symbol: 'USDCHF', name: 'دلار/فرانک', category: 'Major'),
    TradingPair(symbol: 'AUDUSD', name: 'دلار استرالیا/دلار', category: 'Major'),
    TradingPair(symbol: 'USDCAD', name: 'دلار/دلار کانادا', category: 'Major'),
    TradingPair(symbol: 'XAUUSD', name: 'طلا/دلار', category: 'Commodity'),
    TradingPair(symbol: 'XAGUSD', name: 'نقره/دلار', category: 'Commodity'),
    TradingPair(symbol: 'BTCUSD', name: 'بیت‌کوین/دلار', category: 'Crypto'),
    TradingPair(symbol: 'ETHUSD', name: 'اتریوم/دلار', category: 'Crypto'),
  ];
}

class Timeframe {
  final String value;
  final String label;
  final int minutes;

  const Timeframe({
    required this.value,
    required this.label,
    required this.minutes,
  });

  static const List<Timeframe> allTimeframes = [
    Timeframe(value: 'M1', label: 'M1 (1 دقیقه)', minutes: 1),
    Timeframe(value: 'M5', label: 'M5 (5 دقیقه)', minutes: 5),
    Timeframe(value: 'M15', label: 'M15 (15 دقیقه)', minutes: 15),
    Timeframe(value: 'M30', label: 'M30 (30 دقیقه)', minutes: 30),
    Timeframe(value: 'H1', label: 'H1 (1 ساعت)', minutes: 60),
    Timeframe(value: 'H4', label: 'H4 (4 ساعت)', minutes: 240),
    Timeframe(value: 'D1', label: 'D1 (1 روز)', minutes: 1440),
    Timeframe(value: 'W1', label: 'W1 (1 هفته)', minutes: 10080),
  ];
}

class TradingMode {
  final String code;
  final String name;
  final String description;

  const TradingMode({
    required this.code,
    required this.name,
    required this.description,
  });

  static const List<TradingMode> allModes = [
    TradingMode(
      code: 'A1',
      name: 'هیدن اول',
      description: 'فقط سیگنال‌های هیدن اول',
    ),
    TradingMode(
      code: 'A2',
      name: 'همه هیدن‌ها',
      description: 'تمام سیگنال‌های هیدن',
    ),
    TradingMode(
      code: 'B',
      name: 'دایورجنس نبودن نقطه ۲ (مکدی دیفالت)',
      description: 'عدم دایورجنس در نقطه ۲ با مکدی پیش‌فرض',
    ),
    TradingMode(
      code: 'C',
      name: 'دایورجنس نبودن نقطه ۲ (مکدی چهاربرابر)',
      description: 'عدم دایورجنس در نقطه ۲ با مکدی چهاربرابر',
    ),
    TradingMode(
      code: 'D',
      name: 'زده شدن سقف یا کف جدید',
      description: 'شکست سقف یا کف قبلی در ۵۲ کندل گذشته',
    ),
    TradingMode(
      code: 'E',
      name: 'عدم تناسب در نقطه ۳',
      description: 'عدم تناسب بین مکدی دیفالت و مووینگ ۶۰',
    ),
    TradingMode(
      code: 'F',
      name: 'اصلاح مناسب از ۲ تا ۳',
      description: 'اصلاح قیمتی مناسب بین نقاط ۲ و ۳',
    ),
    TradingMode(
      code: 'G',
      name: 'دایورجنس نبودن نقطه ۲ (مکدی دیفالت لول ۲)',
      description: 'عدم دایورجنس در نقطه ۲ با مکدی پیش‌فرض لول ۲',
    ),
  ];
}

class TradingSession {
  final String code;
  final String name;
  final String timeRange;

  const TradingSession({
    required this.code,
    required this.name,
    required this.timeRange,
  });

  static const List<TradingSession> allSessions = [
    TradingSession(
      code: 'TOKYO',
      name: 'سشن توکیو',
      timeRange: '03:00-10:00',
    ),
    TradingSession(
      code: 'LONDON',
      name: 'سشن لندن',
      timeRange: '19:00-22:00',
    ),
    TradingSession(
      code: 'NEWYORK',
      name: 'سشن نیویورک',
      timeRange: '15:00-00:00',
    ),
    TradingSession(
      code: 'SYDNEY',
      name: 'سشن سیدنی',
      timeRange: '01:00-10:00',
    ),
  ];
}
