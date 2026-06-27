import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_presets.dart';
import 'package:fish_counter/services/readiness_score_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preset weights influence readiness score', () {
    final report = AnalyticsReport.fromGrid([
      {'type': 1, 'status': 'green', 'interval': 60, 'target': 60},
      {'type': 2, 'status': 'orange', 'interval': 58, 'target': 60},
      {'type': 1, 'status': 'red', 'interval': 130, 'target': 60},
    ]);

    final base = GameSession(
      id: 'base',
      name: 'Base',
      date: '25.06.26',
      c1: 2,
      c2: 1,
      tries: 3,
      total: 3,
      matchDuration: '01:00:00',
      grid: [],
      goalFishCount: 5,
      goalTargetPaceSeconds: 60,
      goalMaxTries: 4,
      goalStabilityPercent: 70,
    );

    final preset = base.copyWith(
      venueInfo: base.venueInfo.copyWith(
        speciesPreset: FishingPresets.speciesCarp,
        bodyTypePreset: FishingPresets.bodyStocky,
      ),
    );

      expect(
        ReadinessScoreCalculator.calculate(preset, report),
        greaterThan(ReadinessScoreCalculator.calculate(base, report)),
      );
  });
}
