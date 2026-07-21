import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/match_insight_summary.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups activity into five-minute windows including empty windows', () {
    final summary = MatchInsightSummary.fromSession(
      _session([
        {'type': ActivityType.c1Click.value, 'timestamp': '10:01:00'},
        {'type': ActivityType.c2Click.value, 'timestamp': '10:02:00'},
        {'type': ActivityType.c1Click.value, 'timestamp': '10:06:00'},
        {'type': ActivityType.manualPause.value, 'timestamp': '10:12:00'},
        {'type': ActivityType.tryClick.value, 'timestamp': '10:16:00'},
      ]),
    );

    expect(summary, isNotNull);
    expect(summary!.bestWindow.label, '10:00–10:04');
    expect(summary.bestWindow.eventCount, 2);
    expect(summary.quietestWindow.label, '10:10–10:14');
    expect(summary.quietestWindow.eventCount, 0);
  });

  test('associates weather nearest to the highest-activity window', () {
    final summary = MatchInsightSummary.fromSession(
      _session([
        {'type': ActivityType.c1Click.value, 'timestamp': '10:01:00'},
        {'type': ActivityType.c1Click.value, 'timestamp': '10:10:00'},
        {'type': ActivityType.c2Click.value, 'timestamp': '10:11:00'},
      ]),
      snapshots: const [
        WeatherSnapshot(
          latitude: 50,
          longitude: 30,
          placeName: 'Lake',
          description: 'calm',
          temperatureCelsius: 16,
          feelsLikeCelsius: 16,
          pressureHpa: 1012,
          humidityPercent: 70,
          windSpeedMs: 1,
          windDirectionDegrees: 90,
          fetchedAt: '2026-06-06T10:02:00',
        ),
        WeatherSnapshot(
          latitude: 50,
          longitude: 30,
          placeName: 'Lake',
          description: 'windy',
          temperatureCelsius: 20,
          feelsLikeCelsius: 19,
          pressureHpa: 1008,
          humidityPercent: 60,
          windSpeedMs: 5,
          windDirectionDegrees: 180,
          fetchedAt: '2026-06-06T10:12:00',
        ),
      ],
    );

    expect(summary!.nearestWeather?.description, 'windy');
    expect(summary.nearestWeatherTimeLabel, '10:12');
  });

  test('returns no summary without recorded activity', () {
    expect(MatchInsightSummary.fromSession(_session(const [])), isNull);
  });
}

GameSession _session(List<Map<String, dynamic>> grid) {
  return GameSession(
    id: 'summary',
    name: 'Match',
    date: '15.07.26',
    c1: 0,
    c2: 0,
    tries: 0,
    total: 0,
    matchDuration: '1:00:00',
    grid: grid,
  );
}
