import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  test('successful settings sync clears a previous sync failure', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);

    final repo = await PrefsRepository.create();
    await repo.saveSyncStatus(
      status: 'failed',
      error: '[cloud_firestore/permission-denied] denied',
    );

    final service = CloudSettingsService(
      firestore: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')),
    );

    await service.syncLocalAndRemote(repo);

    expect(repo.getSyncLastStatus(), 'synced');
    expect(repo.getSyncLastError(), isEmpty);
    expect(repo.isSyncPending(), isFalse);
  });

  test(
    'applying newer remote settings clears a previous sync failure',
    () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);

      final repo = await PrefsRepository.create();
      await repo.saveSyncStatus(
        status: 'failed',
        error: '[cloud_firestore/permission-denied] denied',
      );

      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection('users')
          .doc('u1')
          .collection('settings')
          .doc('app')
          .set({
            'updatedAt': '2999-01-01T00:00:00Z',
            'syncHistoryEnabled': false,
          });
      final service = CloudSettingsService(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u1')),
      );

      await service.syncLocalAndRemote(repo);

      expect(repo.getSyncLastStatus(), 'synced');
      expect(repo.getSyncLastError(), isEmpty);
      expect(repo.isSyncPending(), isFalse);
    },
  );
}
