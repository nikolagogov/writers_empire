
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const WritersEmpireApp());

class WritersEmpireApp extends StatelessWidget {
  const WritersEmpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Writer's Empire",
      theme: ThemeData.dark(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

class Upgrade {
  final String id, name, icon, description, type;
  final double value, baseCost;
  final int max;
  const Upgrade({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.type,
    required this.value,
    required this.baseCost,
    required this.max,
  });
}

const upgrades = <Upgrade>[
  Upgrade(id: 'kb', name: 'Keyboard', icon: '⌨️', description: '+2 words/click', type: 'click', value: 2, baseCost: 100, max: 25),
  Upgrade(id: 'mk', name: 'Marketing', icon: '📣', description: '+8 words/click', type: 'click', value: 8, baseCost: 600, max: 20),
  Upgrade(id: 'cf', name: 'Coffee', icon: '☕', description: '+0.5 words/sec', type: 'auto', value: .5, baseCost: 200, max: 30),
  Upgrade(id: 'ed', name: 'Editor', icon: '📝', description: '+3 words/sec', type: 'auto', value: 3, baseCost: 1500, max: 20),
  Upgrade(id: 'gh', name: 'Ghost Writer', icon: '👻', description: '+15 words/sec', type: 'auto', value: 15, baseCost: 10000, max: 15),
  Upgrade(id: 'ai', name: 'AI Bot', icon: '🤖', description: '+80 words/sec', type: 'auto', value: 80, baseCost: 70000, max: 10),
];

const locations = <Map<String, dynamic>>[
  {'name': "📝 Child's Room", 'goal': 1000000.0},
  {'name': "🏚 Parents' Basement", 'goal': 5000000.0},
  {'name': "🚗 Garage", 'goal': 20000000.0},
  {'name': "🏠 Rented Attic", 'goal': 50000000.0},
  {'name': "🛋 Small Apartment", 'goal': 50000.0},
  {'name': "🤝 Shared Office", 'goal': 200000000.0},
  {'name': "🏢 Rented Office", 'goal': 800000000.0},
  {'name': "📣 Small Agency", 'goal': 3000000000.0},
  {'name': "📚 Publishing House", 'goal': 10000000000.0},
  {'name': "🏙 City HQ", 'goal': 50000.0},
  {'name': "🗺 National Publisher", 'goal': 50000000000.0},
  {'name': "🌍 Continental Network", 'goal': 200000000000.0},
  {'name': "🌐 Global Empire", 'goal': 800000000000.0},
  {'name': "📡 Media Conglomerate", 'goal': 3000000000000.0},
  {'name': "🏆 Literary Legend", 'goal': 200000.0},
  {'name': "👁 Posthumous Fame", 'goal': 15000000000000.0},
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double words = 0, totalWords = 0;
  int location = 0, muses = 0;
  final Map<String, int> levels = {for (final u in upgrades) u.id: 0};
  String event = 'Your story begins here.';
  Timer? timer;

  double get museMultiplier => 1 + muses * .05;

  double get clickPower {
    var value = 1.0;
    for (final u in upgrades.where((u) => u.type == 'click')) {
      value += (levels[u.id] ?? 0) * u.value;
    }
    return value * museMultiplier;
  }

  double get autoPower {
    var value = 0.0;
    for (final u in upgrades.where((u) => u.type == 'auto')) {
      value += (levels[u.id] ?? 0) * u.value;
    }
    return value * museMultiplier;
  }

  bool get canMove =>
      location < locations.length - 1 && words >= locations[location]['goal'];

  bool get canMuse => words >= 1000000;

  double upgradeCost(Upgrade u) =>
      (u.baseCost * _pow(1.2, levels[u.id] ?? 0));

  double _pow(double a, int b) {
    var result = 1.0;
    for (var i = 0; i < b; i++) result *= a;
    return result;
  }

  @override
  void initState() {
    super.initState();
    _load();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || autoPower <= 0) return;
      setState(() {
        words += autoPower;
        totalWords += autoPower;
      });
      _save();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String fmt(double n) {
    if (n < 1000) return n.floor().toString();
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n < 1000000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n < 1000000000000) return '${(n / 1000000000).toStringAsFixed(2)}B';
    return '${(n / 1000000000000).toStringAsFixed(2)}T';
  }

  void write() {
    setState(() {
      words += clickPower;
      totalWords += clickPower;
      event = 'You wrote ${fmt(clickPower)} words.';
    });
    _save();
  }

  void buy(Upgrade u) {
    final cost = upgradeCost(u);
    final level = levels[u.id] ?? 0;
    if (words < cost || level >= u.max) return;
    setState(() {
      words -= cost;
      levels[u.id] = level + 1;
      event = '${u.name} upgraded to level ${level + 1}.';
    });
    _save();
  }

  void move() {
    if (!canMove) return;
    final next = locations[location + 1]['name'] as String;
    setState(() {
      words -= locations[location]['goal'] as double;
      location++;
      for (final id in levels.keys) levels[id] = 0;
      event = 'You moved to $next.';
    });
    _save();
  }

  void getMuse() {
    if (!canMuse) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🌟 Get a Muse?'),
        content: Text(
          'Start a new career and reset your current progress and upgrades.\n\n'
          'You will gain 1 Muse, giving you +5% permanent production.\n\n'
          'Current Muses: $muses → ${muses + 1}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                muses++;
                words = 0;
                totalWords = 0;
                location = 0;
                for (final id in levels.keys) levels[id] = 0;
                event = 'A new career begins. You gained a Muse!';
              });
              _save();
            },
            child: const Text('GET A MUSE'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('save', jsonEncode({
      'words': words,
      'totalWords': totalWords,
      'location': location,
      'muses': muses,
      'levels': levels,
      'saved': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('save');
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final saved = DateTime.fromMillisecondsSinceEpoch(data['saved'] ?? 0);
      final seconds = DateTime.now().difference(saved).inSeconds.clamp(0, 86400);
      setState(() {
        words = (data['words'] ?? 0).toDouble();
        totalWords = (data['totalWords'] ?? 0).toDouble();
        location = (data['location'] ?? 0).clamp(0, locations.length - 1);
        muses = data['muses'] ?? 0;
        final savedLevels = Map<String, dynamic>.from(data['levels'] ?? {});
        for (final u in upgrades) levels[u.id] = (savedLevels[u.id] ?? 0) as int;
        words += autoPower * seconds;
        totalWords += autoPower * seconds;
        if (seconds > 5) event = 'While you were away: ${fmt(autoPower * seconds)} words.';
      });
    } catch (_) {
      // Ignore an invalid save and start clean.
    }
  }

  Widget upgradeCard(Upgrade u) {
    final level = levels[u.id] ?? 0;
    final cost = upgradeCost(u);
    final affordable = words >= cost && level < u.max;
    return FilledButton(
      onPressed: affordable ? () => buy(u) : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(9),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${u.icon} ${u.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(u.description, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            level >= u.max ? 'MAX' : 'Lv.$level • 💰 ${fmt(cost)}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextName = location < locations.length - 1
        ? locations[location + 1]['name'] as String
        : 'Final destination';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            return Padding(
              padding: EdgeInsets.fromLTRB(12, compact ? 8 : 12, 12, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("✍️ Writer's Empire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            Text('From bedroom writer to literary legend', style: TextStyle(fontSize: 11, color: Colors.white54)),
                          ],
                        ),
                      ),
                      Text('🌟 $muses Muses', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: compact ? 7 : 10),
                  Row(
                    children: [
                      _stat('WORDS', fmt(words)),
                      const SizedBox(width: 6),
                      _stat('WORDS / SEC', fmt(autoPower)),
                      const SizedBox(width: 6),
                      _stat('PER CLICK', fmt(clickPower)),
                    ],
                  ),
                  SizedBox(height: compact ? 6 : 9),
                  Text(locations[location]['name'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  Text(
                    location < locations.length - 1
                        ? 'Next: $nextName • ${fmt(locations[location]['goal'] as double)} words'
                        : 'Final destination',
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (words / (locations[location]['goal'] as double)).clamp(0, 1),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  SizedBox(height: compact ? 7 : 10),
                  SizedBox(
                    height: compact ? 52 : 60,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: write,
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('WRITE ✍️', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 7),
                  SizedBox(
                    height: compact ? 18 : 22,
                    child: Text(event, style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('UPGRADES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Expanded(
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                      childAspectRatio: compact ? 2.15 : 2.0,
                      children: upgrades.map(upgradeCard).toList(),
                    ),
                  ),
                  if (canMove || canMuse) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        if (canMove)
                          FilledButton.icon(
                            onPressed: move,
                            icon: const Icon(Icons.door_front_door_outlined, size: 17),
                            label: Text('GO TO $nextName'),
                          ),
                        if (canMuse)
                          OutlinedButton.icon(
                            onPressed: getMuse,
                            icon: const Icon(Icons.auto_awesome, size: 17),
                            label: const Text('GET A MUSE'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF171D26),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
