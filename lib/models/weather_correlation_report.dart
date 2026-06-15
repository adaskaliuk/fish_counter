import 'dart:math' as math;

import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';

class WeatherCorrelationReport {
  WeatherCorrelationReport(List<GameSession> sessions)
    : sessionsWithWeather = List.unmodifiable(
        sessions.where((session) => session.weatherTemperatureCelsius != null),
      );

  final List<GameSession> sessionsWithWeather;

  int get sampleSize => sessionsWithWeather.length;
  bool get hasEnoughData => sampleSize >= 2;

  double get averageTemperature =>
      _average((session) => session.weatherTemperatureCelsius ?? 0);

  double get averageWind =>
      _average((session) => session.weatherWindSpeedMs ?? 0);

  GameSession? get bestWeatherSession => _bestByStability();

  double get stabilityTemperatureCorrelation => _correlation(
    (session) => session.weatherTemperatureCelsius,
    (session) =>
        AnalyticsReport.fromGrid(session.grid).stabilityScore.toDouble(),
  );

  double get totalWindCorrelation => _correlation(
    (session) => session.weatherWindSpeedMs,
    (session) => session.total.toDouble(),
  );

  WeatherSignal get temperatureSignal =>
      _signal(stabilityTemperatureCorrelation);
  WeatherSignal get windSignal => _signal(totalWindCorrelation);

  double _average(double Function(GameSession session) value) {
    if (sessionsWithWeather.isEmpty) return 0;
    return sessionsWithWeather.map(value).reduce((a, b) => a + b) /
        sessionsWithWeather.length;
  }

  GameSession? _bestByStability() {
    if (sessionsWithWeather.isEmpty) return null;
    return sessionsWithWeather.reduce((best, item) {
      final bestScore = AnalyticsReport.fromGrid(best.grid).stabilityScore;
      final itemScore = AnalyticsReport.fromGrid(item.grid).stabilityScore;
      return itemScore > bestScore ? item : best;
    });
  }

  double _correlation(
    double? Function(GameSession session) xValue,
    double Function(GameSession session) yValue,
  ) {
    final pairs = sessionsWithWeather
        .map((session) => (x: xValue(session), y: yValue(session)))
        .where((pair) => pair.x != null)
        .map((pair) => (x: pair.x!, y: pair.y))
        .toList();
    if (pairs.length < 2) return 0;

    final xAvg =
        pairs.map((pair) => pair.x).reduce((a, b) => a + b) / pairs.length;
    final yAvg =
        pairs.map((pair) => pair.y).reduce((a, b) => a + b) / pairs.length;
    var numerator = 0.0;
    var xVariance = 0.0;
    var yVariance = 0.0;
    for (final pair in pairs) {
      final xDelta = pair.x - xAvg;
      final yDelta = pair.y - yAvg;
      numerator += xDelta * yDelta;
      xVariance += xDelta * xDelta;
      yVariance += yDelta * yDelta;
    }
    if (xVariance == 0 || yVariance == 0) return 0;
    return numerator / math.sqrt(xVariance * yVariance);
  }

  WeatherSignal _signal(double value) {
    if (value > .25) return WeatherSignal.positive;
    if (value < -.25) return WeatherSignal.negative;
    return WeatherSignal.neutral;
  }
}

enum WeatherSignal { positive, negative, neutral }
