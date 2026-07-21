import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountDataDeletionService {
  AccountDataDeletionService({
    FirebaseAuth? auth,
    CloudHistoryService? historyService,
    CloudSettingsService? settingsService,
    Future<void> Function()? signOutProvider,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _historyService = historyService ?? CloudHistoryService(),
       _settingsService = settingsService ?? CloudSettingsService(),
       _signOutProvider = signOutProvider ?? _signOutGoogle;

  final FirebaseAuth _auth;
  final CloudHistoryService _historyService;
  final CloudSettingsService _settingsService;
  final Future<void> Function() _signOutProvider;

  Future<void> deleteCurrentAccount(PrefsRepository repo) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw StateError('Authenticated account required');
    }

    await Future.wait([
      _historyService.deleteAllSessions(),
      _settingsService.deleteRemoteSettings(),
    ]);
    await repo.clearAllData();

    await user.delete();
    await _auth.signOut();
    try {
      await _signOutProvider();
    } catch (_) {
      // Firebase deletion and local clearing already completed.
    }
  }

  static Future<void> _signOutGoogle() => GoogleSignIn.instance.signOut();
}
