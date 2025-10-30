import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_models.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  late List<TradingMode> _modes;

  @override
  void initState() {
    super.initState();
    _loadCurrentModes();
  }

  void _loadCurrentModes() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final userModes = provider.userSettings?.modes ?? {};
    
    // استفاده درست از TradingMode.allModes
    _modes = TradingMode.allModes.map((mode) {
      return mode.copyWith(
        isSelected: userModes[mode.code] ?? false,
      );
    }).toList();
  }

  void _toggleMode(String modeCode) {
    setState(() {
      for (var mode in _modes) {
        if (mode.code == modeCode) {
          if (modeCode == 'A1' || modeCode == 'A2') {
            if (!mode.isSelected) {
              for (var otherMode in _modes) {
                if (otherMode.code == 'A1' || otherMode.code == 'A2') {
                  otherMode.isSelected = (otherMode.code == modeCode);
                }
              }
            }
          } else {
            mode.isSelected = !mode.isSelected;
          }
        }
      }
    });
    _saveSettings();
  }

  void _saveSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final currentSettings = provider.userSettings;
    
    if (currentSettings != null) {
      final newModes = <String, bool>{};
      
      for (var mode in _modes) {
        newModes[mode.code] = mode.isSelected;
      }
      
      final newSettings = currentSettings.copyWith(modes: newModes);
      provider.updateUserSettings(newSettings);
    }
  }

  Widget _buildModeCard(TradingMode mode) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: mode.isSelected ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            mode.isSelected ? Icons.check : Icons.close,
            color: mode.isSelected ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          mode.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: mode.isSelected ? Colors.green.shade800 : Colors.black87,
          ),
        ),
        subtitle: Text(
          mode.description,
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: mode.code == 'A1' || mode.code == 'A2'
            ? Radio<String>(
                value: mode.code,
                groupValue: _getSelectedAMode(),
                onChanged: (value) => _toggleMode(value!),
              )
            : Checkbox(
                value: mode.isSelected,
                onChanged: (value) => _toggleMode(mode.code),
              ),
        onTap: () => _toggleMode(mode.code),
      ),
    );
  }

  String _getSelectedAMode() {
    final aMode = _modes.firstWhere(
      (mode) => (mode.code == 'A1' || mode.code == 'A2') && mode.isSelected,
      orElse: () => TradingMode.allModes.firstWhere((mode) => mode.code == 'A1'),
    );
    return aMode.code;
  }

  Widget _buildModeSection(String title, List<TradingMode> modes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...modes.map(_buildModeCard),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aModes = _modes.where((mode) => mode.code.startsWith('A')).toList();
    final otherModes = _modes.where((mode) => !mode.code.startsWith('A')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب مود'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _modes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'راهنمای انتخاب مود:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• A1 و A2: فقط یکی می‌تواند فعال باشد (Radio Button)\n'
                          '• مودهای B تا G: می‌توان چندین مورد را انتخاب کرد (Checkbox)\n'
                          '• 🟢 = فعال، 🔴 = غیرفعال',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildModeSection('مودهای اصلی (انتخاب یکی)', aModes),
                  const SizedBox(height: 16),
                  _buildModeSection('مودهای تکمیلی (انتخاب چندگانه)', otherModes),
                  const SizedBox(height: 24),
                  _buildSelectionSummary(),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectionSummary() {
    final selectedModes = _modes.where((mode) => mode.isSelected).toList();
    
    return Padding(
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
              'خلاصه انتخاب‌های شما:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (selectedModes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedModes
                    .map((mode) => Chip(
                          label: Text(mode.name),
                          backgroundColor: Colors.green.shade100,
                        ))
                    .toList(),
              )
            else
              const Text(
                'هیچ مودی انتخاب نشده است',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
