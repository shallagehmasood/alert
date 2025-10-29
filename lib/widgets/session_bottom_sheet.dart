import 'package:flutter/material.dart';

const Map<String, String> DISPLAY_SESSIONS = {
  "TOKYO": "سشن توکیو ‎( 03:00-10:00)",
  "LONDON": "سشن لندن ‎(19:00 - 22:00)",
  "NEWYORK": "سشن نیویورک ‎(15:00 - 00:00)",
  "SYDNEY": "سشن سیدنی ‎(01:00 - 10:00)"
};

class SessionBottomSheet extends StatefulWidget {
  final Map<String, bool> initial;
  final void Function(Map<String, bool> result) onSave;

  const SessionBottomSheet({super.key, required this.initial, required this.onSave});

  @override
  State<SessionBottomSheet> createState() => _SessionBottomSheetState();
}

class _SessionBottomSheetState extends State<SessionBottomSheet> {
  late Map<String, bool> temp;

  @override
  void initState() {
    super.initState();
    temp = Map<String, bool>.from({
      for (var k in DISPLAY_SESSIONS.keys) k: widget.initial[k] == true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(12)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('انتخاب سشن‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...DISPLAY_SESSIONS.keys.map((k) {
                return SwitchListTile(
                  title: Text(DISPLAY_SESSIONS[k]!),
                  value: temp[k] ?? false,
                  onChanged: (v) => setState(() => temp[k] = v),
                );
              }).toList(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(temp);
                      Navigator.pop(context);
                    },
                    child: const Text('ذخیره'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
