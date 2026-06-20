import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final VoidCallback onBack;

  const LeaderboardScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real leaderboard data from Firebase / Google Play Games
    // This is placeholder data for UI testing only
    final fakePlayers = const [
      {"r": "1", "n": "Hemingway_Fan", "s": "4.2T"},
      {"r": "2", "n": "NightOwlWriter", "s": "1.8T"},
      {"r": "3", "n": "CaffeineAndWords", "s": "890B"},
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
          const SizedBox(height: 15),
          const Text("Leaderboard", style: TextStyle(fontSize: 20, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const Text(
            "📊 Placeholder - Online leaderboard coming soon",
            style: TextStyle(color: Color(0xFF6B5A3E), fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          ...fakePlayers.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${p['r']}. ${p['n']}", style: const TextStyle(color: Colors.white)),
                    Text("${p['s']} words", style: const TextStyle(color: Color(0xFF9E8A6A))),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A96E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC9A96E).withValues(alpha: 0.2)),
            ),
            child: const Text(
              '💡 Real leaderboard with online scores will be available in a future update.\n'
              'Your progress is still saved locally!',
              style: TextStyle(color: Color(0xFFC8B490), fontSize: 12),
              textAlign: TextAlign.center,
            ),
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