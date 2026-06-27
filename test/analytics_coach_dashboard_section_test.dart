import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/widgets/analytics_coach_dashboard_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders coach dashboard guidance', (tester) async {
    const l10n = AppLocalizations(Locale('en'));
    final session = GameSession(
      id: '1',
      name: 'Session',
      date: '25.06.26',
      c1: 2,
      c2: 2,
      tries: 4,
      total: 6,
      matchDuration: '01:00:00',
      grid: [
        {'type': 1, 'status': 'red', 'interval': 85, 'target': 60},
        {'type': 1, 'status': 'orange', 'interval': 72, 'target': 60},
      ],
      goalFishCount: 10,
      goalTargetPaceSeconds: 60,
      goalMaxTries: 3,
      goalStabilityPercent: 80,
    );
    final report = AnalyticsReport.fromGrid(session.grid);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalyticsCoachDashboardSection(
            session: session,
            report: report,
            l10n: l10n,
            tuning: const HistoricalCatchTuningReport(
              sessionCount: 3,
              fishCountWeight: 0.8,
              stabilityWeight: 1.2,
              triesWeight: 1.1,
              paceWeight: 1.25,
              trackedMetricCount: 4,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Coach Summary'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Target fish count: 10'), findsOneWidget);
    expect(
      find.text(
        'Historical tuning: Fish count 0.80× • Stability 1.20× • Max tries 1.10× • Avg pace 1.25×',
      ),
      findsOneWidget,
    );
  });
}
