import 'dart:convert';

import 'package:fish_counter/constants.dart';
import 'package:fish_counter/game_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepository {
  final SharedPreferences _prefs;

  HistoryRepository(this._prefs);

  static Future<HistoryRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryRepository(prefs);
  }

  Future<void> addHistorySession(GameSession session) async {
    final current = await loadHistorySessions();
    final merged = mergeSessionLists(current, [session]);
    await saveSessionHistory(merged);
  }

  Future<void> deleteHistorySession(String sessionId) async {
    final current = await loadHistorySessions();
    final remaining = current
        .where((session) => session.id != sessionId)
        .toList();
    await saveSessionHistory(remaining);
  }

  Future<void> updateHistorySession(GameSession updatedSession) async {
    final current = await loadHistorySessions();
    final updated = current
        .map(
          (session) =>
              session.id == updatedSession.id ? updatedSession : session,
        )
        .toList();
    await saveSessionHistory(updated);
  }

  Future<List<GameSession>> loadHistorySessions() async {
    final historyJsonList = _prefs.getStringList(PrefsKeys.historySessions);
    if (historyJsonList == null) return [];

    final sessions = <GameSession>[];
    for (final jsonStr in historyJsonList) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        sessions.add(GameSession.fromJson(json));
      } catch (_) {
        // Skip invalid entries
      }
    }
    return sessions;
  }

  Future<void> saveSessionHistory(List<GameSession> sessions) async {
    final deduped = mergeSessionLists(sessions, const []);
    final jsonList = deduped
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await _prefs.setStringList(PrefsKeys.historySessions, jsonList);
  }

  Future<List<GameSession>> mergeHistorySessions(
    List<GameSession> sessions,
  ) async {
    final current = await loadHistorySessions();
    final merged = mergeSessionLists(current, sessions);
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
    merged.sort((a, b) => _sessionTimestamp(a).compareTo(_sessionTimestamp(b)));
    return merged;
  }

  static bool _isNewer(GameSession candidate, GameSession existing) {
    return _sessionTimestamp(
          candidate,
        ).compareTo(_sessionTimestamp(existing)) >=
        0;
  }

  static DateTime _sessionTimestamp(GameSession session) {
    return DateTime.tryParse(session.updatedAt) ??
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(session.id) ?? 0);
  }
}
