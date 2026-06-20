import 'dart:math';
import '../models/location.dart';
import '../models/upgrade.dart';
import '../models/book.dart';
import '../data/game_data.dart';

class GameEngine {
  double words = 0;
  double totalWords = 0;
  int loc = 0;
  int muses = 0;
  int tiersCompleted = 0;
  DateTime? lastSaveTime;

  final Map<String, int> upgrades = {
    'kb': 0,
    'mk': 0,
    'cf': 0,
    'ed': 0,
    'gh': 0,
    'ai': 0,
  };
  final List<String> bonuses = [];
  final List<String> booksOwned = [];
  final Map<String, bool> achDone = {};

  List<Book> get unlockedBooks => BOOKS.where((b) => !booksOwned.contains(b.id)).toList();

  int get currentTier => LOCS[loc].tier;

  bool get isLastInTier {
    if (loc + 1 >= LOCS.length) return true;
    return LOCS[loc + 1].tier != currentTier;
  }

  bool get isAtLastLocation => loc >= LOCS.length - 1;

  bool get canRetire => words >= 1000000;

  double bookMult(String type) {
    double m = 1.0;
    for (final b in BOOKS) {
      if (!booksOwned.contains(b.id)) continue;
      if (b.bonus == type || b.bonus == "both") m += b.val;
    }
    return m;
  }

  double get clickPow {
    double b = 1.0;
    for (final u in UPGS.where((x) => x.type == "click")) {
      final v = bonuses.contains("momentum") ? u.val * 1.10 : u.val;
      b += v * (upgrades[u.id] ?? 0);
    }
    double m = 1.0;
    if (bonuses.contains("wordsmith")) m += 0.10;
    if (bonuses.contains("precision")) m += 0.12;
    final musePct = bonuses.contains("legacy") ? 0.12 : 0.10;
    return b * (1 + muses * musePct) * m * bookMult("click");
  }

  double get autoPow {
    double b = 0.0;
    for (final u in UPGS.where((x) => x.type == "auto")) {
      final v = bonuses.contains("momentum") ? u.val * 1.10 : u.val;
      b += v * (upgrades[u.id] ?? 0);
    }
    double m = 1.0;
    if (bonuses.contains("flowstate")) m += 0.10;
    if (bonuses.contains("torrent")) m += 0.12;
    final musePct = bonuses.contains("legacy") ? 0.12 : 0.10;
    return b * (1 + muses * musePct) * m * bookMult("auto");
  }

  double get upgCostMult {
    double m = 1.0;
    if (bonuses.contains("thrifty")) m *= 0.92;
    if (bonuses.contains("quickstart")) m *= 0.92;
    return m;
  }

  int getUpgCost(Upgrade u) {
    final locMultiplier = pow(4, loc).toDouble();
    return (u.baseCost * locMultiplier * pow(1.2, upgrades[u.id] ?? 0) * upgCostMult).floor();
  }

  void retire() {
    if (!canRetire) return;

    muses++;

    words = 0;
    totalWords = 0;
    loc = 0;
    tiersCompleted = 0;
    upgrades.updateAll((k, v) => 0);
    bonuses.clear();
    booksOwned.clear();
    achDone.clear();

    lastSaveTime = DateTime.now();
  }

  void calculateOfflineProgress() {
    if (lastSaveTime == null) return;
    final secondsAgo = DateTime.now().difference(lastSaveTime!).inSeconds;
    if (secondsAgo > 0 && autoPow > 0) {
      final earned = autoPow * secondsAgo;
      words += earned;
      totalWords += earned;
    }
    lastSaveTime = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'words': words,
        'totalWords': totalWords,
        'loc': loc,
        'muses': muses,
        'tiersCompleted': tiersCompleted,
        'upgrades': upgrades,
        'bonuses': bonuses,
        'booksOwned': booksOwned,
        'achDone': achDone,
        'lastSaveTime': lastSaveTime?.toIso8601String(),
      };

  void fromJson(Map<String, dynamic> json) {
    words = (json['words'] ?? 0.0).toDouble();
    totalWords = (json['totalWords'] ?? 0.0).toDouble();
    loc = json['loc'] ?? 0;
    muses = json['muses'] ?? 0;
    tiersCompleted = json['tiersCompleted'] ?? 0;
    upgrades
      ..clear()
      ..addAll(Map<String, int>.from(json['upgrades'] ?? {}));
    bonuses
      ..clear()
      ..addAll(List<String>.from(json['bonuses'] ?? []));
    booksOwned
      ..clear()
      ..addAll(List<String>.from(json['booksOwned'] ?? []));
    achDone
      ..clear()
      ..addAll(Map<String, bool>.from(json['achDone'] ?? {}));
    final savedTime = json['lastSaveTime'] as String?;
    if (savedTime != null) {
      lastSaveTime = DateTime.tryParse(savedTime);
    }
  }
}