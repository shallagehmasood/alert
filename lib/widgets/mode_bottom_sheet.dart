import 'package:flutter/material.dart';

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

class ModeBottomSheet extends StatefulWidget {
  final Map<String, bool> initial;
  final void Function(Map<String, bool> result) onSave;
  final ScrollController? scrollController;

  const ModeBottomSheet({
    super.key,
    required this.initial,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<ModeBottomSheet> createState() => _ModeBottomSheetState();
}

class _ModeBottomSheetState extends State<ModeBottomSheet> {
  late Map<String, bool> temp;
  late String selectedA;

  @override
  void initState() {
    super.initState();
    temp = Map<String, bool>.from({
      for (var k in DISPLAY_MODES.keys) k: widget.initial[k] == true,
    });
    selectedA = temp['A1'] == true ? 'A1' : temp['A2'] == true ? 'A2' : '';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(12),
      children: [
        const Text('انتخاب مودها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          title: Text(DISPLAY_MODES['A1']!),
          leading: Radio<String>(
            value: 'A1',
            groupValue: selectedA,
            onChanged: (_) {
              setState(() {
                selectedA = 'A1';
                temp['A1'] = true;
                temp['A2'] = false;
              });
            },
          ),
          onTap: () {
            setState(() {
              selectedA = 'A1';
              temp['A1'] = true;
              temp['A2'] = false;
            });
          },
        ),
        ListTile(
          title: Text(DISPLAY_MODES['A2']!),
          leading: Radio<String>(
            value: 'A2',
            groupValue: selectedA,
            onChanged: (_) {
              setState(() {
                selectedA = 'A2';
                temp['A1'] = false;
                temp['A2'] = true;
              });
            },
          ),
          onTap: () {
            setState(() {
              selectedA = 'A2';
              temp['A1'] = false;
              temp['A2'] = true;
            });
          },
        ),
        const SizedBox(height: 6),
        ...['B', 'C', 'D', 'E', 'F', 'G'].map((k) {
          return CheckboxListTile(
            title: Text(DISPLAY_MODES[k]!),
            value: temp[k] ?? false,
            onChanged: (v) => setState(() => temp[k] = v ?? false),
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
    );
  }
}
