import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/fishing_window_forecast_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FishingWindowForecastReport', () {
    test('builds seven forecast days from session context', () {
      final session = GameSession(
        id: 's-1',
        name: 'Session',
        date: '25.06.26',
        c1: 3,
        c2: 2,
        tries: 1,
        total: 12,
        matchDuration: '01:00:00',
        grid: [],
        goalFishCount: 10,
        goalTargetPaceSeconds: 60,
        goalMaxTries: 5,
        goalStabilityPercent: 80,
        weatherDescription: 'clear sky',
        weatherTemperatureCelsius: 21,
        weatherWindSpeedMs: 3,
        weatherPressureHpa: 1016,
        weatherHumidityPercent: 58,
      );

      final report = FishingWindowForecastReport.fromSession(
        session,
        AnalyticsReport.fromGrid([]),
      );

      expect(report.days, hasLength(7));
      expect(report.baseScore, greaterThan(0));
      expect(report.bestDay.score, greaterThanOrEqualTo(report.days.first.score));
      expect(report.days.first.windowLabel(), isNotEmpty);
      expect(report.days.first.dayLabel(), isNotEmpty);
    });
  });
}
