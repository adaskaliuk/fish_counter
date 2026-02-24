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
      id: _safeString(json['id']),
      name: _safeString(json['name'], defaultValue: 'Session'),
      date: _safeString(json['date'], defaultValue: '--'),
      c1: _safeInt(json['c1']),
      c2: _safeInt(json['c2']),
      tries: _safeInt(json['tries']),
      total: _safeInt(json['total']),
      matchDuration: _safeString(json['matchDuration'], defaultValue: '00:00:00'),
      grid: _safeGridList(json['grid']),
    );
  }

  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static List<Map<String, dynamic>> _safeGridList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}
