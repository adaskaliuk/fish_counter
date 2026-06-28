import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  testWidgets('settings exposes shake undo controls', (tester) async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ClickerScreen(enableBackgroundTasks: false),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(ClickerScreenKeys.settingsButtonKey), findsOneWidget);
  });
}
