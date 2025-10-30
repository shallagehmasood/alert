// pages/signals_page.dart

import 'package:flutter/material.dart';

class SignalsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        final signals = apiService.signals;
        
        if (signals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 64, color: Color(0xFFB0B0B0)),
                SizedBox(height: 16),
                Text(
                  'سیگنالی یافت نشد',
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 16,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: signals.length,
          itemBuilder: (context, index) {
            return SignalCard(signal: signals[index]);
          },
        );
      },
    );
  }
}
