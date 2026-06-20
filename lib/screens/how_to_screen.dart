import 'package:flutter/material.dart';
import '../engine/game_engine.dart';

class HowToScreen extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onBack;
  final VoidCallback onRetire;

  const HowToScreen({
    super.key,
    required this.engine,
    required this.onBack,
    required this.onRetire,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
          const SizedBox(height: 15),
          const Text("How to Play", style: TextStyle(fontSize: 20, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 20),
          const Text(
            "1. Tap Write to generate words. Words per click grows with upgrades.\n\n"
            "2. Buy Upgrades for passive auto-production. Prices scale 20% per level.\n\n"
            "3. Move up through 20 locations. Each move costs words and resets upgrades.\n\n"
            "4. Complete a Tier to pick a permanent bonus that stacks forever.\n\n"
            "5. Retire at 1,000,000 words to gain a Muse (+10% production per Muse). "
            "You can retire multiple times!\n\n"
            "6. Publish books at milestones for production boosts.",
            style: TextStyle(color: Color(0xFFC8B490), fontSize: 14, height: 1.5),
          ),
          const Spacer(),
          if (engine.canRetire)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: onRetire,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🌟", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text("Retire for a Muse!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          const SizedBox(height: 20),
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