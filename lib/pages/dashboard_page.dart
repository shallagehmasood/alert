// pages/dashboard_page.dart
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _startSignalPolling();
  }

  void _startSignalPolling() {
    // پولینگ هر ۵ ثانیه
    Timer.periodic(Duration(seconds: 5), (timer) async {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.getSignals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اولین هیدن', style: TextStyle(fontFamily: 'Vazir')),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.show_chart), text: 'سیگنال‌ها'),
            Tab(icon: Icon(Icons.settings), text: 'تنظیمات'),
            Tab(icon: Icon(Icons.currency_exchange), text: 'جفت‌ارزها'),
            Tab(icon: Icon(Icons.person), text: 'پروفایل'),
          ],
          labelStyle: TextStyle(fontFamily: 'Vazir'),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SignalsPage(),
          SettingsPage(),
          PairsPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
