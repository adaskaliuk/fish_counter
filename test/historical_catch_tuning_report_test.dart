import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives tuning weights from history', () {
    final sessions = [
      GameSession(
        id: '1',
        name: 'A',
        date: '25.06.26',
        c1: 3,
        c2: 2,
        tries: 1,
        total: 10,
        matchDuration: '01:00:00',
        grid: [
          {'type': 1, 'status': 'green', 'interval': 60, 'target': 60},
        ],
        goalFishCount: 8,
        goalTargetPaceSeconds: 60,
        goalMaxTries: 5,
        goalStabilityPercent: 70,
      ),
      GameSession(
        id: '2',
        name: 'B',
        date: '26.06.26',
        c1: 1,
        c2: 1,
        tries: 4,
        total: 4,
        matchDuration: '01:00:00',
        grid: [
          {'type': 1, 'status': 'orange', 'interval': 75, 'target': 60},
        ],
        goalFishCount: 8,
        goalTargetPaceSeconds: 60,
        goalMaxTries: 5,
        goalStabilityPercent: 70,
      ),
    ];

    final report = HistoricalCatchTuningReport.fromSessions(sessions);

    expect(report.sessionCount, 2);
    expect(report.fishCountWeight, greaterThan(0.75));
    expect(report.stabilityWeight, greaterThan(0.75));
    expect(report.triesWeight, equals(1));
    expect(report.paceWeight, greaterThan(0.75));
    expect(report.compactSummary, isNotEmpty);
  });

  test('keeps neutral weights for missing goals', () {
    final sessions = [
      GameSession(
        id: '1',
        name: 'A',
        date: '25.06.26',
        c1: 3,
        c2: 2,
        tries: 1,
        total: 10,
        matchDuration: '01:00:00',
        grid: [
          {'type': 1, 'status': 'green', 'interval': 60, 'target': 60},
        ],
      ),
    ];

    final report = HistoricalCatchTuningReport.fromSessions(sessions);

    expect(report.sessionCount, 1);
    expect(report.fishCountWeight, 1);
    expect(report.triesWeight, 1);
    expect(report.paceWeight, 1);
    expect(report.stabilityWeight, isNot(1));
  });
}
