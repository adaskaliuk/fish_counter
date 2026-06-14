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

  bool get canSync => _user != null && !_user!.isAnonymous;

  Future<void> uploadLocalSettings(PrefsRepository repo) async {
    if (!canSync) return;
    final settings = repo.loadAppSettings();
    await _settingsRef(_user!.uid).set({
      ...settings.toJson(),
      'syncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> syncLocalAndRemote(PrefsRepository repo) async {
    if (!canSync) return;

    final local = repo.loadAppSettings();
    final snapshot = await _settingsRef(_user!.uid).get();
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
