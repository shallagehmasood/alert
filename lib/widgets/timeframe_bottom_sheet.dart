import 'package:flutter/material.dart';

const List<String> TIMEFRAMES = [
  "M1", "M2", "M3", "M4", "M5", "M6",
  "M10", "M12", "M15", "M20", "M30", "H1",
  "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1"
];

class TimeframeBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialPairData;
  final void Function(Map<String, dynamic> pairData) onSave;
  final ScrollController? scrollController;

  const TimeframeBottomSheet({
    super.key,
    required this.initialPairData,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<TimeframeBottomSheet> createState() => _TimeframeBottomSheetState();
}

class _TimeframeBottomSheetState extends State<TimeframeBottomSheet> {
  late Map<String, dynamic> temp;

  @override
  void initState() {
    super.initState();
    temp = Map<String, dynamic>.from(widget.initialPairData);
    temp['signal'] = temp['signal'] ?? 'BUYSELL';
  }

  void _toggleTf(String tf) {
    setState(() {
      temp[tf] = !(temp[tf] == true);
    });
  }

  void _setSignal(String s) {
    setState(() {
      temp['signal'] = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(12),
      children: [
        const Text('تنظیمات جفت‌ارز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var tf in TIMEFRAMES)
              FilterChip(
                label: Text(tf),
                selected: temp[tf] == true,
                onSelected: (_) => _toggleTf(tf),
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('نوع سیگنال:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            ChoiceChip(label: const Text('BUY'), selected: temp['signal'] == 'BUY', onSelected: (_) => _setSignal('BUY')),
            ChoiceChip(label: const Text('SELL'), selected: temp['signal'] == 'SELL', onSelected: (_) => _setSignal('SELL')),
            ChoiceChip(label: const Text('BUYSELL'), selected: temp['signal'] == 'BUYSELL', onSelected: (_) => _setSignal('BUYSELL')),
          ],
        ),
        const SizedBox(height: 12),
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
