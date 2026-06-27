import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_presets.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';

class ReadinessScoreCalculator {
  static int calculate(
    GameSession session,
    AnalyticsReport report, {
    HistoricalCatchTuningReport? tuning,
  }) {
    final weights = FishingPresets.weightsFor(
      speciesPreset: session.speciesPreset,
      bodyTypePreset: session.bodyTypePreset,
    );
    final tuningWeights = tuning ?? HistoricalCatchTuningReport.neutral();
    final weightedScores = <double>[];
    final weightedWeights = <double>[];

    void addScore(int score, double weight) {
      weightedScores.add(score * weight);
      weightedWeights.add(weight);
    }

    addScore(
      session.goalStabilityPercent > 0
          ? _percentScore(report.stabilityScore, session.goalStabilityPercent)
          : report.stabilityScore,
      weights.stability * tuningWeights.stabilityWeight,
    );

    if (session.goalFishCount > 0) {
      addScore(
        _percentScore(session.total, session.goalFishCount),
        weights.fishCount * tuningWeights.fishCountWeight,
      );
    }

    if (session.goalMaxTries > 0) {
      addScore(
        _reversePercentScore(session.tries, session.goalMaxTries),
        weights.tries * tuningWeights.triesWeight,
      );
    }

    if (session.goalTargetPaceSeconds > 0 && report.averageInterval > 0) {
      addScore(
        _reversePercentScore(
          (report.averageInterval - session.goalTargetPaceSeconds).abs(),
          session.goalTargetPaceSeconds,
        ),
        weights.pace * tuningWeights.paceWeight,
      );
    }

    return (weightedScores.reduce((a, b) => a + b) /
            weightedWeights.reduce((a, b) => a + b))
        .round();
  }

  static int _percentScore(num value, num target) {
    return ((value / target) * 100).round();
  }

  static int _reversePercentScore(num value, num target) {
    return (100 - ((value / target) * 100)).round();
  }
}
