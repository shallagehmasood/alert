// pages/settings_page.dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettings>(
      builder: (context, userSettings, child) {
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // مودهای معاملاتی
            _buildSection('🎯 مودهای معاملاتی', [
              _buildModeToggle('هیدن اول', 'A1', userSettings),
              _buildModeToggle('همه هیدن‌ها', 'A2', userSettings),
              _buildModeToggle('دایورجنس نبودن نقطه ۲ (مکدی دیفالت)', 'B', userSettings),
              _buildModeToggle('دایورجنس نبودن نقطه ۲ (مکدی چهاربرابر)', 'C', userSettings),
              _buildModeToggle('زده شدن سقف یا کف جدید', 'D', userSettings),
              _buildModeToggle('عدم تناسب در نقطه ۳', 'E', userSettings),
              _buildModeToggle('اصلاح مناسب از ۲ تا ۳', 'F', userSettings),
              _buildModeToggle('دایورجنس نبودن نقطه ۲ (مکدی دیفالت لول ۲)', 'G', userSettings),
            ]),

            SizedBox(height: 24),

            // سشن‌های معاملاتی
            _buildSection('🌍 سشن‌های معاملاتی', [
              _buildSessionToggle('سشن توکیو (03:00-10:00)', 'TOKYO', userSettings),
              _buildSessionToggle('سشن لندن (19:00-22:00)', 'LONDON', userSettings),
              _buildSessionToggle('سشن نیویورک (15:00-00:00)', 'NEWYORK', userSettings),
              _buildSessionToggle('سشن سیدنی (01:00-10:00)', 'SYDNEY', userSettings),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: Color(0xFF1E1E1E),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(String label, String mode, UserSettings userSettings) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(color: Colors.white, fontFamily: 'Vazir')),
      value: userSettings.modes[mode] ?? false,
      onChanged: (value) => userSettings.toggleMode(mode, value),
      activeColor: Color(0xFF2196F3),
    );
  }

  Widget _buildSessionToggle(String label, String session, UserSettings userSettings) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(color: Colors.white, fontFamily: 'Vazir')),
      value: userSettings.sessions[session] ?? false,
      onChanged: (value) => userSettings.toggleSession(session, value),
      activeColor: Color(0xFF2196F3),
    );
  }
}
