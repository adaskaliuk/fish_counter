import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/progress_report.dart';
import 'package:flutter_test/flutter_test.dart';

GameSession _session({
  required String id,
  required String date,
  required int total,
  required int tries,
  required String status,
}) {
  return GameSession(
    id: id,
    name: id,
    date: date,
    c1: total,
    c2: 0,
    tries: tries,
    total: total,
    matchDuration: '1:00',
    grid: [
      {'type': 1, 'status': status, 'interval': 60, 'target': 60},
    ],
  );
}

void main() {
  test('calculates personal records and trends', () {
    final report = ProgressReport([
      _session(
        id: 'new',
        date: '2026-06-03',
        total: 8,
        tries: 1,
        status: 'green',
      ),
      _session(
        id: 'old',
        date: '2026-06-01',
        total: 5,
        tries: 3,
        status: 'red',
      ),
    ]);

    expect(report.sessionsAnalyzed, 2);
    expect(report.bestFishCountSession?.id, 'new');
    expect(report.fewestTriesSession?.id, 'new');
    expect(report.totalFishDelta, 3);
    expect(report.stabilityDelta, greaterThan(0));
    expect(report.fishTrend, ProgressTrend.improving);
  });
}
