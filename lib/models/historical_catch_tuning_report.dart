import 'dart:math' as math;

import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';

class HistoricalCatchTuningReport {
  final int sessionCount;
  final double fishCountWeight;
  final double stabilityWeight;
  final double triesWeight;
  final double paceWeight;
  final int trackedMetricCount;

  const HistoricalCatchTuningReport({
    required this.sessionCount,
    required this.fishCountWeight,
    required this.stabilityWeight,
    required this.triesWeight,
    required this.paceWeight,
    required this.trackedMetricCount,
  });

  bool get isEmpty => sessionCount == 0;

  Map<String, dynamic> toJson() => {
    'sessionCount': sessionCount,
    'fishCountWeight': fishCountWeight,
    'stabilityWeight': stabilityWeight,
    'triesWeight': triesWeight,
    'paceWeight': paceWeight,
    'trackedMetricCount': trackedMetricCount,
  };

  factory HistoricalCatchTuningReport.fromJson(Map<String, dynamic> json) {
    return HistoricalCatchTuningReport(
      sessionCount: _toInt(json['sessionCount']),
      fishCountWeight: _toDouble(json['fishCountWeight'], defaultValue: 1),
      stabilityWeight: _toDouble(json['stabilityWeight'], defaultValue: 1),
      triesWeight: _toDouble(json['triesWeight'], defaultValue: 1),
      paceWeight: _toDouble(json['paceWeight'], defaultValue: 1),
      trackedMetricCount: _toInt(json['trackedMetricCount']),
    );
  }

  String get compactSummary {
    if (trackedMetricCount == 0) return '';
    return [
      'fish ${fishCountWeight.toStringAsFixed(2)}×',
      'stability ${stabilityWeight.toStringAsFixed(2)}×',
      'tries ${triesWeight.toStringAsFixed(2)}×',
      'pace ${paceWeight.toStringAsFixed(2)}×',
    ].join(' • ');
  }

  factory HistoricalCatchTuningReport.fromSessions(List<GameSession> sessions) {
    if (sessions.isEmpty) {
      return const HistoricalCatchTuningReport(
        sessionCount: 0,
        fishCountWeight: 1,
        stabilityWeight: 1,
        triesWeight: 1,
        paceWeight: 1,
        trackedMetricCount: 0,
      );
    }

    final fishScores = <double>[];
    final stabilityScores = <double>[];
    final triesScores = <double>[];
    final paceScores = <double>[];

    for (final session in sessions) {
      final report = AnalyticsReport.fromGrid(session.grid);

      if (session.goalFishCount > 0) {
        fishScores.add((session.total / session.goalFishCount) * 100);
      }

      stabilityScores.add(report.stabilityScore.toDouble());

      if (session.goalMaxTries > 0) {
        triesScores.add(100 - (session.tries / session.goalMaxTries) * 100);
      }

      if (session.goalTargetPaceSeconds > 0 && report.averageInterval > 0) {
        paceScores.add(
          100 -
              ((report.averageInterval - session.goalTargetPaceSeconds).abs() /
                      session.goalTargetPaceSeconds) *
                  100,
        );
      }
    }

    return HistoricalCatchTuningReport(
      sessionCount: sessions.length,
      fishCountWeight: _weightFromAverage(fishScores),
      stabilityWeight: _weightFromAverage(stabilityScores),
      triesWeight: _weightFromAverage(triesScores),
      paceWeight: _weightFromAverage(paceScores),
      trackedMetricCount:
          fishScores.length + stabilityScores.length + triesScores.length + paceScores.length,
    );
  }

  static HistoricalCatchTuningReport neutral([int sessionCount = 0]) {
    return HistoricalCatchTuningReport(
      sessionCount: sessionCount,
      fishCountWeight: 1,
      stabilityWeight: 1,
      triesWeight: 1,
      paceWeight: 1,
      trackedMetricCount: 0,
    );
  }

  static double _weightFromAverage(List<double> scores) {
    if (scores.isEmpty) return 1;
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final normalized = 1 / (1 + math.exp(-(average - 50) / 15));
    return 0.75 + (normalized * 0.5);
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  static double _toDouble(dynamic value, {double defaultValue = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
