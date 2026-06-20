import 'package:flutter/material.dart';
import '../engine/game_engine.dart';

class AchievementsScreen extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onBack;

  const AchievementsScreen({super.key, required this.engine, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // Define all achievements with their display data
    final achievements = [
      {
        'id': 'first_word',
        'icon': '✍️',
        'title': 'First Word',
        'description': 'Write your first word',
      },
      {
        'id': 'first_k',
        'icon': '📝',
        'title': '1K Words',
        'description': 'Write 1,000 words total',
      },
      {
        'id': 'first_m',
        'icon': '📚',
        'title': '1M Words',
        'description': 'Write 1,000,000 words total',
      },
      {
        'id': 'first_retire',
        'icon': '🌟',
        'title': 'First Retire',
        'description': 'Retire for your first Muse',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
          const SizedBox(height: 15),
          const Text("Achievements", style: TextStyle(fontSize: 20, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          Text(
            "${engine.achDone.length}/${achievements.length} unlocked",
            style: const TextStyle(color: Color(0xFF9E8A6A), fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...achievements.map((ach) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: engine.achDone.containsKey(ach['id'])
                      ? const Color(0xFF5AB478).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: engine.achDone.containsKey(ach['id'])
                        ? const Color(0xFF5AB478).withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      engine.achDone.containsKey(ach['id']) ? '✅' : '🔒',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ach['title'] as String,
                            style: TextStyle(
                              color: engine.achDone.containsKey(ach['id'])
                                  ? const Color(0xFF5AB478)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ach['description'] as String,
                            style: TextStyle(
                              color: engine.achDone.containsKey(ach['id'])
                                  ? const Color(0xFF8ECFA8)
                                  : const Color(0xFF9E8A6A),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (engine.achDone.containsKey(ach['id']))
                      const Text(
                        'Unlocked!',
                        style: TextStyle(color: Color(0xFF5AB478), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              )),
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