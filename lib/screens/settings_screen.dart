import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onReset;

  const SettingsScreen({super.key, required this.onBack, required this.onReset});

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
              Switch(value: true, onChanged: (_) {}, activeColor: const Color(0xFFC9A96E)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8503C).withValues(alpha: 0.15),
              side: const BorderSide(color: Colors.redAccent, width: 0.5),
              minimumSize: const Size.fromHeight(45),
            ),
            onPressed: onReset,
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
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: Color(0xFF9E8A6A), size: 16),
        label: const Text("Back", style: TextStyle(color: Color(0xFF9E8A6A), fontSize: 14)),
      ),
    );
  }
}