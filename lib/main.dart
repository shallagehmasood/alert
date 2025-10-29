import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← اضافه شد
import '../services/api_service.dart';

const Map<String, String> DISPLAY_MODES = {
  "A1": "هیدن اول",
  "A2": "همه هیدن ها",
  "B": "دایورجنس نبودن نقطه 2 در مکدی دیفالت اول 1 ",
  "C": "دایورجنس نبودن نقطه 2 در مکدی چهار برابر",
  "D": "زده شدن سقف یا کف جدید نسبت به 52 کندل قبل",
  "E": "عدم تناسب در نقطه 3 بین مکدی دیفالت و مووینگ 60",
  "F": "از 2 تا 3 اصلاح مناسبی داشته باشد",
  "G": "دایورجنس نبودن نقطه 2 در مکدی دیفالت لول 2 ",
};

class ModesScreen extends StatefulWidget {
  final String userId;
  const ModesScreen({super.key, required this.userId});

  @override
  _ModesScreenState createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  final ApiService _api = ApiService();
  Map<String, bool> _modes = {};
  bool _loading = true;

  // ذخیره در حافظه محلی
  Future<void> _saveLocalModes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'modes_${widget.userId}',
      _modes.entries.where((e) => e.value).map((e) => e.key).toList(),
    );
  }

  // بارگذاری از حافظه محلی
  Future<void> _loadLocalModes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('modes_${widget.userId}') ?? [];
    setState(() {
      _modes = {
        for (var mode in ['A1', 'A2', 'B', 'C', 'D', 'E', 'F', 'G'])
          mode: saved.contains(mode)
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    try {
      // اول از حافظه محلی بارگذاری کن
      await _loadLocalModes();

      // سپس از سرور هم بارگذاری کن (اگر آفلاین نیست)
      final data = await _api.getSettings(widget.userId);
      final serverModes = (data['modes'] as Map?) ?? {};
      setState(() {
        _modes = {
          for (var mode in ['A1', 'A2', 'B', 'C', 'D', 'E', 'F', 'G'])
            mode: serverModes[mode] == true
        };
        // ذخیره دوباره در حافظه محلی
        _saveLocalModes();
      });
    } catch (e) {
      // اگر سرور در دسترس نیست، فقط از حافظه محلی استفاده کن
      await _loadLocalModes();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleMode(String mode) async {
    setState(() {
      if (mode == 'A1') {
        _modes['A1'] = true;
        _modes['A2'] = false;
      } else if (mode == 'A2') {
        _modes['A1'] = false;
        _modes['A2'] = true;
      } else {
        _modes[mode] = !(_modes[mode] ?? false);
      }
    });

    // ذخیره در حافظه محلی
    await _saveLocalModes();

    try {
      // ذخیره در سرور
      await _api.saveSettings(widget.userId, {
        'timeframes': {},
        'modes': _modes,
        'sessions': {},
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'ذخیره در سرور نشد (آفلاین؟)');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('انتخاب مود')),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeTile('A1', DISPLAY_MODES['A1']!),
                _buildModeTile('A2', DISPLAY_MODES['A2']!),
              ],
            ),
            const Divider(height: 30),
            for (var mode in ['B', 'C', 'D', 'E', 'F', 'G'])
              _buildModeTile(mode, DISPLAY_MODES[mode]!),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile(String key, String label) {
    final isActive = _modes[key] ?? false;
    return ListTile(
      title: Text(label),
      leading: Icon(
        isActive ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isActive ? Colors.green : Colors.grey,
      ),
      onTap: () => _toggleMode(key),
    );
  }
}
