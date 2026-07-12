import 'package:fish_counter/auth_gate.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fish_counter/auth_screen.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/widgets/analytics_coach_dashboard_section.dart';
import 'package:fish_counter/widgets/analytics_screen_body.dart';
import 'package:fish_counter/widgets/analytics_weather_section.dart';
import 'package:fish_counter/widgets/session_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  group('auth-role persistence', () {
    test('PrefsRepository round-trips role across create()', () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      final repo = await PrefsRepository.create();
      await repo.saveAthleteProfile(const AthleteProfile(role: 'coach'));

      final repo2 = await PrefsRepository.create();
      expect(repo2.loadAthleteProfile().role, 'coach');
      expect(repo2.loadAthleteProfile().isCoach, isTrue);
    });

    test('empty role defaults to athlete', () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      final repo = await PrefsRepository.create();
      expect(repo.loadAthleteProfile().role, '');
      expect(repo.loadAthleteProfile().isAthlete, isTrue);
    });
  });

  group('auth-role ui visibility', () {
    const l10n = AppLocalizations(Locale('en'));
    final session = GameSession(
      id: '1',
      name: 'S',
      date: '25.06.26',
      c1: 0,
      c2: 0,
      tries: 0,
      total: 0,
      matchDuration: '0:00',
      grid: const [],
    );
    final report = AnalyticsReport.fromGrid(session.grid);

    Future<void> pump(WidgetTester tester, {required bool isCoach}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsScreenBody(
              session: session,
              report: report,
              activityLogs: const [],
              l10n: l10n,
              isCoach: isCoach,
            ),
          ),
        ),
      );
    }

    testWidgets('coach sees coach dashboard and weather sections', (tester) async {
      await pump(tester, isCoach: true);
      expect(find.byType(AnalyticsCoachDashboardSection), findsOneWidget);
      expect(find.byType(AnalyticsWeatherSection), findsOneWidget);
    });

    testWidgets('athlete does not see coach dashboard or weather sections', (tester) async {
      await pump(tester, isCoach: false);
      expect(find.byType(AnalyticsCoachDashboardSection), findsNothing);
      expect(find.byType(AnalyticsWeatherSection), findsNothing);
      expect(find.text('Readiness dashboard'), findsNothing);
      expect(find.text('Readiness'), findsNothing);
      expect(find.text('7-day forecast'), findsNothing);
    });

    testWidgets('athlete session edit hides coach-only fields and preserves values', (tester) async {
      final session = GameSession(
        id: 'edit',
        name: 'S',
        date: '25.06.26',
        c1: 0,
        c2: 0,
        tries: 0,
        total: 0,
        matchDuration: '0:00',
        grid: const [],
        trainingType: 'Pace drill',
        fishingMethod: 'Feeder',
      );
      GameSession? updated;

      await tester.pumpWidget(MaterialApp(
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
            child: const Text('edit'),
          ),
        ),
      ));

      await tester.tap(find.text('edit'));
      await tester.pumpAndSettle();

      expect(find.text('Training type'), findsNothing);
      expect(find.text('Fishing method'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(updated!.venueInfo.trainingType, 'Pace drill');
      expect(updated!.venueInfo.fishingMethod, 'Feeder');
    });
  });

  group('auth-role signup flow', () {
    // ponytail: covers post-login role prompt → save → prefs.
    // FirebaseAuth signup/login itself is the SDK's contract, not ours.
    testWidgets('role prompt saves selection to prefs', (tester) async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleSetupScreen(),
      ));

      // Initially: Save disabled, no role in prefs.
      final saveBtn = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(saveBtn).onPressed, isNull);

      final repo0 = await PrefsRepository.create();
      expect(repo0.loadAthleteProfile().role, '');

      // Pick "Coach" from dropdown.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coach').last);
      await tester.pumpAndSettle();

      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final repo = await PrefsRepository.create();
      expect(repo.loadAthleteProfile().role, 'coach');
      expect(repo.loadAthleteProfile().isCoach, isTrue);
    });

    testWidgets('role save preserves existing profile fields', (tester) async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      // Seed a legacy profile (empty role, but other fields present).
      final seed = await PrefsRepository.create();
      await seed.saveAthleteProfile(const AthleteProfile(
        athleteName: 'Anna',
        defaultVenue: 'Lake',
        coachName: 'Boris',
      ));

      var savedCalls = 0;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RoleSetupScreen(onSaved: () => savedCalls++),
      ));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Athlete').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final repo = await PrefsRepository.create();
      final profile = repo.loadAthleteProfile();
      expect(profile.role, 'athlete');
      expect(profile.athleteName, 'Anna');
      expect(profile.defaultVenue, 'Lake');
      expect(profile.coachName, 'Boris');
      expect(savedCalls, 1);
    });
  });


  group('auth-role signup end-to-end (mock FirebaseAuth)', () {
    testWidgets('login mode hides role picker', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthScreen(auth: MockFirebaseAuth()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('register creates user and preserves existing profile fields', (tester) async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      final seed = await PrefsRepository.create();
      await seed.saveAthleteProfile(const AthleteProfile(
        athleteName: 'Anna',
        defaultVenue: 'Lake',
      ));
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthScreen(auth: auth),
      ));
      await tester.pumpAndSettle();

      // Switch to register mode.
      await tester.tap(find.text('Need an account? Register'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(AuthScreenStateKeys.emailFieldKey), 'a@b.com');
      await tester.enterText(
          find.byKey(AuthScreenStateKeys.passwordFieldKey), 'pw123456');

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coach').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(AuthScreenStateKeys.submitButtonKey));
      await tester.pumpAndSettle();

      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, 'a@b.com');

      final repo = await PrefsRepository.create();
      final profile = repo.loadAthleteProfile();
      expect(profile.role, 'coach');
      expect(profile.isCoach, isTrue);
      expect(profile.athleteName, 'Anna');
      expect(profile.defaultVenue, 'Lake');
    });

    testWidgets('login with existing user does not clobber role', (tester) async {
      final storage = await useMemoryStorage();
      addTearDown(resetMemoryStorage);
      // Seed athlete role in prefs.
      final seed = await PrefsRepository.create();
      await seed.saveAthleteProfile(const AthleteProfile(role: 'athlete'));
      // ignore: unused_local_variable
      final _ = storage;

      final signedIn = MockUser(email: 'x@y.com', uid: 'u1');
      final auth = MockFirebaseAuth(mockUser: signedIn);

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthScreen(auth: auth),
      ));
      await tester.pumpAndSettle();

      // Default is login mode.
      await tester.enterText(
          find.byKey(AuthScreenStateKeys.emailFieldKey), 'x@y.com');
      await tester.enterText(
          find.byKey(AuthScreenStateKeys.passwordFieldKey), 'pw');

      await tester.tap(find.byKey(AuthScreenStateKeys.submitButtonKey));
      await tester.pumpAndSettle();

      final repo = await PrefsRepository.create();
      expect(repo.loadAthleteProfile().role, 'athlete');
    });
  });
}
