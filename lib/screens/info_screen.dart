import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final String type; // "removeads" or "credits"
  final VoidCallback onBack;

  const InfoScreen({super.key, required this.type, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isAds = type == "removeads";
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _backButton(),
          const Spacer(),
          Text(isAds ? "✨" : "🕯️", style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            isAds ? "Remove Ads" : "Credits",
            style: const TextStyle(fontSize: 22, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif'),
          ),
          const SizedBox(height: 10),
          Text(
            isAds
                ? "Support the game & write in peace.\nOne-time purchase coming soon on Google Play."
                : "Inspired by every writer who ever started in a small room.",
            style: const TextStyle(color: Color(0xFF9E8A6A), fontSize: 14, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
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