import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/models/app_settings.dart';
import 'package:fish_counter/services/prefs_repository.dart';

class CloudSettingsService {
  CloudSettingsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  User? get _user => _auth.currentUser;

  Future<void> uploadLocalSettings(PrefsRepository repo) async {
    final user = _user;
    if (user == null || user.isAnonymous) return;

    try {
      final settings = repo.loadAppSettings();
      await _settingsRef(user.uid).set({
        ...settings.toJson(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await repo.setSyncPending(false);
    } catch (e) {
      await repo.saveSyncStatus(status: 'failed', error: e.toString());
      await repo.setSyncPending(true);
      rethrow;
    }
  }

  Future<void> syncLocalAndRemote(PrefsRepository repo) async {
    try {
      final user = _user;
      if (user == null || user.isAnonymous) return;

      final local = repo.loadAppSettings();
      final snapshot = await _settingsRef(user.uid).get();
      if (!snapshot.exists) {
        await uploadLocalSettings(repo);
        return;
      }

      final remote = AppSettings.fromJson(snapshot.data() ?? {});
      if (_isRemoteNewer(local, remote)) {
        await repo.applyAppSettings(remote);
      } else {
        await uploadLocalSettings(repo);
      }
      await repo.setSyncPending(false);
    } catch (e) {
      await repo.saveSyncStatus(status: 'failed', error: e.toString());
      await repo.setSyncPending(true);
      rethrow;
    }
  }

  bool _isRemoteNewer(AppSettings local, AppSettings remote) {
    final localTime = DateTime.tryParse(local.updatedAt) ?? DateTime(1970);
    final remoteTime = DateTime.tryParse(remote.updatedAt) ?? DateTime(1970);
    return remoteTime.isAfter(localTime);
  }

  DocumentReference<Map<String, dynamic>> _settingsRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('app');
  }
}
