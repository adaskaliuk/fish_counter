import 'package:fish_counter/models/app_settings.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  test('AppSettings serializes profile and settings', () {
    const settings = AppSettings(
      syncHistoryEnabled: true,
      resetDelay: 10,
      vibeInterval: 45,
      matchSeconds: 3600,
      shakeUndoEnabled: false,
      shakeSensitivity: 'high',
      role: 'coach',
      athleteProfile: AthleteProfile(athleteName: 'Athlete'),
      updatedAt: '2026-06-14T10:00:00.000',
    );

    final parsed = AppSettings.fromJson(settings.toJson());

    expect(parsed.syncHistoryEnabled, true);
    expect(parsed.vibeInterval, 45);
    expect(parsed.shakeUndoEnabled, false);
    expect(parsed.role, 'coach');
    expect(parsed.athleteProfile.athleteName, 'Athlete');
  });

  test('AppSettings missing role stays empty for role setup migration', () {
    final parsed = AppSettings.fromJson(const {
      'athleteProfile': {'athleteName': 'Legacy'},
    });

    expect(parsed.role, '');
    expect(parsed.athleteProfile.athleteName, 'Legacy');
  });

  test('PrefsRepository applies nested role when top-level role is missing', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);
    final repo = await PrefsRepository.create();

    await repo.applyAppSettings(
      const AppSettings(
        syncHistoryEnabled: false,
        resetDelay: 0,
        vibeInterval: 0,
        matchSeconds: 0,
        shakeUndoEnabled: true,
        shakeSensitivity: 'medium',
        role: '',
        athleteProfile: AthleteProfile(role: 'coach', athleteName: 'Legacy'),
        updatedAt: '',
      ),
    );

    final profile = repo.loadAthleteProfile();
    expect(profile.role, 'coach');
    expect(profile.athleteName, 'Legacy');
  });

  test('PrefsRepository applies and loads app settings', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);
    final repo = await PrefsRepository.create();

    await repo.applyAppSettings(
      const AppSettings(
        syncHistoryEnabled: true,
        resetDelay: 9,
        vibeInterval: 30,
        matchSeconds: 1200,
        shakeUndoEnabled: false,
        shakeSensitivity: 'low',
        role: 'coach',
        athleteProfile: AthleteProfile(defaultVenue: 'River'),
        updatedAt: '2026-06-14T10:00:00.000Z',
      ),
    );

    final loaded = repo.loadAppSettings();

    expect(loaded.syncHistoryEnabled, true);
    expect(loaded.resetDelay, 9);
    expect(loaded.matchSeconds, 1200);
    expect(loaded.role, 'coach');
    expect(loaded.athleteProfile.defaultVenue, 'River');
    expect(loaded.updatedAt, '2026-06-14T10:00:00.000Z');
  });

  test('PrefsRepository touchSettingsUpdatedAt bumps updatedAt', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);
    final repo = await PrefsRepository.create();

    await repo.touchSettingsUpdatedAt();

    final loaded = repo.loadAppSettings();
    expect(loaded.updatedAt, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T.*Z$')));
  });
}
