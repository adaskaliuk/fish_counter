import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/session_comparison_report.dart';
import 'package:flutter_test/flutter_test.dart';

GameSession _session({
  required String id,
  required int total,
  required int tries,
}) {
  return GameSession(
    id: id,
    name: id,
    date: 'date',
    c1: total,
    c2: 0,
    tries: tries,
    total: total,
    matchDuration: '1:00',
    grid: [
      {
        'type': 1,
        'status': total > 5 ? 'green' : 'red',
        'interval': 60,
        'target': 60,
      },
    ],
  );
}

void main() {
  test('compares session counters and analytics', () {
    final report = SessionComparisonReport(
      base: _session(id: 'base', total: 4, tries: 3),
      compare: _session(id: 'compare', total: 7, tries: 1),
    );

    expect(report.totalDelta, 3);
    expect(report.triesDelta, -2);
    expect(report.stabilityDelta, greaterThan(0));
  });
}
