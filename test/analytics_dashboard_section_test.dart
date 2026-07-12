import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:fish_counter/widgets/analytics_dashboard_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders readiness dashboard tiles', (tester) async {
    const l10n = AppLocalizations(Locale('en'));
    final session = GameSession(
      id: '1',
      name: 'Session',
      date: '25.06.26',
      c1: 2,
      c2: 2,
      tries: 1,
      total: 4,
      matchDuration: '01:00:00',
      grid: [
        {'type': 1, 'status': 'green', 'interval': 60, 'target': 60},
        {'type': 2, 'status': 'orange', 'interval': 78, 'target': 60},
        {'type': 1, 'status': 'red', 'interval': 120, 'target': 60},
      ],
      weatherDescription: 'clear sky',
      weatherTemperatureCelsius: 20,
      weatherWindSpeedMs: 3,
      weatherPressureHpa: 1015,
      weatherHumidityPercent: 60,
      weatherSnapshots: const [
        WeatherSnapshot(
          latitude: 50,
          longitude: 30,
          placeName: 'River',
          description: 'clear sky',
          temperatureCelsius: 19.5,
          feelsLikeCelsius: 19,
          pressureHpa: 1015,
          humidityPercent: 60,
          windSpeedMs: 3,
          windDirectionDegrees: 180,
          fetchedAt: '2026-06-25T10:00:00Z',
        ),
      ],
    );
    final report = AnalyticsReport.fromGrid(session.grid);
    final activityLogs = [
      ActivityLog.fromRawData(
        type: ActivityType.c1Click,
        status: Status.perfect,
        intervalSeconds: 60,
        targetInterval: 60,
        timestampString: '10:00:00',
      ),
      ActivityLog.fromRawData(
        type: ActivityType.c2Click,
        status: Status.average,
        intervalSeconds: 78,
        targetInterval: 60,
        timestampString: '10:15:00',
      ),
      ActivityLog.fromRawData(
        type: ActivityType.c1Click,
        status: Status.poor,
        intervalSeconds: 120,
        targetInterval: 60,
        timestampString: '10:30:00',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnalyticsDashboardSection(
              session: session,
              report: report,
              activityLogs: activityLogs,
              l10n: l10n,
              isCoach: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Readiness dashboard'), findsOneWidget);
    expect(find.text('7-day forecast'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Phase split'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Best window'), findsOneWidget);
    expect(find.text('Best day'), findsOneWidget);
  });
}
