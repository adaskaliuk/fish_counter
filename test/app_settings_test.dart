import 'package:fish_counter/models/app_settings.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppSettings serializes profile and settings', () {
    const settings = AppSettings(
      syncHistoryEnabled: true,
      resetDelay: 10,
      vibeInterval: 45,
      matchSeconds: 3600,
      shakeUndoEnabled: false,
      shakeSensitivity: 'high',
      athleteProfile: AthleteProfile(athleteName: 'Athlete'),
      updatedAt: '2026-06-14T10:00:00.000',
    );

    final parsed = AppSettings.fromJson(settings.toJson());

    expect(parsed.syncHistoryEnabled, true);
    expect(parsed.vibeInterval, 45);
    expect(parsed.shakeUndoEnabled, false);
    expect(parsed.athleteProfile.athleteName, 'Athlete');
  });

  test('PrefsRepository applies and loads app settings', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = await PrefsRepository.create();

    await repo.applyAppSettings(
      const AppSettings(
        syncHistoryEnabled: true,
        resetDelay: 9,
        vibeInterval: 30,
        matchSeconds: 1200,
        shakeUndoEnabled: false,
        shakeSensitivity: 'low',
        athleteProfile: AthleteProfile(defaultVenue: 'River'),
        updatedAt: '2026-06-14T10:00:00.000Z',
      ),
    );

    final loaded = repo.loadAppSettings();

    expect(loaded.syncHistoryEnabled, true);
    expect(loaded.resetDelay, 9);
    expect(loaded.matchSeconds, 1200);
    expect(loaded.athleteProfile.defaultVenue, 'River');
    expect(loaded.updatedAt, '2026-06-14T10:00:00.000Z');
  });

  test('PrefsRepository touchSettingsUpdatedAt bumps updatedAt', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = await PrefsRepository.create();

    await repo.touchSettingsUpdatedAt();

    final loaded = repo.loadAppSettings();
    expect(loaded.updatedAt, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T.*Z$')));
  });
}
