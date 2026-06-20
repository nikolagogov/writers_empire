import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReset;

  const SettingsScreen({super.key, required this.onBack, required this.onReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSaveEnabled = true;
  static const String _autoSaveKey = "writers_empire_auto_save";

  @override
  void initState() {
    super.initState();
    _loadAutoSavePreference();
  }

  Future<void> _loadAutoSavePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _autoSaveEnabled = prefs.getBool(_autoSaveKey) ?? true;
      });
    } catch (_) {}
  }

  Future<void> _toggleAutoSave(bool value) async {
    setState(() {
      _autoSaveEnabled = value;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoSaveKey, value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
          const SizedBox(height: 15),
          const Text("Settings", style: TextStyle(fontSize: 20, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Auto-save progress", style: TextStyle(color: Color(0xFFC8B490))),
              Switch(
                value: _autoSaveEnabled,
                onChanged: _toggleAutoSave,
                activeColor: const Color(0xFFC9A96E),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8503C).withValues(alpha: 0.15),
              side: const BorderSide(color: Colors.redAccent, width: 0.5),
              minimumSize: const Size.fromHeight(45),
            ),
            onPressed: widget.onReset,
            child: const Text("Reset Progress permanently", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: widget.onBack,
        icon: const Icon(Icons.arrow_back, color: Color(0xFF9E8A6A), size: 16),
        label: const Text("Back", style: TextStyle(color: Color(0xFF9E8A6A), fontSize: 14)),
      ),
    );
  }
}