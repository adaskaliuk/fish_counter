import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
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

    final text = ReportExporter.buildPlainText(session, isCoach: true);

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

    final csv = ReportExporter.buildCsv(session, isCoach: true);

    expect(csv, contains('"session","name","Pace drill"'));
    expect(csv, contains('"context","athlete","Andrew"'));
    expect(csv, contains('"context","fishing_method","Feeder"'));
    expect(csv, contains('"goals","fish_count","5"'));
    expect(csv, contains('"analytics","stability_score","100"'));
    expect(csv, contains('"10:00:00","C1","60","green"'));
  });

  test('hides coach-only details and summaries for athlete exports', () {
    final session = GameSession(
      id: '2',
      name: 'Pace drill',
      date: '06.06.26 10:00',
      c1: 2,
      c2: 3,
      tries: 1,
      total: 5,
      goalFishCount: 5,
      matchDuration: '5:00',
      athleteName: 'Andrew',
      coachName: 'Coach',
      coachComment: 'Keep pace',
      trainingType: 'Pace drill',
      fishingMethod: 'Feeder',
      weatherPlace: 'Kyiv',
      weatherDescription: 'Clear',
      grid: const [],
    );

    final text = ReportExporter.buildPlainText(
      session,
      isCoach: false,
      tuning: const HistoricalCatchTuningReport(
        sessionCount: 2,
        fishCountWeight: 1.1,
        stabilityWeight: 0.9,
        triesWeight: 1.05,
        paceWeight: 0.95,
        trackedMetricCount: 4,
      ),
    );
    final csv = ReportExporter.buildCsv(
      session,
      isCoach: false,
      tuning: const HistoricalCatchTuningReport(
        sessionCount: 2,
        fishCountWeight: 1.1,
        stabilityWeight: 0.9,
        triesWeight: 1.05,
        paceWeight: 0.95,
        trackedMetricCount: 4,
      ),
    );

    expect(text, isNot(contains('Coach Analytics')));
    expect(text, isNot(contains('Coach comment')));
    expect(text, isNot(contains('Training type')));
    expect(text, isNot(contains('Fishing method')));
    expect(text, isNot(contains('Weather')));
    expect(text, isNot(contains('Forecast')));
    expect(text, isNot(contains('Readiness score')));
    expect(text, isNot(contains('Historical tuning')));
    expect(csv, isNot(contains('coach')));
    expect(csv, isNot(contains('training_type')));
    expect(csv, isNot(contains('fishing_method')));
    expect(csv, isNot(contains('weather')));
    expect(csv, isNot(contains('forecast')));
    expect(csv, isNot(contains('history_tuning')));
  });

  test('includes coach details for coach exports', () {
    final session = GameSession(
      id: '3',
      name: 'Pace drill',
      date: '06.06.26 10:00',
      c1: 2,
      c2: 3,
      tries: 1,
      total: 5,
      goalFishCount: 5,
      matchDuration: '5:00',
      athleteName: 'Andrew',
      coachName: 'Coach',
      coachComment: 'Keep pace',
      fishingMethod: 'Feeder',
      grid: const [],
    );

    final text = ReportExporter.buildPlainText(session, isCoach: true);

    expect(text, contains('Coach Analytics'));
    expect(text, contains('Coach comment: Keep pace'));
  });

  test('includes forecast and tuning in plain text report', () {
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
      goalMaxTries: 2,
      goalStabilityPercent: 80,
      matchDuration: '5:00',
      athleteName: 'Andrew',
      coachName: 'Coach',
      grid: const [
        {
          'type': 1,
          'status': 'green',
          'interval': 60,
          'target': 60,
          'timestamp': '10:00:00',
        },
      ],
    );

    final text = ReportExporter.buildPlainText(
      session,
      isCoach: true,
      tuning: const HistoricalCatchTuningReport(
        sessionCount: 2,
        fishCountWeight: 1.1,
        stabilityWeight: 0.9,
        triesWeight: 1.05,
        paceWeight: 0.95,
        trackedMetricCount: 4,
      ),
    );

    expect(text, contains('Forecast'));
    expect(text, contains('Readiness score'));
    expect(text, contains('Historical tuning'));
  });
}
