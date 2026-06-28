import 'package:flutter/material.dart';

enum SyncStatus { localOnly, off, synced, failed, syncing }

extension SyncStatusX on SyncStatus {
  static SyncStatus fromStorage(String value) => switch (value) {
    'off' => SyncStatus.off,
    'synced' => SyncStatus.synced,
    'failed' => SyncStatus.failed,
    'syncing' => SyncStatus.syncing,
    _ => SyncStatus.localOnly,
  };

  IconData get icon => switch (this) {
    SyncStatus.off => Icons.cloud_off,
    SyncStatus.synced => Icons.cloud_done,
    SyncStatus.failed => Icons.cloud_off,
    SyncStatus.syncing => Icons.sync,
    SyncStatus.localOnly => Icons.cloud_queue,
  };

  Color get color => switch (this) {
    SyncStatus.off => Colors.grey,
    SyncStatus.synced => Colors.green,
    SyncStatus.failed => Colors.orange,
    SyncStatus.syncing => Colors.blue,
    SyncStatus.localOnly => Colors.grey,
  };
}
