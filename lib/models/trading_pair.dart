class TradingPair {
  final String name;
  final Map<String, bool> timeframeStatus;
  final String signalType;

  TradingPair({
    required this.name,
    required this.timeframeStatus,
    required this.signalType,
  });

  static const List<String> pairs = [
    "EURUSD", "GBPUSD", "USDJPY", "USDCHF",
    "AUDUSD", "AUDJPY", "CADJPY", "EURJPY", "BTCUSD",
    "USDCAD", "GBPJPY", "ADAUSD", "BRENT", "XAUUSD", "XAGUSD",
    "ETHUSD", "DowJones30", "Nasdaq100"
  ];

  static const List<String> timeframes = [
    "M1", "M2", "M3", "M4", "M5", "M6",
    "M10", "M12", "M15", "M20", "M30", "H1",
    "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1"
  ];
}
