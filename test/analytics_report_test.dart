import 'package:fish_counter/models/analytics_report.dart';
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
