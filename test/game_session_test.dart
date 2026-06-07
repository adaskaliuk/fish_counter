import 'package:fish_counter/game_session.dart';
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
        athleteNote: 'Athlete note',
        coachComment: 'Coach comment',
      );

      final parsed = GameSession.fromJson(session.toJson());

      expect(parsed.userId, 'uid-1');
      expect(parsed.userEmail, 'athlete@example.com');
      expect(parsed.userDisplayName, 'Athlete');
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
      expect(parsed.athleteNote, 'Athlete note');
      expect(parsed.coachComment, 'Coach comment');
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
    });
  });
}
