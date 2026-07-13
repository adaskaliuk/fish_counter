import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

GameSession _session({
  required String id,
  required String name,
  required String updatedAt,
}) {
  return GameSession(
    id: id,
    name: name,
    date: '06.06.26 10:00',
    c1: 1,
    c2: 0,
    tries: 0,
    total: 1,
    matchDuration: '0:05',
    grid: const [],
    updatedAt: updatedAt,
  );
}

void main() {
  group('PrefsRepository history merge', () {
    test('deduplicates by id and keeps newest session version', () {
      final local = _session(
        id: '1',
        name: 'Local old',
        updatedAt: '2026-06-07T10:00:00Z',
      );
      final remote = _session(
        id: '1',
        name: 'Remote new',
        updatedAt: '2026-06-07T11:00:00Z',
      );

      final merged = PrefsRepository.mergeSessionLists([local], [remote]);

      expect(merged, hasLength(1));
      expect(merged.single.name, 'Remote new');
    });

    test('sorts merged sessions by timestamp', () {
      final newer = _session(
        id: '2',
        name: 'Newer',
        updatedAt: '2026-06-07T11:00:00Z',
      );
      final older = _session(
        id: '1',
        name: 'Older',
        updatedAt: '2026-06-07T10:00:00Z',
      );

      final merged = PrefsRepository.mergeSessionLists([newer], [older]);

      expect(merged.map((session) => session.name), ['Older', 'Newer']);
    });

    test('deletes a local history session by id', () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);
      final repo = await PrefsRepository.create();
      await repo.saveSessionHistory([
        _session(id: '1', name: 'Keep', updatedAt: '2026-06-07T10:00:00Z'),
        _session(id: '2', name: 'Delete', updatedAt: '2026-06-07T11:00:00Z'),
      ]);

      await repo.deleteHistorySession('2');

      final state = await repo.loadInitialState();
      expect(state.historySessions.map((session) => session.name), ['Keep']);
    });

    test('updates a local history session by id', () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);
      final repo = await PrefsRepository.create();
      await repo.saveSessionHistory([
        _session(id: '1', name: 'Old', updatedAt: '2026-06-07T10:00:00Z'),
      ]);

      await repo.updateHistorySession(
        _session(id: '1', name: 'New', updatedAt: '2026-06-07T11:00:00Z'),
      );

      final state = await repo.loadInitialState();
      expect(state.historySessions.single.name, 'New');
    });
  });

  group('PrefsRepository user profile', () {
    test('stores athlete profile per Firebase user id with global fallback', () async {
      await useMemoryStorage();
      addTearDown(resetMemoryStorage);
      final repo = await PrefsRepository.create();

      await repo.saveAthleteProfile(
        const AthleteProfile(role: 'coach', athleteName: 'Coach User'),
        userId: 'u1',
      );
      await repo.saveAthleteProfile(
        const AthleteProfile(role: 'athlete', athleteName: 'Athlete User'),
        userId: 'u2',
      );

      expect(repo.loadAthleteProfile(userId: 'u1').role, 'coach');
      expect(repo.loadAthleteProfile(userId: 'u1').athleteName, 'Coach User');
      expect(repo.loadAthleteProfile(userId: 'u2').role, 'athlete');
      expect(repo.loadAthleteProfile(userId: 'u2').athleteName, 'Athlete User');
      expect(repo.loadAthleteProfile().role, 'athlete');
    });
  });

}
