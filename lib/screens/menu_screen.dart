import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  final bool hasSave;
  final String saveInfo;
  final VoidCallback onPlay;
  final VoidCallback onContinue;
  final VoidCallback onHowTo;
  final VoidCallback onAchievements;
  final VoidCallback onLeaderboard;
  final VoidCallback onSettings;
  final VoidCallback onRemoveAds;
  final VoidCallback onCredits;

  const MenuScreen({
    super.key,
    required this.hasSave,
    required this.saveInfo,
    required this.onPlay,
    required this.onContinue,
    required this.onHowTo,
    required this.onAchievements,
    required this.onLeaderboard,
    required this.onSettings,
    required this.onRemoveAds,
    required this.onCredits,
  });

  Widget _btn(String title, String icon, VoidCallback onTap, {bool primary = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? const Color(0xFFC9A96E) : const Color(0xFF231A0F),
          foregroundColor: primary ? const Color(0xFF1A1207) : const Color(0xFFF5E6C8),
          side: primary ? null : BorderSide(color: const Color(0xFFF5E6C8).withValues(alpha: 0.18), width: 0.5),
          padding: EdgeInsets.symmetric(vertical: primary ? 16 : 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: primary ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (!primary) ...[Text(icon, style: const TextStyle(fontSize: 18)), const SizedBox(width: 12)],
            Text(title, style: TextStyle(fontSize: primary ? 18 : 16, fontWeight: primary ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("📖", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          const Text("Writer's Empire", style: TextStyle(fontSize: 32, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const Text("Tycoon", style: TextStyle(fontSize: 32, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const Text("From bedroom desk to literary immortality", style: TextStyle(color: Color(0xFF9E8A6A), fontSize: 14, fontStyle: FontStyle.italic)),
          const SizedBox(height: 35),
          if (hasSave) ...[
            _btn("Continue", "▶", onContinue, primary: true),
            Text(saveInfo, style: const TextStyle(color: Color(0xFF6B5A3E), fontSize: 11)),
            const SizedBox(height: 10),
          ] else ...[
            _btn("Play", "▶", onPlay, primary: true),
          ],
          _btn("How to Play", "📜", onHowTo),
          _btn("Achievements", "🏆", onAchievements),
          _btn("Leaderboard", "📊", onLeaderboard),
          _btn("Settings", "⚙️", onSettings),
          _btn("Remove Ads", "✨", onRemoveAds),
          _btn("Credits", "🖊", onCredits),
          const SizedBox(height: 20),
          const Text("v1.1.0", style: TextStyle(color: Color(0xFF4A3A28), fontSize: 11)),
        ],
      ),
    );
  }
}