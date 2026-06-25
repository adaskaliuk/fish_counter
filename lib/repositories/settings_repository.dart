import 'dart:convert';

import 'package:fish_counter/constants.dart';
import 'package:fish_counter/models/app_settings.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/utils/type_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  AppSettings loadAppSettings() {
    return AppSettings(
      syncHistoryEnabled:
          TypeUtils.safeBool(_prefs.getBool(PrefsKeys.syncHistoryEnabled), defaultValue: Defaults.defaultSyncHistoryEnabled),
      resetDelay:
          TypeUtils.safeInt(_prefs.getInt(PrefsKeys.resetDelay), defaultValue: Defaults.defaultResetDelaySeconds),
      vibeInterval:
          TypeUtils.safeInt(_prefs.getInt(PrefsKeys.vibeInterval), defaultValue: Defaults.defaultVibeIntervalSeconds),
      matchSeconds:
          TypeUtils.safeInt(_prefs.getInt(PrefsKeys.matchSeconds), defaultValue: Defaults.defaultMatchDurationSeconds),
      shakeUndoEnabled:
          TypeUtils.safeBool(_prefs.getBool(PrefsKeys.shakeUndoEnabled), defaultValue: Defaults.defaultShakeUndoEnabled),
      shakeSensitivity:
          TypeUtils.safeString(_prefs.getString(PrefsKeys.shakeSensitivity), defaultValue: Defaults.defaultShakeSensitivity),
      athleteProfile: loadAthleteProfile(),
      updatedAt: TypeUtils.safeString(_prefs.getString(PrefsKeys.settingsUpdatedAt)),
    );
  }

  Future<void> applyAppSettings(AppSettings settings) async {
    await _prefs.setBool(
      PrefsKeys.syncHistoryEnabled,
      settings.syncHistoryEnabled,
    );
    await _prefs.setInt(PrefsKeys.resetDelay, settings.resetDelay);
    await _prefs.setInt(PrefsKeys.vibeInterval, settings.vibeInterval);
    await _prefs.setInt(PrefsKeys.matchSeconds, settings.matchSeconds);
    await _prefs.setBool(PrefsKeys.shakeUndoEnabled, settings.shakeUndoEnabled);
    await _prefs.setString(
      PrefsKeys.shakeSensitivity,
      settings.shakeSensitivity,
    );
    await _prefs.setString(
      PrefsKeys.athleteProfile,
      jsonEncode(settings.athleteProfile.toJson()),
    );
    await _prefs.setString(
      PrefsKeys.settingsUpdatedAt,
      DateTime.tryParse(settings.updatedAt)?.toUtc().toIso8601String() ??
          settings.updatedAt,
    );
  }

  AthleteProfile loadAthleteProfile() {
    final raw = _prefs.getString(PrefsKeys.athleteProfile);
    if (raw == null) return const AthleteProfile();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return AthleteProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return const AthleteProfile();
  }

  Future<void> saveAthleteProfile(AthleteProfile profile) async {
    await _prefs.setString(
      PrefsKeys.athleteProfile,
      jsonEncode(profile.toJson()),
    );
    await touchSettingsUpdatedAt();
  }

  Future<void> touchSettingsUpdatedAt() async {
    await _prefs.setString(
      PrefsKeys.settingsUpdatedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> saveSyncStatus({
    required String status,
    String error = '',
  }) async {
    await _prefs.setString(PrefsKeys.syncLastStatus, status);
    await _prefs.setString(
      PrefsKeys.syncLastAt,
      DateTime.now().toIso8601String(),
    );
    await _prefs.setString(PrefsKeys.syncLastError, error);
  }

  String getSyncLastStatus() =>
      _prefs.getString(PrefsKeys.syncLastStatus) ?? 'localOnly';

  String getSyncLastAt() => _prefs.getString(PrefsKeys.syncLastAt) ?? '';

  String getSyncLastError() => _prefs.getString(PrefsKeys.syncLastError) ?? '';
}
