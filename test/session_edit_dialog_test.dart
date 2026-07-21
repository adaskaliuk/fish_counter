import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/widgets/session_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('session edit saves final weight and count', (tester) async {
    final session = GameSession(
      id: 'edit-result',
      name: 'Match',
      date: '15.07.26',
      c1: 1,
      c2: 1,
      tries: 0,
      total: 2,
      matchDuration: '1:00:00',
      grid: const [],
    );
    GameSession? updated;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              updated = await SessionEditDialog.show(context, session);
            },
            child: const Text('Edit'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    Finder field(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );
    await tester.enterText(field('Final weight (kg)'), '2,75');
    await tester.enterText(field('Final count'), '14');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(updated, isNotNull);
    expect(updated!.finalWeightKg, 2.75);
    expect(updated!.finalCount, 14);
  });
}
