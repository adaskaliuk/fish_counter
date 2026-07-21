import 'package:firebase_core/firebase_core.dart';
import 'package:fish_counter/services/cloud_sync_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('permission-denied sync error is not retryable', () {
    expect(
      isRetryableCloudSyncError(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      isFalse,
    );
  });

  test('other sync errors remain retryable', () {
    expect(
      isRetryableCloudSyncError(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      ),
      isTrue,
    );
  });

  test('sync status omits exception messages and personal data', () {
    final error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Denied for athlete@example.com at users/private-user',
    );

    expect(cloudSyncErrorCode(error), 'cloud_firestore/permission-denied');
    expect(cloudSyncErrorCode(error), isNot(contains('athlete@example.com')));
    expect(cloudSyncErrorCode(error), isNot(contains('private-user')));
  });
}
