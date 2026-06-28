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
}
