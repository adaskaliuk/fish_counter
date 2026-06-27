import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
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
      ],
      weatherDescription: 'clear sky',
      weatherTemperatureCelsius: 20,
      weatherWindSpeedMs: 3,
      weatherPressureHpa: 1015,
      weatherHumidityPercent: 60,
    );
    final report = AnalyticsReport.fromGrid(session.grid);

    await tester.pumpWidget(
      const MaterialApp(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalyticsDashboardSection(
            session: session,
            report: report,
            l10n: l10n,
          ),
        ),
      ),
    );

    expect(find.text('Readiness dashboard'), findsOneWidget);
    expect(find.text('7-day forecast'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Best window'), findsOneWidget);
    expect(find.text('Best day'), findsOneWidget);
  });
}
