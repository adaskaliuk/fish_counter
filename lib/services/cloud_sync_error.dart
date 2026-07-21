import 'package:firebase_core/firebase_core.dart';

bool isRetryableCloudSyncError(Object error) {
  if (error is FirebaseException && error.code == 'permission-denied') {
    return false;
  }

  return !error.toString().contains('permission-denied');
}

String cloudSyncErrorCode(Object error) {
  if (error is FirebaseException) {
    return '${error.plugin}/${error.code}';
  }

  return error.runtimeType.toString();
}
