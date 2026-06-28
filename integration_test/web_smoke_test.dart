import 'package:fish_counter/auth_screen.dart';
import 'package:fish_counter/auth_gate.dart';
import 'package:fish_counter/clicker_screen.dart';
import 'package:fish_counter/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('web smoke', () {
    testWidgets('guest sign-in and clicker flow works', (tester) async {
      await app.main();
      await _pumpUntilVisible(
        tester,
        find.byKey(AuthGateKeys.authScreenKey),
        or: find.byKey(AuthGateKeys.clickerScreenKey),
      );

      if (find.byKey(AuthGateKeys.clickerScreenKey).evaluate().isNotEmpty) {
        await _pumpUntilVisible(
          tester,
          find.byKey(ClickerScreenKeys.signOutButtonKey),
          or: find.byKey(ClickerScreenKeys.powerButtonKey),
        );
        await tester.tap(find.byKey(ClickerScreenKeys.signOutButtonKey));
        await _pumpUntilVisible(tester, find.byKey(AuthGateKeys.authScreenKey));
      }

      expect(find.byKey(AuthScreenStateKeys.emailFieldKey), findsOneWidget);
      expect(find.byKey(AuthScreenStateKeys.passwordFieldKey), findsOneWidget);
      expect(find.byKey(AuthScreenStateKeys.submitButtonKey), findsOneWidget);
      expect(find.byKey(AuthScreenStateKeys.googleButtonKey), findsOneWidget);
      expect(find.byKey(AuthScreenStateKeys.guestButtonKey), findsOneWidget);

      await tester.tap(find.byKey(AuthScreenStateKeys.guestButtonKey));
      await _pumpUntilVisible(tester, find.byKey(AuthGateKeys.clickerScreenKey));
      await _pumpUntilVisible(
        tester,
        find.byKey(ClickerScreenKeys.powerButtonKey),
        or: find.byKey(ClickerScreenKeys.signOutButtonKey),
      );
      await tester.tap(find.byKey(ClickerScreenKeys.settingsButtonKey));
      await _pumpUntilVisible(
        tester,
        find.byKey(SettingsDialogKeys.actionDelayKey),
      );
      expect(find.byKey(SettingsDialogKeys.vibeIntervalKey), findsOneWidget);
      expect(find.byKey(SettingsDialogKeys.saveButtonKey), findsOneWidget);
      await tester.tap(find.byKey(SettingsDialogKeys.saveButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(ClickerScreenKeys.signOutButtonKey), findsOneWidget);

      await tester.tap(find.byKey(ClickerScreenKeys.signOutButtonKey));
      await _pumpUntilVisible(tester, find.byKey(AuthGateKeys.authScreenKey));
    });
  });
}

Future<void> _pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Finder? or,
  int maxPumps = 60,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    final foundPrimary = finder.evaluate().isNotEmpty;
    final foundSecondary = or?.evaluate().isNotEmpty ?? false;
    if (foundPrimary || foundSecondary) return;
  }

  fail('Timed out waiting for expected app entry screen');
}
