class Upgrade {
  final String id;
  final String name;
  final String desc;
  final double baseCost;
  final double val;
  final String type; // "click" or "auto"
  final int max;
  const Upgrade({
    required this.id,
    required this.name,
    required this.desc,
    required this.baseCost,
    required this.val,
    required this.type,
    required this.max,
  });
}