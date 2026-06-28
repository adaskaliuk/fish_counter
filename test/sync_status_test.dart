import 'package:fish_counter/models/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync status parses stored values', () {
    expect(SyncStatusX.fromStorage('off'), SyncStatus.off);
    expect(SyncStatusX.fromStorage('synced'), SyncStatus.synced);
    expect(SyncStatusX.fromStorage('failed'), SyncStatus.failed);
    expect(SyncStatusX.fromStorage('syncing'), SyncStatus.syncing);
    expect(SyncStatusX.fromStorage('anything'), SyncStatus.localOnly);
  });

  test('sync status maps icons and colors', () {
    expect(SyncStatus.synced.icon, Icons.cloud_done);
    expect(SyncStatus.failed.color, Colors.orange);
  });
}
