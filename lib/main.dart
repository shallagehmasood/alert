@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Alert_X',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // ← اجبار به حالت روشن
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
      ),
    ),
    darkTheme: ThemeData( // اختیاری: اگر بخواهی حالت تاریک هم داشته باشی
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ),
    themeMode: ThemeMode.light, // ← همیشه از تم روشن استفاده کن
    home: MainScreen(userId: FIXED_USER_ID),
    locale: const Locale('fa', 'IR'),
    supportedLocales: const [Locale('fa', 'IR')],
  );
}
