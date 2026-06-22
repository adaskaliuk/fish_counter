import 'package:fish_counter/constants.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/widgets/activity_heatmap_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders activity heatmap card and legend', (tester) async {
    const l10n = AppLocalizations(Locale('en'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityHeatmapCard(
            l10n: l10n,
            logs: [
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
                intervalSeconds: 45,
                targetInterval: 60,
                timestampString: '10:01:00',
              ),
              ActivityLog.fromRawData(
                type: ActivityType.manualPause,
                status: Status.pause,
                intervalSeconds: 0,
                targetInterval: 60,
                timestampString: '10:02:00',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Activity heatmap'), findsOneWidget);
    expect(find.text('PAUSE / RESET'), findsOneWidget);
    expect(find.byType(Tooltip), findsNWidgets(3));
  });
}
