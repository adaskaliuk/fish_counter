import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';

class ProgressReport {
  ProgressReport(List<GameSession> sessions)
    : sessions = List.unmodifiable(_sortedOldestFirst(sessions));

  final List<GameSession> sessions;

  int get sessionsAnalyzed => sessions.length;
  bool get hasEnoughForTrend => sessions.length >= 2;

  GameSession? get bestFishCountSession =>
      _maxByInt((session) => session.total);

  GameSession? get bestStabilitySession => _maxByInt(
    (session) => AnalyticsReport.fromGrid(session.grid).stabilityScore,
  );

  GameSession? get fewestTriesSession => _minByInt((session) => session.tries);

  double get averageFishCount =>
      _average((session) => session.total.toDouble());

  double get averageStability => _average(
    (session) =>
        AnalyticsReport.fromGrid(session.grid).stabilityScore.toDouble(),
  );

  int get totalFishDelta =>
      hasEnoughForTrend ? sessions.last.total - sessions.first.total : 0;

  int get stabilityDelta {
    if (!hasEnoughForTrend) return 0;
    return AnalyticsReport.fromGrid(sessions.last.grid).stabilityScore -
        AnalyticsReport.fromGrid(sessions.first.grid).stabilityScore;
  }

  ProgressTrend get fishTrend => _trend(totalFishDelta);
  ProgressTrend get stabilityTrend => _trend(stabilityDelta);

  static List<GameSession> _sortedOldestFirst(List<GameSession> sessions) {
    final sorted = List<GameSession>.from(sessions);
    sorted.sort((a, b) => _dateKey(a).compareTo(_dateKey(b)));
    return sorted;
  }

  static String _dateKey(GameSession session) =>
      session.date.isNotEmpty ? session.date : session.updatedAt;

  GameSession? _maxByInt(int Function(GameSession session) value) {
    if (sessions.isEmpty) return null;
    return sessions.reduce(
      (best, item) => value(item) > value(best) ? item : best,
    );
  }

  GameSession? _minByInt(int Function(GameSession session) value) {
    if (sessions.isEmpty) return null;
    return sessions.reduce(
      (best, item) => value(item) < value(best) ? item : best,
    );
  }

  double _average(double Function(GameSession session) value) {
    if (sessions.isEmpty) return 0;
    return sessions.map(value).reduce((a, b) => a + b) / sessions.length;
  }

  ProgressTrend _trend(int delta) {
    if (delta > 0) return ProgressTrend.improving;
    if (delta < 0) return ProgressTrend.declining;
    return ProgressTrend.stable;
  }
}

enum ProgressTrend { improving, declining, stable }
