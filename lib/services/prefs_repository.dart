import 'dart:convert';

import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:fish_counter/models/app_settings.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:fish_counter/services/local_storage.dart';
import 'package:fish_counter/utils/type_utils.dart';

/// Handles persistence for sessions and optional typed activity logs.
class PrefsRepository {
  final LocalStorage _prefs;
  static LocalStorage? _testStorage;

  PrefsRepository(this._prefs);

  static void useTestStorage(LocalStorage? storage) {
    _testStorage = storage;
  }

  static Future<PrefsRepository> create() async {
    final testStorage = _testStorage;
    if (testStorage != null) {
      return PrefsRepository(testStorage);
    }
    final prefs = await HiveLocalStorage.create();
    return PrefsRepository(prefs);
  }

  static Future<StateContainer> loadState() async {
    final repo = await PrefsRepository.create();
    return repo.loadInitialState();
  }

  Future<void> saveCounterState({
    required int c1,
    required int c2,
    required int tries,
    required int total,
    required bool powerOn,
    required bool paused,
  }) async {
    await _prefs.setInt(PrefsKeys.counter1, c1);
    await _prefs.setInt(PrefsKeys.counter2, c2);
    await _prefs.setInt(PrefsKeys.tries, tries);
    await _prefs.setInt(PrefsKeys.total, total);
    await _prefs.setBool(PrefsKeys.isPowerOn, powerOn);
    await _prefs.setBool(PrefsKeys.isPaused, paused);
  }

  Future<bool> isSyncHistoryEnabled() async {
    return _prefs.getBool(PrefsKeys.syncHistoryEnabled) ??
        Defaults.defaultSyncHistoryEnabled;
  }

  Future<void> setSyncHistoryEnabled(bool enabled) async {
    await _prefs.setBool(PrefsKeys.syncHistoryEnabled, enabled);
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

  bool isSyncPending() => _prefs.getBool(PrefsKeys.syncPending) ?? false;

  Future<void> setSyncPending(bool pending) async {
    await _prefs.setBool(PrefsKeys.syncPending, pending);
  }

  String getSyncLastStatus() =>
      _prefs.getString(PrefsKeys.syncLastStatus) ?? 'localOnly';

  String getSyncLastAt() => _prefs.getString(PrefsKeys.syncLastAt) ?? '';

  String getSyncLastError() => _prefs.getString(PrefsKeys.syncLastError) ?? '';

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

  Future<void> saveClickerState({
    required int c1,
    required int c2,
    required int tries,
    required int total,
    required bool powerOn,
    required bool paused,
    required bool sessionActive,
    required bool dataHidden,
    required int resetDelay,
    required int vibeInterval,
    required int matchSeconds,
    required bool syncHistoryEnabled,
    required bool shakeUndoEnabled,
    required String shakeSensitivity,
    required List<Map<String, dynamic>> activityGrid,
    required List<Map<String, dynamic>> weatherSnapshots,
  }) async {
    await _prefs.setInt(PrefsKeys.counter1, c1);
    await _prefs.setInt(PrefsKeys.counter2, c2);
    await _prefs.setInt(PrefsKeys.tries, tries);
    await _prefs.setInt(PrefsKeys.total, total);
    await _prefs.setBool(PrefsKeys.isPowerOn, powerOn);
    await _prefs.setBool(PrefsKeys.isPaused, paused);
    await _prefs.setBool(PrefsKeys.isSessionActive, sessionActive);
    await _prefs.setBool(PrefsKeys.isDataHidden, dataHidden);
    await _prefs.setInt(PrefsKeys.resetDelay, resetDelay);
    await _prefs.setInt(PrefsKeys.vibeInterval, vibeInterval);
    await _prefs.setInt(PrefsKeys.matchSeconds, matchSeconds);
    await _prefs.setBool(PrefsKeys.syncHistoryEnabled, syncHistoryEnabled);
    await _prefs.setBool(PrefsKeys.shakeUndoEnabled, shakeUndoEnabled);
    await _prefs.setString(PrefsKeys.shakeSensitivity, shakeSensitivity);
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(activityGrid));
    await _prefs.setString(PrefsKeys.weatherSnapshots, jsonEncode(weatherSnapshots));
  }

  Future<void> addHistorySession(GameSession session) async {
    final current = await loadInitialState();
    final merged = mergeSessionLists(current.historySessions, [session]);
    await saveSessionHistory(merged);
  }

  Future<void> deleteHistorySession(String sessionId) async {
    final current = await loadInitialState();
    final remaining = current.historySessions
        .where((session) => session.id != sessionId)
        .toList();
    await saveSessionHistory(remaining);
  }

  Future<void> updateHistorySession(GameSession updatedSession) async {
    final current = await loadInitialState();
    final updated = current.historySessions
        .map(
          (session) =>
              session.id == updatedSession.id ? updatedSession : session,
        )
        .toList();
    await saveSessionHistory(updated);
  }

  Future<void> saveActivity(List<ActivityLog> activityLogs) async {
    final rawData = activityLogs.map((log) => log.toJson()).toList();
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(rawData));
  }

  Future<List<GameSession>> mergeHistorySessions(
    List<GameSession> sessions,
  ) async {
    final current = await loadInitialState();
    final merged = mergeSessionLists(current.historySessions, sessions);
    await saveSessionHistory(merged);
    return merged;
  }

  static List<GameSession> mergeSessionLists(
    List<GameSession> local,
    List<GameSession> remote,
  ) {
    final byId = <String, GameSession>{};
    for (final session in [...local, ...remote]) {
      final existing = byId[session.id];
      if (existing == null || _isNewer(session, existing)) {
        byId[session.id] = session;
      }
    }

    final merged = byId.values.toList();
    merged.sort((a, b) {
      final timestampCompare = _sessionSortTimestamp(a).compareTo(
        _sessionSortTimestamp(b),
      );
      if (timestampCompare != 0) return timestampCompare;
      return a.id.compareTo(b.id);
    });
    return merged;
  }

  static bool _isNewer(GameSession candidate, GameSession existing) {
    return _sessionFreshness(candidate).compareTo(_sessionFreshness(existing)) >= 0;
  }

  static DateTime _sessionFreshness(GameSession session) {
    return DateTime.tryParse(session.updatedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime _sessionSortTimestamp(GameSession session) {
    final createdAt = int.tryParse(session.id);
    if (createdAt != null) {
      return DateTime.fromMillisecondsSinceEpoch(createdAt);
    }

    return DateTime.tryParse(session.updatedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> saveSessionHistory(List<GameSession> sessions) async {
    final deduped = mergeSessionLists(sessions, const []);
    final jsonList = deduped
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await _prefs.setStringList(PrefsKeys.historySessions, jsonList);
  }

  Future<StateContainer> loadInitialState() async {
    final gridJson = _prefs.getString(PrefsKeys.activityGrid);
    final activityLogs = <ActivityLog>[];
    final rawActivityGrid = <Map<String, dynamic>>[];
    final weatherSnapshots = <WeatherSnapshot>[];
    final weatherJson = _prefs.getString(PrefsKeys.weatherSnapshots);

    if (gridJson != null) {
      try {
        final rawData = jsonDecode(gridJson);
        if (rawData is List) {
          for (final raw in rawData) {
            if (raw is Map) {
              final entry = Map<String, dynamic>.from(raw);
              rawActivityGrid.add(entry);
              activityLogs.add(ActivityLog.fromJson(entry));
            }
          }
        }
      } catch (_) {
        activityLogs.clear();
        rawActivityGrid.clear();
      }
    }

    if (weatherJson != null) {
      try {
        final rawData = jsonDecode(weatherJson);
        if (rawData is List) {
          for (final raw in rawData) {
            if (raw is Map) {
              weatherSnapshots.add(
                WeatherSnapshot.fromJson(Map<String, dynamic>.from(raw)),
              );
            }
          }
        }
      } catch (_) {
        weatherSnapshots.clear();
      }
    }

    final historyJsonList =
        _prefs.getStringList(PrefsKeys.historySessions) ?? [];
    final sessions = <GameSession>[];

    for (final item in historyJsonList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          sessions.add(
            GameSession.fromJson(Map<String, dynamic>.from(decoded)),
          );
        }
      } catch (_) {
        // Ignore invalid history entries.
      }
    }

    final enrichedSessions = mergeSessionLists(sessions, const []);

    return StateContainer(
      c1: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.counter1)),
      c2: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.counter2)),
      tries: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.tries)),
      total: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.total)),
      powerOn: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.isPowerOn), defaultValue: true),
      paused: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.isPaused), defaultValue: true),
      sessionActive: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.isSessionActive)),
      dataHidden: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.isDataHidden), defaultValue: true),
      resetDelay: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.resetDelay), defaultValue: Defaults.defaultResetDelaySeconds),
      vibeInterval: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.vibeInterval), defaultValue: Defaults.defaultVibeIntervalSeconds),
      matchSeconds: TypeUtils.safeInt(_prefs.getInt(PrefsKeys.matchSeconds), defaultValue: Defaults.defaultMatchDurationSeconds),
      activityGrid: activityLogs,
      rawActivityGrid: rawActivityGrid,
      weatherSnapshots: weatherSnapshots,
      historySessions: enrichedSessions,
      syncHistoryEnabled: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.syncHistoryEnabled), defaultValue: Defaults.defaultSyncHistoryEnabled),
      shakeUndoEnabled: TypeUtils.safeBool(_prefs.getBool(PrefsKeys.shakeUndoEnabled), defaultValue: Defaults.defaultShakeUndoEnabled),
      shakeSensitivity: TypeUtils.safeString(_prefs.getString(PrefsKeys.shakeSensitivity), defaultValue: Defaults.defaultShakeSensitivity),
    );
  }

}

/// Container class for loaded app state.
class StateContainer {
  final int c1;
  final int c2;
  final int tries;
  final int total;
  final bool powerOn;
  final bool paused;
  final bool sessionActive;
  final bool dataHidden;
  final int resetDelay;
  final int vibeInterval;
  final int matchSeconds;
  final List<ActivityLog> activityGrid;
  final List<Map<String, dynamic>> rawActivityGrid;
  final List<WeatherSnapshot> weatherSnapshots;
  final List<GameSession> historySessions;
  final bool syncHistoryEnabled;
  final bool shakeUndoEnabled;
  final String shakeSensitivity;

  StateContainer({
    required this.c1,
    required this.c2,
    required this.tries,
    required this.total,
    required this.powerOn,
    required this.paused,
    required this.sessionActive,
    required this.dataHidden,
    required this.resetDelay,
    required this.vibeInterval,
    required this.matchSeconds,
    required this.activityGrid,
    required this.rawActivityGrid,
    required this.weatherSnapshots,
    required this.historySessions,
    required this.syncHistoryEnabled,
    required this.shakeUndoEnabled,
    required this.shakeSensitivity,
  });
}
