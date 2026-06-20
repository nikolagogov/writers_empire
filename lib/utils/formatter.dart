String fmt(double n) {
  if (n >= 1e15) return "${(n / 1e15).toStringAsFixed(2)}Qa";
  if (n >= 1e12) return "${(n / 1e12).toStringAsFixed(2)}T";
  if (n >= 1e9) return "${(n / 1e9).toStringAsFixed(2)}B";
  if (n >= 1e6) return "${(n / 1e6).toStringAsFixed(2)}M";
  if (n >= 1e3) return "${(n / 1e3).toStringAsFixed(1)}K";
  return n.toStringAsFixed(0);
}