class TradingMode {
  final String code;
  final String name;
  final String description;
  bool isSelected;

  TradingMode({
    required this.code,
    required this.name,
    required this.description,
    this.isSelected = false,
  });

  TradingMode copyWith({
    String? code,
    String? name,
    String? description,
    bool? isSelected,
  }) {
    return TradingMode(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<TradingMode> get allModes => [
    TradingMode(
      code: "A1",
      name: "هیدن اول",
      description: "هیدن اول",
    ),
    TradingMode(
      code: "A2", 
      name: "همه هیدن ها",
      description: "همه هیدن ها",
    ),
    TradingMode(
      code: "B",
      name: "مود B",
      description: "دایورجنس نبودن نقطه 2 در مکدی دیفالت اول 1",
    ),
    TradingMode(
      code: "C",
      name: "مود C", 
      description: "دایورجنس نبودن نقطه 2 در مکدی چهار برابر",
    ),
    TradingMode(
      code: "D",
      name: "مود D",
      description: "زده شدن سقف یا کف جدید نسبت به 52 کندل قبل",
    ),
    TradingMode(
      code: "E",
      name: "مود E",
      description: "عدم تناسب در نقطه 3 بین مکدی دیفالت و مووینگ 60",
    ),
    TradingMode(
      code: "F",
      name: "مود F",
      description: "از 2 تا 3 اصلاح مناسبی داشته باشد", 
    ),
    TradingMode(
      code: "G",
      name: "مود G",
      description: "دایورجنس نبودن نقطه 2 در مکدی دیفالت لول 2",
    ),
  ];
}

class TradingSession {
  final String code;
  final String name;
  final String timeRange;
  bool isSelected;

  TradingSession({
    required this.code,
    required this.name,
    required this.timeRange,
    this.isSelected = false,
  });

  TradingSession copyWith({
    String? code,
    String? name,
    String? timeRange,
    bool? isSelected,
  }) {
    return TradingSession(
      code: code ?? this.code,
      name: name ?? this.name,
      timeRange: timeRange ?? this.timeRange,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<TradingSession> get allSessions => [
    TradingSession(
      code: "TOKYO",
      name: "سشن توکیو",
      timeRange: "( 03:00-10:00)",
    ),
    TradingSession(
      code: "LONDON", 
      name: "سشن لندن",
      timeRange: "(19:00 - 22:00)",
    ),
    TradingSession(
      code: "NEWYORK",
      name: "سشن نیویورک", 
      timeRange: "(15:00 - 00:00)",
    ),
    TradingSession(
      code: "SYDNEY",
      name: "سشن سیدنی",
      timeRange: "(01:00 - 10:00)", 
    ),
  ];
}
