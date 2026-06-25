import 'dart:convert';

import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/activity_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateContainer {
  final int counter1;
  final int counter2;
  final int tries;
  final int total;
  final bool powerOn;
  final bool paused;
  final bool sessionActive;
  final bool dataHidden;
  final int resetDelay;
  final int vibeInterval;
  final int matchSeconds;
  final bool syncHistoryEnabled;
  final bool shakeUndoEnabled;
  final String shakeSensitivity;
  final List<Map<String, dynamic>> activityGrid;
  final List<GameSession> historySessions;

  const StateContainer({
    this.counter1 = 0,
    this.counter2 = 0,
    this.tries = 0,
    this.total = 0,
    this.powerOn = true,
    this.paused = true,
    this.sessionActive = false,
    this.dataHidden = false,
    this.resetDelay = Defaults.defaultResetDelaySeconds,
    this.vibeInterval = Defaults.defaultVibeIntervalSeconds,
    this.matchSeconds = Defaults.defaultMatchDurationSeconds,
    this.syncHistoryEnabled = Defaults.defaultSyncHistoryEnabled,
    this.shakeUndoEnabled = Defaults.defaultShakeUndoEnabled,
    this.shakeSensitivity = Defaults.defaultShakeSensitivity,
    this.activityGrid = const [],
    this.historySessions = const [],
  });

  List<ActivityLog> get activityLogs {
    return activityGrid.map((e) => ActivityLog.fromJson(e)).toList();
  }

  List<Map<String, dynamic>> get rawActivityGrid => activityGrid;
}

class StateRepository {
  final SharedPreferences _prefs;

  StateRepository(this._prefs);

  static Future<StateRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StateRepository(prefs);
  }

  static Future<StateContainer> loadState() async {
    final repo = await StateRepository.create();
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
    required bool syncHistoryEnabled,
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
    await _prefs.setBool(PrefsKeys.syncHistoryEnabled, syncHistoryEnabled);
    await _prefs.setBool(PrefsKeys.shakeUndoEnabled, shakeUndoEnabled);
    await _prefs.setString(PrefsKeys.shakeSensitivity, shakeSensitivity);
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(activityGrid));
  }

  Future<void> saveActivity(List<ActivityLog> activityLogs) async {
    final rawData = activityLogs.map((log) => log.toJson()).toList();
    await _prefs.setString(PrefsKeys.activityGrid, jsonEncode(rawData));
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

    final historyJsonList = _prefs.getStringList(PrefsKeys.historySessions);
    final historySessions = <GameSession>[];
    if (historyJsonList != null) {
      for (final jsonStr in historyJsonList) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          historySessions.add(GameSession.fromJson(json));
        } catch (_) {
          // Skip invalid entries
        }
      }
    }

    return StateContainer(
      counter1: _prefs.getInt(PrefsKeys.counter1) ?? 0,
      counter2: _prefs.getInt(PrefsKeys.counter2) ?? 0,
      tries: _prefs.getInt(PrefsKeys.tries) ?? 0,
      total: _prefs.getInt(PrefsKeys.total) ?? 0,
      powerOn: _prefs.getBool(PrefsKeys.isPowerOn) ?? true,
      paused: _prefs.getBool(PrefsKeys.isPaused) ?? true,
      sessionActive: _prefs.getBool(PrefsKeys.isSessionActive) ?? false,
      dataHidden: _prefs.getBool(PrefsKeys.isDataHidden) ?? false,
      resetDelay: _prefs.getInt(PrefsKeys.resetDelay) ?? Defaults.defaultResetDelaySeconds,
      vibeInterval: _prefs.getInt(PrefsKeys.vibeInterval) ?? Defaults.defaultVibeIntervalSeconds,
      matchSeconds: _prefs.getInt(PrefsKeys.matchSeconds) ?? Defaults.defaultMatchDurationSeconds,
      syncHistoryEnabled: _prefs.getBool(PrefsKeys.syncHistoryEnabled) ?? Defaults.defaultSyncHistoryEnabled,
      shakeUndoEnabled: _prefs.getBool(PrefsKeys.shakeUndoEnabled) ?? Defaults.defaultShakeUndoEnabled,
      shakeSensitivity: _prefs.getString(PrefsKeys.shakeSensitivity) ?? Defaults.defaultShakeSensitivity,
      activityGrid: rawActivityGrid,
      historySessions: historySessions,
    );
  }
}
