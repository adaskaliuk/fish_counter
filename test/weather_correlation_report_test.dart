import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/weather_correlation_report.dart';
import 'package:flutter_test/flutter_test.dart';

GameSession _session({
  required String id,
  required double temp,
  required double wind,
  required int total,
  required String status,
}) {
  return GameSession(
    id: id,
    name: id,
    date: '2026-06-15',
    c1: total,
    c2: 0,
    tries: 0,
    total: total,
    matchDuration: '1:00',
    weatherTemperatureCelsius: temp,
    weatherWindSpeedMs: wind,
    weatherDescription: 'clear',
    grid: [
      {'type': 1, 'status': status, 'interval': 60, 'target': 60},
    ],
  );
}

void main() {
  test('calculates weather correlations from sessions', () {
    final report = WeatherCorrelationReport([
      _session(id: 'cold', temp: 10, wind: 6, total: 3, status: 'red'),
      _session(id: 'warm', temp: 20, wind: 2, total: 8, status: 'green'),
    ]);

    expect(report.sampleSize, 2);
    expect(report.hasEnoughData, true);
    expect(report.bestWeatherSession?.id, 'warm');
    expect(report.temperatureSignal, WeatherSignal.positive);
    expect(report.windSignal, WeatherSignal.negative);
  });
}
