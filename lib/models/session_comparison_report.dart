import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';

class SessionComparisonReport {
  SessionComparisonReport({required this.base, required this.compare})
    : baseAnalytics = AnalyticsReport.fromGrid(base.grid),
      compareAnalytics = AnalyticsReport.fromGrid(compare.grid);

  final GameSession base;
  final GameSession compare;
  final AnalyticsReport baseAnalytics;
  final AnalyticsReport compareAnalytics;

  int get totalDelta => compare.total - base.total;
  int get c1Delta => compare.c1 - base.c1;
  int get c2Delta => compare.c2 - base.c2;
  int get triesDelta => compare.tries - base.tries;
  int get stabilityDelta =>
      compareAnalytics.stabilityScore - baseAnalytics.stabilityScore;
  double get averageIntervalDelta =>
      compareAnalytics.averageInterval - baseAnalytics.averageInterval;
  double get averageDeviationDelta =>
      compareAnalytics.averageDeviation - baseAnalytics.averageDeviation;
  int get longestStableStreakDelta =>
      compareAnalytics.longestStableStreak - baseAnalytics.longestStableStreak;
}
