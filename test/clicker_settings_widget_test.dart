import 'dart:convert';

import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
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

  testWidgets('start clears previous session artifacts', (tester) async {
    final storage = await useSeededMemoryStorage({
      PrefsKeys.counter1: 4,
      PrefsKeys.counter2: 2,
      PrefsKeys.tries: 1,
      PrefsKeys.total: 6,
      PrefsKeys.isPowerOn: true,
      PrefsKeys.isPaused: true,
      PrefsKeys.isSessionActive: false,
      PrefsKeys.isDataHidden: false,
      PrefsKeys.resetDelay: Defaults.defaultResetDelaySeconds,
      PrefsKeys.vibeInterval: Defaults.defaultVibeIntervalSeconds,
      PrefsKeys.matchSeconds: 0,
      PrefsKeys.activityGrid: '[]',
      PrefsKeys.historySessions: const [],
    });
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

    expect(find.byKey(ClickerScreenKeys.c1ValueKey), findsOneWidget);
    expect(find.byKey(ClickerScreenKeys.totalValueKey), findsOneWidget);
    expect(find.byKey(ClickerScreenKeys.c2ValueKey), findsOneWidget);

    await tester.tap(find.byKey(ClickerScreenKeys.startPauseButtonKey));
    await tester.pump();

    expect(find.text('0'), findsWidgets);
    expect(find.text('6'), findsNothing);
    expect(storage.getInt(PrefsKeys.counter1), 0);
    expect(storage.getInt(PrefsKeys.counter2), 0);
    expect(storage.getInt(PrefsKeys.tries), 0);
    expect(storage.getInt(PrefsKeys.total), 0);
  });

  testWidgets('shows history button when a match exists', (tester) async {
    await useSeededMemoryStorage({
      PrefsKeys.historySessions: [
        jsonEncode(
          GameSession(
            id: '1',
            name: 'Saved match',
            date: '25.06.26',
            c1: 1,
            c2: 0,
            tries: 0,
            total: 1,
            matchDuration: '00:30:00',
            grid: const [],
          ).toJson(),
        ),
      ],
      PrefsKeys.isPowerOn: true,
      PrefsKeys.isPaused: true,
      PrefsKeys.isSessionActive: false,
    });
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

    expect(find.byKey(ClickerScreenKeys.historyButtonKey), findsOneWidget);
  });

  testWidgets('hides history button when no matches exist', (tester) async {
    await useSeededMemoryStorage({
      PrefsKeys.historySessions: const [],
      PrefsKeys.isPowerOn: true,
      PrefsKeys.isPaused: true,
      PrefsKeys.isSessionActive: false,
    });
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

    expect(find.byKey(ClickerScreenKeys.historyButtonKey), findsNothing);
  });

  testWidgets('red power button saves the current session', (tester) async {
    final storage = await useSeededMemoryStorage({
      PrefsKeys.counter1: 2,
      PrefsKeys.counter2: 1,
      PrefsKeys.tries: 1,
      PrefsKeys.total: 3,
      PrefsKeys.isPowerOn: true,
      PrefsKeys.isPaused: false,
      PrefsKeys.isSessionActive: true,
      PrefsKeys.isDataHidden: false,
      PrefsKeys.activityGrid: jsonEncode([
        {'type': 1, 'status': 'green', 'interval': 60, 'target': 60},
      ]),
      PrefsKeys.historySessions: const [],
    });
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

    await tester.tap(find.byKey(ClickerScreenKeys.powerButtonKey));
    await tester.pumpAndSettle();

    final history = storage.getStringList(PrefsKeys.historySessions) ?? const [];
    expect(history, hasLength(1));
    expect(find.byKey(ClickerScreenKeys.historyButtonKey), findsOneWidget);
  });
}
