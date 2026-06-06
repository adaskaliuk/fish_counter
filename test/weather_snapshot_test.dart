import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds compact weather summary', () {
    const snapshot = WeatherSnapshot(
      latitude: 50.45,
      longitude: 30.52,
      placeName: 'Kyiv',
      description: 'clear sky',
      temperatureCelsius: 21.5,
      feelsLikeCelsius: 20.0,
      pressureHpa: 1012,
      humidityPercent: 55,
      windSpeedMs: 3.2,
      windDirectionDegrees: 180,
      fetchedAt: '2026-06-06T10:00:00Z',
    );

    expect(snapshot.summary, 'Kyiv • clear sky • 21.5°C • wind 3.2 m/s');
  });
}
