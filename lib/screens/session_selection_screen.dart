import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_models.dart';

class SessionSelectionScreen extends StatefulWidget {
  const SessionSelectionScreen({super.key});

  @override
  State<SessionSelectionScreen> createState() => _SessionSelectionScreenState();
}

class _SessionSelectionScreenState extends State<SessionSelectionScreen> {
  late List<TradingSession> _sessions;

  @override
  void initState() {
    super.initState();
    _loadCurrentSessions();
  }

  void _loadCurrentSessions() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final userSessions = provider.userSettings?.sessions ?? {};
    
    _sessions = TradingSession.allSessions.map((session) {
      return session.copyWith(
        isSelected: userSessions[session.code] ?? false,
      );
    }).toList();
  }

  void _toggleSession(String sessionCode) {
    setState(() {
      for (var session in _sessions) {
        if (session.code == sessionCode) {
          session.isSelected = !session.isSelected;
        }
      }
    });
    _saveSettings();
  }

  void _saveSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final currentSettings = provider.userSettings;
    
    if (currentSettings != null) {
      final newSessions = <String, bool>{};
      
      for (var session in _sessions) {
        newSessions[session.code] = session.isSelected;
      }
      
      final newSettings = currentSettings.copyWith(sessions: newSessions);
      provider.updateUserSettings(newSettings);
    }
  }

  Widget _buildSessionCard(TradingSession session) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: session.isSelected ? Colors.orange : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            session.isSelected ? Icons.access_time : Icons.schedule,
            color: session.isSelected ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          session.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: session.isSelected ? Colors.orange.shade800 : Colors.black87,
          ),
        ),
        subtitle: Text(
          session.timeRange,
          style: TextStyle(
            fontSize: 14,
            color: session.isSelected ? Colors.orange.shade600 : Colors.grey.shade600,
          ),
        ),
        trailing: Checkbox(
          value: session.isSelected,
          onChanged: (value) => _toggleSession(session.code),
        ),
        onTap: () => _toggleSession(session.code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب سشن'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'راهنمای انتخاب سشن:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• می‌توانید چندین سشن را همزمان انتخاب کنید\n'
                    '• سشن‌ها بر اساس زمان سرور GMT-3 محاسبه می‌شوند\n'
                    '• 🟢 = فعال، 🔴 = غیرفعال',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ..._sessions.map(_buildSessionCard),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سشن‌های انتخاب شده:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _sessions
                          .where((session) => session.isSelected)
                          .map((session) => Chip(
                                label: Text('${session.name} ${session.timeRange}'),
                                backgroundColor: Colors.orange.shade100,
                              ))
                          .toList(),
                    ),
                    if (_sessions.where((session) => session.isSelected).isEmpty)
                      const Text(
                        'هیچ سشنی انتخاب نشده است',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: FutureBuilder(
                  future: _getCurrentTimeInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final timeInfo = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اطلاعات زمانی فعلی:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('زمان سرور: ${timeInfo['currentTime']}'),
                          Text('سشن فعال: ${timeInfo['activeSessions']}'),
                        ],
                      );
                    }
                    return const Text('در حال دریافت اطلاعات زمانی...');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _getCurrentTimeInfo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final activeSessions = _sessions
        .where((session) => session.isSelected)
        .map((session) => session.name)
        .join(', ');
    
    return {
      'currentTime': currentTime,
      'activeSessions': activeSessions.isNotEmpty ? activeSessions : 'هیچکدام',
    };
  }
}
