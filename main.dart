import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const WritersEmpireApp());

class WritersEmpireApp extends StatelessWidget {
  const WritersEmpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Writer's Empire",
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C83FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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

const upgrades = [
  Upgrade(id: 'kb', name: 'Keyboard', icon: '⌨️', description: '+2 / click', type: 'click', value: 2, baseCost: 100, max: 25),
  Upgrade(id: 'mk', name: 'Marketing', icon: '📣', description: '+8 / click', type: 'click', value: 8, baseCost: 600, max: 20),
  Upgrade(id: 'cf', name: 'Coffee', icon: '☕', description: '+0.5 / sec', type: 'auto', value: .5, baseCost: 200, max: 30),
  Upgrade(id: 'ed', name: 'Editor', icon: '📝', description: '+3 / sec', type: 'auto', value: 3, baseCost: 1500, max: 20),
  Upgrade(id: 'gh', name: 'Ghost Writer', icon: '👻', description: '+15 / sec', type: 'auto', value: 15, baseCost: 10000, max: 15),
  Upgrade(id: 'ai', name: 'AI Bot', icon: '🤖', description: '+80 / sec', type: 'auto', value: 80, baseCost: 70000, max: 10),
];

const locations = [
  ("📝 Child's Room", 1000000.0),
  ("🏚 Parents' Basement", 5000000.0),
  ("🚗 Garage", 20000000.0),
  ("🏠 Rented Attic", 50000000.0),
  ("🛋 Small Apartment", 200000000.0),
  ("🤝 Shared Office", 800000000.0),
  ("🏢 Rented Office", 3000000000.0),
  ("📣 Small Agency", 10000000000.0),
  ("📚 Publishing House", 30000000000.0),
  ("🏙 City HQ", 100000000000.0),
  ("🗺 National Publisher", 500000000000.0),
  ("🌍 Continental Network", 2000000000000.0),
  ("🌐 Global Empire", 8000000000000.0),
  ("📡 Media Conglomerate", 30000000000000.0),
  ("🏆 Literary Legend", 100000000000000.0),
  ("👁 Posthumous Fame", 500000000000000.0),
  ("🎖 Nobel Archive", 2000000000000000.0),
  ("🗿 Cultural Monument", 8000000000000000.0),
  ("🔭 Galactic Library", 30000000000000000.0),
  ("♾ Immortal Word", 100000000000000000.0),
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double words = 0, totalWords = 0;
  int location = 0, muses = 0;
  final levels = <String, int>{for (final u in upgrades) u.id: 0};
  String event = 'Your story begins here.';
  Timer? timer;

  double get multiplier => 1 + muses * .05;

  double get clickPower {
    var p = 1.0;
    for (final u in upgrades.where((u) => u.type == 'click')) {
      p += (levels[u.id] ?? 0) * u.value;
    }
    return p * multiplier;
  }

  double get autoPower {
    var p = 0.0;
    for (final u in upgrades.where((u) => u.type == 'auto')) {
      p += (levels[u.id] ?? 0) * u.value;
    }
    return p * multiplier;
  }

  double get moveGoal => locations[location].$2;
  bool get canMove => location < locations.length - 1 && words >= moveGoal;
  bool get canMuse => words >= 1000000;

  double cost(Upgrade u) {
    var c = u.baseCost;
    for (var i = 0; i < (levels[u.id] ?? 0); i++) c *= 1.2;
    return c;
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
    if (n < 1000000000000000) return '${(n / 1000000000000).toStringAsFixed(2)}T';
    return '${(n / 1000000000000000).toStringAsFixed(2)}Qa';
  }

  void write() {
    setState(() {
      words += clickPower;
      totalWords += clickPower;
      event = '+${fmt(clickPower)} words';
    });
    _save();
  }

  void buy(Upgrade u) {
    final lv = levels[u.id] ?? 0;
    final c = cost(u);
    if (lv >= u.max || words < c) return;
    setState(() {
      words -= c;
      levels[u.id] = lv + 1;
      event = '${u.name} → Level ${lv + 1}';
    });
    _save();
  }

  void advance() {
    if (!canMove) return;
    final next = locations[location + 1].$1;
    setState(() {
      words -= moveGoal;
      location++;
      for (final id in levels.keys) levels[id] = 0;
      event = 'New chapter: $next';
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
          'Your current career and upgrades will reset.\n\n'
          'You will gain 1 Muse and keep it permanently.\n'
          'Each Muse gives +5% to all production.\n\n'
          'Muses: $muses → ${muses + 1}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                muses++;
                words = 0;
                totalWords = 0;
                location = 0;
                for (final id in levels.keys) levels[id] = 0;
                event = 'New career started — Muse gained!';
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
    await p.setString('writers_empire_save_v2', jsonEncode({
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
    final raw = p.getString('writers_empire_save_v2');
    if (raw == null) return;
    try {
      final d = jsonDecode(raw) as Map<String, dynamic>;
      final saved = DateTime.fromMillisecondsSinceEpoch((d['saved'] ?? 0) as int);
      final seconds = DateTime.now().difference(saved).inSeconds.clamp(0, 86400);
      setState(() {
        words = (d['words'] ?? 0).toDouble();
        totalWords = (d['totalWords'] ?? 0).toDouble();
        location = ((d['location'] ?? 0) as int).clamp(0, locations.length - 1);
        muses = (d['muses'] ?? 0) as int;
        final savedLevels = Map<String, dynamic>.from(d['levels'] ?? {});
        for (final u in upgrades) levels[u.id] = (savedLevels[u.id] ?? 0) as int;
        words += autoPower * seconds;
        totalWords += autoPower * seconds;
        if (seconds > 5) event = 'While away: +${fmt(autoPower * seconds)} words';
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: LayoutBuilder(
              builder: (context, c) {
                final tight = c.maxHeight < 720;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: tight ? 7 : 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("✍️ Writer's Empire", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                                Text('Build your writing empire.', style: TextStyle(fontSize: 11, color: Colors.white54)),
                              ],
                            ),
                          ),
                          Text('🌟 $muses', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                      SizedBox(height: tight ? 7 : 11),
                      Row(children: [
                        _stat('WORDS', fmt(words)),
                        const SizedBox(width: 7),
                        _stat('WORDS / SEC', fmt(autoPower)),
                        const SizedBox(width: 7),
                        _stat('PER CLICK', fmt(clickPower)),
                      ]),
                      SizedBox(height: tight ? 7 : 10),
                      Text(locations[location].$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      if (location < locations.length - 1)
                        Text(
                          'Next: ${locations[location + 1].$1} • ${fmt(moveGoal)} words',
                          style: const TextStyle(fontSize: 10, color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: (words / moveGoal).clamp(0, 1),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      SizedBox(height: tight ? 7 : 10),
                      SizedBox(
                        width: double.infinity,
                        height: tight ? 55 : 62,
                        child: FilledButton(
                          onPressed: write,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('WRITE ✍️', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      SizedBox(height: tight ? 3 : 6),
                      SizedBox(
                        height: 18,
                        child: Text(event, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('UPGRADES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upgrades.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: tight ? 2.25 : 2.0,
                          ),
                          itemBuilder: (_, i) => _upgradeCard(upgrades[i]),
                        ),
                      ),
                      if (canMove || canMuse)
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (canMove)
                                FilledButton.icon(
                                  onPressed: advance,
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                  label: Text('GO TO ${locations[location + 1].$1}'),
                                ),
                              if (canMuse)
                                OutlinedButton.icon(
                                  onPressed: getMuse,
                                  icon: const Icon(Icons.auto_awesome, size: 18),
                                  label: const Text('GET A MUSE'),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF141A29),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      ]),
    ),
  );

  Widget _upgradeCard(Upgrade u) {
    final lv = levels[u.id] ?? 0;
    final c = cost(u);
    final canBuy = lv < u.max && words >= c;
    return FilledButton(
      onPressed: canBuy ? () => buy(u) : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${u.icon} ${u.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(u.description, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(lv >= u.max ? 'MAX' : 'Lv.$lv  •  💰 ${fmt(c)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
