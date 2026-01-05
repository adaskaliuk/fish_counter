// ==========================================
// МОДЕЛЬ СЕСІЇ
// ==========================================
class GameSession {
  final String id, name, date, matchDuration;
  final int c1, c2, tries, total;
  final List<Map<String, dynamic>> grid;

  GameSession({
    required this.id,
    required this.name,
    required this.date,
    required this.c1,
    required this.c2,
    required this.tries,
    required this.total,
    required this.matchDuration,
    required this.grid,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date,
    'c1': c1,
    'c2': c2,
    'tries': tries,
    'total': total,
    'matchDuration': matchDuration,
    'grid': grid,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "Session",
      date: json['date']?.toString() ?? "--",
      c1: json['c1'] ?? 0,
      c2: json['c2'] ?? 0,
      tries: json['tries'] ?? 0,
      total: json['total'] ?? 0,
      matchDuration: json['matchDuration'] ?? "00:00:00",
      grid: List<Map<String, dynamic>>.from(json['grid'] ?? []),
    );
  }
}
