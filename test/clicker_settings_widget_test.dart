import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('settings exposes shake undo controls', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ClickerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();

    expect(find.text('Shake Undo'), findsOneWidget);
    expect(find.text('Shake Sensitivity'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);

    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();

    expect(find.text('Low'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
