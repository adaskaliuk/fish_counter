import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/services/readiness_score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsReport', () {
    test('calculates coach metrics from activity grid', () {
      final report = AnalyticsReport.fromGrid([
        _entry(type: 1, status: 'green', interval: 60, target: 60),
        _entry(type: 2, status: 'orange', interval: 45, target: 60),
        _entry(type: 3, status: 'grey', interval: 30, target: 60),
        _entry(type: 1, status: 'red', interval: 120, target: 60),
        _entry(type: 0, status: 'grey', interval: 0, target: 60),
      ]);

      expect(report.greenCount, 1);
      expect(report.orangeCount, 1);
      expect(report.greyCount, 1);
      expect(report.redCount, 1);
      expect(report.tryCount, 1);
      expect(report.earlyCount, 1);
      expect(report.lateCount, 1);
      expect(report.bestIntervalSeconds, 30);
      expect(report.worstIntervalSeconds, 120);
      expect(report.averageInterval, 63.75);
      expect(report.averageDeviation, 3.75);
      expect(report.stabilityScore, 55);
      expect(report.longestStableStreak, 2);

      final session = GameSession(
        id: 's-1',
        name: 'Session',
        date: '2026-06-25',
        c1: 3,
        c2: 2,
        tries: 1,
        total: 12,
        matchDuration: '01:00:00',
        grid: [],
        goalFishCount: 10,
        goalTargetPaceSeconds: 60,
        goalMaxTries: 5,
        goalStabilityPercent: 80,
      );

      expect(ReadinessScoreCalculator.calculate(session, report), 91);

      expect(
        ReadinessScoreCalculator.calculate(
          session,
          report,
          tuning: const HistoricalCatchTuningReport(
            sessionCount: 4,
            fishCountWeight: 1.25,
            stabilityWeight: 0.75,
            triesWeight: 0.75,
            paceWeight: 0.75,
            trackedMetricCount: 4,
          ),
        ),
        isNot(91),
      );
    });

    test('handles empty grid', () {
      final report = AnalyticsReport.fromGrid([]);

      expect(report.validClickCount, 0);
      expect(report.bestIntervalSeconds, isNull);
      expect(report.worstIntervalSeconds, isNull);
      expect(report.averageInterval, 0);
      expect(report.averageDeviation, 0);
      expect(report.stabilityScore, 0);
    });
  });
}

Map<String, dynamic> _entry({
  required int type,
  required String status,
  required int interval,
  required int target,
}) {
  return {
    'type': type,
    'status': status,
    'interval': interval,
    'target': target,
  };
}
