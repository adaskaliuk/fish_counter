import 'dart:async';

import 'package:fish_counter/auth_gate.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

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

  testWidgets('shows history button after startup sync brings a match', (
    tester,
  ) async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);

    final startupCompleter = Completer<void>();

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
          startupSyncBuilder: () async {
            final repo = await PrefsRepository.create();
            await repo.saveSessionHistory([
              GameSession(
                id: '1',
                name: 'Remote match',
                date: '25.06.26',
                c1: 1,
                c2: 0,
                tries: 0,
                total: 1,
                matchDuration: '00:30:00',
                grid: const [],
              ),
            ]);
            startupCompleter.complete();
            return startupCompleter.future;
          },
          enableBackgroundTasks: false,
        ),
      ),
    );

    await tester.pump();
    await startupCompleter.future;
    await tester.pumpAndSettle();

    expect(find.byType(ClickerScreen), findsOneWidget);
    expect(find.byKey(ClickerScreenKeys.historyButtonKey), findsOneWidget);
  });
}
