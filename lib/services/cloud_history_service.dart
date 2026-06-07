import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/game_session.dart';

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
    }, SetOptions(merge: true));
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

  CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('sessions');
  }
}
