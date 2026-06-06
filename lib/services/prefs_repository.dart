import 'dart:convert';

import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistence for sessions and optional typed activity logs.
class PrefsRepository {
  final SharedPreferences _prefs;

  PrefsRepository(this._prefs);

  static Future<PrefsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
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
    required bool shakeUndoEnabled,
    required String shakeSensitivity,
    required List<Map<String, dynamic>> activityGrid,
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
    await _prefs.setBool(PrefsKeys.shakeUndoEnabled, shakeUndoEnabled);
    await _prefs.setString(PrefsKeys.shakeSensitivity, shakeSensitivity);
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(activityGrid));
  }

  Future<void> addHistorySession(GameSession session) async {
    final history = _prefs.getStringList(PrefsKeys.historySessions) ?? [];
    history.add(jsonEncode(session.toJson()));
    await _prefs.setStringList(PrefsKeys.historySessions, history);
  }

  Future<void> saveActivity(List<ActivityLog> activityLogs) async {
    final rawData = activityLogs.map((log) => log.toJson()).toList();
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(rawData));
  }

  Future<void> saveSessionHistory(List<GameSession> sessions) async {
    final jsonList = sessions
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await _prefs.setStringList(PrefsKeys.historySessions, jsonList);
  }

  Future<StateContainer> loadInitialState() async {
    final gridJson = _prefs.getString(PrefsKeys.activityGrid);
    final activityLogs = <ActivityLog>[];
    final rawActivityGrid = <Map<String, dynamic>>[];

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

    return StateContainer(
      c1: _prefs.getInt(PrefsKeys.counter1) ?? 0,
      c2: _prefs.getInt(PrefsKeys.counter2) ?? 0,
      tries: _prefs.getInt(PrefsKeys.tries) ?? 0,
      total: _prefs.getInt(PrefsKeys.total) ?? 0,
      powerOn: _prefs.getBool(PrefsKeys.isPowerOn) ?? true,
      paused: _prefs.getBool(PrefsKeys.isPaused) ?? true,
      sessionActive: _prefs.getBool(PrefsKeys.isSessionActive) ?? false,
      dataHidden: _prefs.getBool(PrefsKeys.isDataHidden) ?? true,
      resetDelay:
          _prefs.getInt(PrefsKeys.resetDelay) ??
          Defaults.defaultResetDelaySeconds,
      vibeInterval:
          _prefs.getInt(PrefsKeys.vibeInterval) ??
          Defaults.defaultVibeIntervalSeconds,
      matchSeconds:
          _prefs.getInt(PrefsKeys.matchSeconds) ??
          Defaults.defaultMatchDurationSeconds,
      activityGrid: activityLogs,
      rawActivityGrid: rawActivityGrid,
      historySessions: sessions,
      shakeUndoEnabled:
          _prefs.getBool(PrefsKeys.shakeUndoEnabled) ??
          Defaults.defaultShakeUndoEnabled,
      shakeSensitivity:
          _prefs.getString(PrefsKeys.shakeSensitivity) ??
          Defaults.defaultShakeSensitivity,
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
  final List<GameSession> historySessions;
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
    required this.historySessions,
    required this.shakeUndoEnabled,
    required this.shakeSensitivity,
  });
}
