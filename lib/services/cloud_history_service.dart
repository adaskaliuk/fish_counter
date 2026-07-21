import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/services/cloud_sync_error.dart';
import 'package:fish_counter/services/prefs_repository.dart';

class CloudHistorySyncResult {
  const CloudHistorySyncResult({
    required this.localCount,
    required this.remoteCount,
    required this.mergedCount,
    required this.uploadedCount,
    required this.skipped,
  });

  final int localCount;
  final int remoteCount;
  final int mergedCount;
  final int uploadedCount;
  final bool skipped;
}

class CloudHistoryService {
  CloudHistoryService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  User? get _user => _auth.currentUser;

  bool get canSync => _user != null && !_user!.isAnonymous;

  Future<void> uploadSession(GameSession session) async {
    final user = _user;
    if (user == null || user.isAnonymous) return;

    await _sessionsRef(user.uid).doc(session.id).set({
      ...session.toJson(),
      'syncedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String sessionId) async {
    final user = _user;
    if (user == null || user.isAnonymous) return;

    await _sessionsRef(user.uid).doc(sessionId).delete();
  }

  Future<void> deleteAllSessions() async {
    final user = _user;
    if (user == null || user.isAnonymous) {
      throw StateError('Authenticated account required');
    }

    final sessions = _sessionsRef(user.uid);
    while (true) {
      final snapshot = await sessions.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  Future<List<GameSession>> loadSessions() async {
    final user = _user;
    if (user == null || user.isAnonymous) return [];

    final snapshot = await _sessionsRef(
      user.uid,
    ).orderBy('id', descending: false).get();

    return snapshot.docs
        .map((doc) => GameSession.fromJson(doc.data()))
        .toList();
  }

  Future<CloudHistorySyncResult> syncLocalAndRemote(
    PrefsRepository repo,
  ) async {
    try {
      if (!canSync) {
        await repo.saveSyncStatus(status: 'localOnly');
        return const CloudHistorySyncResult(
          localCount: 0,
          remoteCount: 0,
          mergedCount: 0,
          uploadedCount: 0,
          skipped: true,
        );
      }

      final state = await repo.loadInitialState();
      if (!state.syncHistoryEnabled) {
        await repo.saveSyncStatus(status: 'off');
        return CloudHistorySyncResult(
          localCount: state.historySessions.length,
          remoteCount: 0,
          mergedCount: state.historySessions.length,
          uploadedCount: 0,
          skipped: true,
        );
      }

      final remoteSessions = await loadSessions();
      final merged = PrefsRepository.mergeSessionLists(
        state.historySessions,
        remoteSessions,
      );
      await repo.saveSessionHistory(merged);

      var uploaded = 0;
      for (final session in merged) {
        await uploadSession(session);
        uploaded += 1;
      }

      await repo.saveSyncStatus(status: 'synced');
      await repo.setSyncPending(false);

      return CloudHistorySyncResult(
        localCount: state.historySessions.length,
        remoteCount: remoteSessions.length,
        mergedCount: merged.length,
        uploadedCount: uploaded,
        skipped: false,
      );
    } catch (e) {
      await repo.saveSyncStatus(status: 'failed', error: cloudSyncErrorCode(e));
      await repo.setSyncPending(isRetryableCloudSyncError(e));
      rethrow;
    }
  }

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('sessions');
  }
}
