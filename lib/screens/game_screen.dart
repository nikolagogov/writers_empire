import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/game_engine.dart';
import '../data/game_data.dart';
import '../utils/formatter.dart';
import 'menu_screen.dart';
import 'how_to_screen.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'info_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameEngine engine;
  Timer? _timer;
  String _eventText = "Start writing and build your empire...";
  String _activeScreen = "menu";
  bool _hasSave = false;
  String _saveInfo = "";
  late AnimationController _clickAnimController;

  static const String _saveKey = "writers_empire_save_v1";

  @override
  void initState() {
    super.initState();
    engine = GameEngine();
    _loadGame();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    _clickAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clickAnimController.dispose();
    super.dispose();
  }

  // 🔧 FIX: Auto-tick now works everywhere, not only in "game" screen
  void _onTick(Timer timer) {
    if (engine.autoPow > 0) {
      setState(() {
        engine.words += engine.autoPow;
        engine.totalWords += engine.autoPow;
        _checkBooks();
        engine.checkAchievements();
      });
    }
  }

  void _checkBooks() {
    for (final b in engine.lockedBooks) {
      if (engine.totalWords >= b.milestone) {
        setState(() {
          engine.booksOwned.add(b.id);
          _eventText = "📖 Published \"${b.title}\"! ${b.desc}";
        });
      }
    }
  }

  void _doClick() {
    setState(() {
      engine.words += engine.clickPow;
      engine.totalWords += engine.clickPow;
      _clickAnimController.forward(from: 0);
      _checkBooks();
      engine.checkAchievements();
    });
  }

  void _doMove(Location nx) {
    if (engine.isAtLastLocation) return;
    if (engine.words < nx.goal) return;

    setState(() {
      engine.words -= nx.goal;
      engine.loc++;
      engine.upgrades.updateAll((k, v) => 0);
      _eventText = "🎉 Moved to ${LOCS[engine.loc].name}! Upgrades reset.";
    });
    _saveGame();
  }

  void _doTierAdvance(double goal) {
    // 🔧 FIX: Added guard for last location
    if (engine.isAtLastLocation) return;
    if (engine.words < goal) return;

    setState(() {
      final remainder = engine.words - goal;
      engine.words = remainder;
      engine.loc++;
      engine.tiersCompleted++; // 🔧 FIX: Now increments tiersCompleted
      engine.upgrades.updateAll((k, v) => 0);
      _eventText = "✨ Tier Complete! Advanced to ${LOCS[engine.loc].name}";
    });
    _saveGame();
  }

  Future<void> _confirmRetire() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF231A0F),
        title: const Text('🌟 Retire for a Muse?', style: TextStyle(color: Color(0xFFF5E6C8))),
        content: Text(
          'You will reset all progress but gain +10% permanent production bonus per Muse.\n\n'
          'Current Muses: ${engine.muses}\n'
          'Current bonus: +${(engine.muses * 10).toInt()}%\n'
          'Muses after: ${engine.muses + 1}\n'
          'New bonus: +${((engine.muses + 1) * 10).toInt()}%\n\n'
          'You can retire multiple times!',
          style: const TextStyle(color: Color(0xFF9E8A6A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E8A6A))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B59B6)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retire!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        engine.retire();
        _eventText = "🌟 Retired! Gained a Muse! +${(engine.muses * 10).toInt()}% bonus forever.";
        engine.checkAchievements();
      });
      _saveGame();
    }
  }

  // 🔧 NEW: Confirm dialog for reset
  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF231A0F),
        title: const Text('⚠️ Reset Progress?', style: TextStyle(color: Color(0xFFF5E6C8))),
        content: const Text(
          'This will permanently delete ALL your progress.\n\n'
          'This action cannot be undone!',
          style: TextStyle(color: Color(0xFF9E8A6A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E8A6A))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC8503C)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetGame();
    }
  }

  Future<void> _loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_saveKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data.isNotEmpty) {
          engine.fromJson(data);
          engine.calculateOfflineProgress();
          setState(() {
            _hasSave = true;
            _saveInfo = "${LOCS[engine.loc].name} · ${fmt(engine.words)} words";
            _checkBooks();
            engine.checkAchievements();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveGame() async {
    try {
      engine.lastSaveTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_saveKey, jsonEncode(engine.toJson()));
      setState(() {
        _hasSave = true;
        _saveInfo = "${LOCS[engine.loc].name} · ${fmt(engine.words)} words";
      });
    } catch (_) {}
  }

  void _resetGame() {
    setState(() {
      engine = GameEngine();
      _hasSave = false;
      _activeScreen = "menu";
    });
    SharedPreferences.getInstance().then((p) => p.remove(_saveKey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1207),
      body: SafeArea(
        child: _activeScreen == "menu"
            ? MenuScreen(
                hasSave: _hasSave,
                saveInfo: _saveInfo,
                onPlay: () => setState(() => _activeScreen = "game"),
                onContinue: () => setState(() => _activeScreen = "game"),
                onHowTo: () => setState(() => _activeScreen = "howto"),
                onAchievements: () => setState(() => _activeScreen = "achievements"),
                onLeaderboard: () => setState(() => _activeScreen = "leaderboard"),
                onSettings: () => setState(() => _activeScreen = "settings"),
                onRemoveAds: () => setState(() => _activeScreen = "removeads"),
                onCredits: () => setState(() => _activeScreen = "credits"),
              )
            : _buildScreen(),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_activeScreen) {
      case "howto":
        return HowToScreen(
          engine: engine,
          onBack: () => setState(() => _activeScreen = "menu"),
          onRetire: _confirmRetire,
        );
      case "achievements":
        return AchievementsScreen(
          engine: engine,
          onBack: () => setState(() => _activeScreen = "menu"),
        );
      case "leaderboard":
        return LeaderboardScreen(
          onBack: () => setState(() => _activeScreen = "menu"),
        );
      case "settings":
        return SettingsScreen(
          onBack: () => setState(() => _activeScreen = "menu"),
          onReset: _confirmReset, // 🔧 FIX: Now uses confirm dialog
        );
      case "removeads":
      case "credits":
        return InfoScreen(
          type: _activeScreen,
          onBack: () => setState(() => _activeScreen = "menu"),
        );
      default:
        return _buildGameplay();
    }
  }

  Widget _buildGameplay() {
    final currentLoc = LOCS[engine.loc];
    final hasNext = engine.loc + 1 < LOCS.length;
    final nx = hasNext ? LOCS[engine.loc + 1] : null;

    bool showMoveBtn = false;
    String moveBtnText = "";
    VoidCallback? moveAction;
    String msgText = "";

    if (nx != null && nx.tier == engine.currentTier) {
      if (engine.words >= nx.goal) {
        showMoveBtn = true;
        msgText = "Ready to move to ${nx.name}! Cost: ${fmt(nx.goal)} words. You'll keep the rest.";
        moveBtnText = "🚀 Move up";
        moveAction = () => _doMove(nx);
      }
    } else if (engine.isLastInTier && engine.currentTier < 4) {
      if (currentLoc.goal > 0 && engine.words >= currentLoc.goal) {
        showMoveBtn = true;
        msgText = "Tier ${engine.currentTier} complete! Cost: ${fmt(currentLoc.goal)} words. You'll keep the rest.";
        moveBtnText = "🏆 Complete Tier ${engine.currentTier}";
        moveAction = () => _doTierAdvance(currentLoc.goal);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  _saveGame();
                  setState(() => _activeScreen = "menu");
                },
                icon: const Icon(Icons.arrow_back, color: Color(0xFF9E8A6A), size: 14),
                label: const Text("Menu", style: TextStyle(color: Color(0xFF9E8A6A), fontSize: 13)),
              ),
              Row(
                children: [
                  if (engine.canRetire)
                    GestureDetector(
                      onTap: _confirmRetire,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("🌟", style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text("Retire", style: TextStyle(color: Color(0xFFC39BD3), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A96E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("Tier ${engine.currentTier}", style: const TextStyle(color: Color(0xFFC9A96E), fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(currentLoc.name, style: const TextStyle(color: Color(0xFFF5E6C8), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 15),
          AnimatedBuilder(
            animation: _clickAnimController,
            builder: (context, child) {
              final scale = 1.0 + 0.1 * (1 - _clickAnimController.value);
              return Transform.scale(
                scale: scale,
                child: Text("${fmt(engine.words)} words", style: const TextStyle(fontSize: 36, color: Color(0xFFF5E6C8), fontWeight: FontWeight.bold)),
              );
            },
          ),
          Text("${engine.autoPow.toStringAsFixed(1)} words/sec", style: const TextStyle(color: Color(0xFF9E8A6A), fontSize: 13)),
          if (engine.muses > 0)
            Text("🧠 ${engine.muses} Muse${engine.muses > 1 ? 's' : ''} (${(engine.muses * 10).toInt()}% bonus)",
                style: const TextStyle(color: Color(0xFF9B59B6), fontSize: 12)),
          const Spacer(),
          if (showMoveBtn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF5AB478).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF5AB478).withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(msgText, style: const TextStyle(color: Color(0xFF8ECFA8), fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5AB478),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: moveAction,
                    child: Text(moveBtnText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          GestureDetector(
            onTap: _doClick,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFC9A96E), Color(0xFFE8C98A)]),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                child: Text("✍️ Write", style: TextStyle(color: Color(0xFF1A1207), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(8)),
            child: Text(_eventText, style: const TextStyle(color: Color(0xFF9E8A6A), fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 15),
          const Align(alignment: Alignment.centerLeft, child: Text("Upgrades", style: TextStyle(color: Color(0xFF6B5A3E), fontSize: 11, fontWeight: FontWeight.bold))),
          const SizedBox(height: 5),
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: UPGS.length,
              itemBuilder: (context, index) {
                final u = UPGS[index];
                final cost = engine.getUpgCost(u);
                final lv = engine.upgrades[u.id] ?? 0;
                final isMax = lv >= u.max;
                final canAfford = engine.words >= cost;

                return InkWell(
                  onTap: (isMax || !canAfford) ? null : () => setState(() {
                        engine.words -= cost;
                        engine.upgrades[u.id] = lv + 1;
                      }),
                  child: Opacity(
                    opacity: isMax ? 1.0 : (canAfford ? 1.0 : 0.4),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        border: Border.all(
                          color: isMax ? const Color(0xFF5AB478).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.12),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text("Lv $lv", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                          Text(u.desc, style: const TextStyle(color: Colors.grey, fontSize: 9)),
                          const SizedBox(height: 2),
                          Text(
                            isMax ? "✓ Max" : "${fmt(cost.toDouble())} words",
                            style: TextStyle(
                              color: isMax ? const Color(0xFF5AB478) : const Color(0xFFC9A96E),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}