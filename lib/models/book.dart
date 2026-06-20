class Book {
  final String id;
  final String title;
  final double milestone;
  final String bonus; // "click", "auto" or "both"
  final double val;
  final String desc;
  const Book({
    required this.id,
    required this.title,
    required this.milestone,
    required this.bonus,
    required this.val,
    required this.desc,
  });
}