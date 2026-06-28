import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows sync badge when retry is pending', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ClickerScreen(
          enableBackgroundTasks: false,
          initialSyncPending: true,
        ),
      ),
    );

    await _pumpUntilVisible(tester, find.byKey(ClickerScreenKeys.syncBadgeButtonKey));
  });
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 200));
  }
  fail('Timed out waiting for sync badge');
}
