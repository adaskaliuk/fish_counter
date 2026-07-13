import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSession', () {
    test('serializes and parses metadata and notes', () {
      final session = GameSession(
        id: '1',
        name: 'Training',
        date: '06.06.26 10:00',
        c1: 1,
        c2: 2,
        tries: 3,
        total: 3,
        goalFishCount: 10,
        goalTargetPaceSeconds: 60,
        goalMaxTries: 2,
        goalStabilityPercent: 80,
        matchDuration: '5:00',
        grid: const [],
        userId: 'uid-1',
        userEmail: 'athlete@example.com',
        userDisplayName: 'Athlete',
        athleteName: 'Andrew',
        coachName: 'Coach',
        venue: 'River',
        sectorPeg: 'A12',
        trainingType: 'Pace drill',
        fishingMethod: 'Feeder',
        targetPace: '60s',
        conditions: 'Windy',
        baitNotes: 'Worms',
        weatherPlace: 'Kyiv',
        weatherDescription: 'clear sky',
        weatherFetchedAt: '2026-06-06T10:00:00Z',
        latitude: 50.45,
        longitude: 30.52,
        weatherTemperatureCelsius: 21.5,
        weatherWindSpeedMs: 3.2,
        weatherSnapshots: [
          WeatherSnapshot(
            latitude: 50.45,
            longitude: 30.52,
            placeName: 'Kyiv',
            description: 'clear sky',
            temperatureCelsius: 21.5,
            feelsLikeCelsius: 20.8,
            pressureHpa: 1012,
            humidityPercent: 55,
            windSpeedMs: 3.2,
            windDirectionDegrees: 180,
            fetchedAt: '2026-06-06T10:00:00Z',
          ),
        ],
        updatedAt: '2026-06-06T10:01:00Z',
        athleteNote: 'Athlete note',
        coachComment: 'Coach comment',
        finalWeightKg: 12.35,
        finalCount: 42,
      );

      final parsed = GameSession.fromJson(session.toJson());

      expect(parsed.userId, 'uid-1');
      expect(parsed.userEmail, 'athlete@example.com');
      expect(parsed.userDisplayName, 'Athlete');
      expect(parsed.goalFishCount, 10);
      expect(parsed.goalTargetPaceSeconds, 60);
      expect(parsed.goalMaxTries, 2);
      expect(parsed.goalStabilityPercent, 80);
      expect(parsed.athleteName, 'Andrew');
      expect(parsed.coachName, 'Coach');
      expect(parsed.venue, 'River');
      expect(parsed.sectorPeg, 'A12');
      expect(parsed.trainingType, 'Pace drill');
      expect(parsed.fishingMethod, 'Feeder');
      expect(parsed.targetPace, '60s');
      expect(parsed.conditions, 'Windy');
      expect(parsed.baitNotes, 'Worms');
      expect(parsed.weatherPlace, 'Kyiv');
      expect(parsed.weatherDescription, 'clear sky');
      expect(parsed.weatherFetchedAt, '2026-06-06T10:00:00Z');
      expect(parsed.latitude, 50.45);
      expect(parsed.longitude, 30.52);
      expect(parsed.weatherTemperatureCelsius, 21.5);
      expect(parsed.weatherWindSpeedMs, 3.2);
      expect(parsed.weatherSnapshots, hasLength(1));
      expect(parsed.weatherSnapshots.first.temperatureCelsius, 21.5);
      expect(parsed.updatedAt, '2026-06-06T10:01:00Z');
      expect(parsed.athleteNote, 'Athlete note');
      expect(parsed.coachComment, 'Coach comment');
      expect(parsed.finalWeightKg, 12.35);
      expect(parsed.finalCount, 42);
    });

    test('keeps metadata and notes optional for old saved sessions', () {
      final parsed = GameSession.fromJson({
        'id': '1',
        'name': 'Old session',
        'date': '06.06.26 10:00',
        'c1': 1,
        'c2': 2,
        'tries': 3,
        'total': 3,
        'matchDuration': '5:00',
        'grid': [],
      });

      expect(parsed.userId, isEmpty);
      expect(parsed.userEmail, isEmpty);
      expect(parsed.userDisplayName, isEmpty);
      expect(parsed.athleteName, isEmpty);
      expect(parsed.coachName, isEmpty);
      expect(parsed.venue, isEmpty);
      expect(parsed.sectorPeg, isEmpty);
      expect(parsed.trainingType, isEmpty);
      expect(parsed.fishingMethod, isEmpty);
      expect(parsed.targetPace, isEmpty);
      expect(parsed.conditions, isEmpty);
      expect(parsed.baitNotes, isEmpty);
      expect(parsed.weatherPlace, isEmpty);
      expect(parsed.weatherDescription, isEmpty);
      expect(parsed.latitude, isNull);
      expect(parsed.longitude, isNull);
      expect(parsed.weatherTemperatureCelsius, isNull);
      expect(parsed.athleteNote, isEmpty);
      expect(parsed.coachComment, isEmpty);
      expect(parsed.finalWeightKg, isNull);
      expect(parsed.finalCount, isNull);
    });


    test('round-trips weight only, count only, and both result values', () {
      GameSession base({double? weight, int? count}) => GameSession(
            id: '1',
            name: 'Session',
            date: '06.06.26 10:00',
            c1: 1,
            c2: 0,
            tries: 0,
            total: 1,
            matchDuration: '5:00',
            grid: const [],
            finalWeightKg: weight,
            finalCount: count,
            updatedAt: '2026-06-06T10:00:00Z',
          );

      final weightOnly = GameSession.fromJson(base(weight: 1.25).toJson());
      expect(weightOnly.finalWeightKg, 1.25);
      expect(weightOnly.finalCount, isNull);
      final countOnly = GameSession.fromJson(base(count: 7).toJson());
      expect(countOnly.finalWeightKg, isNull);
      expect(countOnly.finalCount, 7);
      final both = GameSession.fromJson(base(weight: 2.5, count: 9).toJson());
      expect(both.finalWeightKg, 2.5);
      expect(both.finalCount, 9);
    });

    test('copyWith updates editable metadata and preserves counters', () {
      final session = GameSession(
        id: '1',
        name: 'Old',
        date: '06.06.26 10:00',
        c1: 1,
        c2: 2,
        tries: 3,
        total: 3,
        matchDuration: '5:00',
        grid: const [],
        finalWeightKg: 1.5,
        finalCount: 4,
        updatedAt: '2026-06-06T10:00:00Z',
      );

      final updated = session.copyWith(
        name: 'New',
        venue: 'Lake',
        updatedAt: '2026-06-06T11:00:00Z',
      );

      expect(updated.name, 'New');
      expect(updated.venue, 'Lake');
      expect(updated.c1, 1);
      expect(updated.total, 3);
      expect(updated.updatedAt, '2026-06-06T11:00:00Z');
      expect(updated.finalWeightKg, 1.5);
      expect(updated.finalCount, 4);

      final cleared = updated.copyWith(clearFinalWeight: true, clearFinalCount: true);
      expect(cleared.finalWeightKg, isNull);
      expect(cleared.finalCount, isNull);
    });
  });
}
