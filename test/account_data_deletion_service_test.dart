import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fish_counter/services/account_data_deletion_service.dart';
import 'package:fish_counter/services/cloud_history_service.dart';
import 'package:fish_counter/services/cloud_settings_service.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  test(
    'deletes owned cloud data, local data, and authenticated account',
    () async {
      final storage = await useSeededMemoryStorage({
        'history_sessions': ['private-session'],
        'athlete_profile': '{"athleteName":"Private athlete"}',
      });
      addTearDown(resetMemoryStorage);

      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1', email: 'athlete@example.com'),
      );
      await firestore
          .collection('users')
          .doc('u1')
          .collection('sessions')
          .doc('s1')
          .set({'name': 'Private session'});
      await firestore
          .collection('users')
          .doc('u1')
          .collection('settings')
          .doc('app')
          .set({'athleteName': 'Private athlete'});

      final service = AccountDataDeletionService(
        auth: auth,
        historyService: CloudHistoryService(firestore: firestore, auth: auth),
        settingsService: CloudSettingsService(firestore: firestore, auth: auth),
        signOutProvider: () async {},
      );

      await service.deleteCurrentAccount(await PrefsRepository.create());

      expect(
        (await firestore
                .collection('users')
                .doc('u1')
                .collection('sessions')
                .get())
            .docs,
        isEmpty,
      );
      expect(
        (await firestore
                .collection('users')
                .doc('u1')
                .collection('settings')
                .get())
            .docs,
        isEmpty,
      );
      expect(storage.values, isEmpty);
      expect(auth.currentUser, isNull);
    },
  );

  test('requires an authenticated non-anonymous account', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);

    final auth = MockFirebaseAuth(signedIn: false);
    final service = AccountDataDeletionService(
      auth: auth,
      historyService: CloudHistoryService(
        firestore: FakeFirebaseFirestore(),
        auth: auth,
      ),
      settingsService: CloudSettingsService(
        firestore: FakeFirebaseFirestore(),
        auth: auth,
      ),
      signOutProvider: () async {},
    );

    await expectLater(
      service.deleteCurrentAccount(await PrefsRepository.create()),
      throwsStateError,
    );
  });

  test('rejects deletion for anonymous accounts', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);

    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'guest', isAnonymous: true),
    );
    final service = AccountDataDeletionService(
      auth: auth,
      historyService: CloudHistoryService(
        firestore: FakeFirebaseFirestore(),
        auth: auth,
      ),
      settingsService: CloudSettingsService(
        firestore: FakeFirebaseFirestore(),
        auth: auth,
      ),
      signOutProvider: () async {},
    );

    await expectLater(
      service.deleteCurrentAccount(await PrefsRepository.create()),
      throwsStateError,
    );
  });
}
