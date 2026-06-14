import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/services/report_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds plain text sport-fishing report', () {
    final session = GameSession(
      id: '1',
      name: 'Pace drill',
      date: '06.06.26 10:00',
      c1: 2,
      c2: 3,
      tries: 1,
      total: 5,
      goalFishCount: 5,
      goalTargetPaceSeconds: 60,
      matchDuration: '5:00',
      athleteName: 'Andrew',
      coachName: 'Coach',
      venue: 'River',
      sectorPeg: 'A12',
      trainingType: 'Pace drill',
      fishingMethod: 'Feeder',
      targetPace: '60s',
      conditions: 'Windy',
      baitNotes: 'Worms',
      athleteNote: 'Good focus',
      coachComment: 'Keep pace',
      grid: [
        {
          'type': 1,
          'status': 'green',
          'interval': 60,
          'target': 60,
          'timestamp': '10:00:00',
        },
      ],
    );

    final text = ReportExporter.buildPlainText(session);

    expect(text, contains('FishCounter Training Report'));
    expect(text, contains('Athlete: Andrew'));
    expect(text, contains('Fishing method: Feeder'));
    expect(text, contains('Fish count: 5'));
    expect(text, contains('Target pace: 60s'));
    expect(text, contains('Stability score: 100%'));
    expect(text, contains('Coach comment: Keep pace'));
    expect(text, contains('10:00:00 | C1 | 60s | green'));
  });

  test('builds CSV sport-fishing report', () {
    final session = GameSession(
      id: '1',
      name: 'Pace drill',
      date: '06.06.26 10:00',
      c1: 2,
      c2: 3,
      tries: 1,
      total: 5,
      goalFishCount: 5,
      matchDuration: '5:00',
      athleteName: 'Andrew',
      fishingMethod: 'Feeder',
      grid: [
        {
          'type': 1,
          'status': 'green',
          'interval': 60,
          'target': 60,
          'timestamp': '10:00:00',
        },
      ],
    );

    final csv = ReportExporter.buildCsv(session);

    expect(csv, contains('"session","name","Pace drill"'));
    expect(csv, contains('"context","athlete","Andrew"'));
    expect(csv, contains('"context","fishing_method","Feeder"'));
    expect(csv, contains('"goals","fish_count","5"'));
    expect(csv, contains('"analytics","stability_score","100"'));
    expect(csv, contains('"10:00:00","C1","60","green"'));
  });
}
