import 'dart:async';

import 'package:fish_counter/auth_gate.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading while startup sync runs then opens clicker', (
    tester,
  ) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StartupSyncedClickerScreen(
          startupSyncBuilder: () => completer.future,
          enableBackgroundTasks: false,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ClickerScreen), findsNothing);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ClickerScreen), findsOneWidget);
  });

  testWidgets('retries pending sync on resume after startup', (tester) async {
    final startupCompleter = Completer<void>();
    var foregroundRetryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StartupSyncedClickerScreen(
          startupSyncBuilder: () => startupCompleter.future,
          foregroundSyncBuilder: () async {
            foregroundRetryCount += 1;
          },
          enableBackgroundTasks: false,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    startupCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.byType(ClickerScreen), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(
      AppLifecycleState.resumed,
    );
    await tester.pump();

    expect(foregroundRetryCount, 1);
  });
}
