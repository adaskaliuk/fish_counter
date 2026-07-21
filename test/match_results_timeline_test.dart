import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:fish_counter/widgets/analytics_screen_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const l10n = AppLocalizations(Locale('en'));

void main() {
  testWidgets('shows event labels and timestamps in match timeline', (
    tester,
  ) async {
    final grid = [
      {
        'type': ActivityType.c1Click.value,
        'status': 'green',
        'interval': 60,
        'target': 60,
        'timestamp': '10:01:00',
      },
      {
        'type': ActivityType.c2Click.value,
        'status': 'orange',
        'interval': 90,
        'target': 60,
        'timestamp': '10:02:30',
      },
      {
        'type': ActivityType.tryClick.value,
        'status': 'red',
        'interval': 30,
        'target': 60,
        'timestamp': '10:03:00',
      },
    ];
    final session = _session(grid: grid);
    await _pump(tester, session);

    expect(find.text('Activity Timeline:'), findsWidgets);
    expect(find.text('C1 Click'), findsOneWidget);
    expect(find.text('C2 Click'), findsOneWidget);
    expect(find.text('Try Error'), findsOneWidget);
    expect(find.text('10:01'), findsOneWidget);
    expect(find.text('10:02'), findsOneWidget);
    expect(find.text('10:01:00'), findsOneWidget);
    expect(find.text('10:02:30'), findsOneWidget);
    expect(find.text('10:03:00'), findsOneWidget);
    expect(
      find.textContaining('highest activity window 10:00–10:04 (3 events)'),
      findsOneWidget,
    );
  });

  testWidgets('summarizes real five-minute activity windows', (tester) async {
    final session = _session(
      grid: [
        {'type': ActivityType.c1Click.value, 'timestamp': '10:01:00'},
        {'type': ActivityType.c2Click.value, 'timestamp': '10:02:00'},
        {'type': ActivityType.c1Click.value, 'timestamp': '10:06:00'},
        {'type': ActivityType.tryClick.value, 'timestamp': '10:16:00'},
      ],
    );

    await _pump(tester, session);

    expect(
      find.textContaining('highest activity window 10:00–10:04 (2 events)'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Quietest window 10:10–10:14 (0 events)'),
      findsOneWidget,
    );
  });

  testWidgets('associates nearest weather with the best window', (
    tester,
  ) async {
    final session = _session(
      grid: [
        {'type': ActivityType.c1Click.value, 'timestamp': '10:01:00'},
        {'type': ActivityType.c1Click.value, 'timestamp': '10:10:00'},
        {'type': ActivityType.c2Click.value, 'timestamp': '10:11:00'},
      ],
      weatherSnapshots: const [
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

    await _pump(tester, session);

    expect(
      find.textContaining('Nearby weather: windy, 20.0°C at 10:12'),
      findsOneWidget,
    );
  });

  testWidgets('shows weather snapshots during match', (tester) async {
    final session = _session(
      weatherSnapshots: const [
        WeatherSnapshot(
          latitude: 50,
          longitude: 30,
          placeName: 'Lake',
          description: 'cloudy',
          temperatureCelsius: 18,
          feelsLikeCelsius: 17,
          pressureHpa: 1010,
          humidityPercent: 70,
          windSpeedMs: 3,
          windDirectionDegrees: 180,
          fetchedAt: '10:00',
        ),
        WeatherSnapshot(
          latitude: 50,
          longitude: 30,
          placeName: 'Lake',
          description: 'windy',
          temperatureCelsius: 20,
          feelsLikeCelsius: 18,
          pressureHpa: 1008,
          humidityPercent: 65,
          windSpeedMs: 5,
          windDirectionDegrees: 200,
          fetchedAt: '10:15',
        ),
      ],
    );

    await _pump(tester, session);

    expect(find.text('Weather during match'), findsOneWidget);
    expect(find.textContaining('temp up 2.0'), findsOneWidget);
    expect(find.textContaining('pressure down 2.0'), findsOneWidget);
    expect(find.textContaining('max wind 5.0 m/s'), findsOneWidget);
    expect(find.textContaining('Temperature: 18.0°C'), findsOneWidget);
    expect(find.textContaining('Pressure: 1010 hPa'), findsOneWidget);
    expect(find.textContaining('Wind speed: 3.0 m/s'), findsOneWidget);
  });

  testWidgets('shows weather fallback when no data exists', (tester) async {
    await _pump(tester, _session());
    expect(find.text('No weather data for this match'), findsOneWidget);
  });
}

GameSession _session({
  List<Map<String, dynamic>> grid = const [],
  List<WeatherSnapshot> weatherSnapshots = const [],
}) {
  return GameSession(
    id: '1',
    name: 'Session',
    date: '06.06.26 10:00',
    c1: 1,
    c2: 1,
    tries: 1,
    total: 2,
    matchDuration: '0:30',
    grid: grid,
    weatherSnapshots: weatherSnapshots,
    updatedAt: '2026-06-06T10:30:00Z',
  );
}

Future<void> _pump(WidgetTester tester, GameSession session) {
  final report = AnalyticsReport.fromGrid(session.grid);
  final logs = session.grid.map(ActivityLog.fromJson).toList();
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AnalyticsScreenBody(
          session: session,
          report: report,
          activityLogs: logs,
          l10n: l10n,
          isCoach: true,
        ),
      ),
    ),
  );
}
