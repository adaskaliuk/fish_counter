import 'package:fish_counter/controllers/clicker_controller.dart';
import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClickerController', () {
    test('increments C1 and recalculates total', () {
      final counters = ClickerController.incrementCounters(
        counter1: 1,
        counter2: 2,
        tries: 3,
        type: 1,
      );

      expect(counters.counter1, 2);
      expect(counters.counter2, 2);
      expect(counters.tries, 3);
      expect(counters.total, 4);
    });

    test('increments C2 and recalculates total', () {
      final counters = ClickerController.incrementCounters(
        counter1: 1,
        counter2: 2,
        tries: 3,
        type: 2,
      );

      expect(counters.counter1, 1);
      expect(counters.counter2, 3);
      expect(counters.tries, 3);
      expect(counters.total, 4);
    });

    test('increments try without changing total', () {
      final counters = ClickerController.incrementCounters(
        counter1: 1,
        counter2: 2,
        tries: 3,
        type: 3,
      );

      expect(counters.counter1, 1);
      expect(counters.counter2, 2);
      expect(counters.tries, 4);
      expect(counters.total, 3);
    });

    test('allows increment only when app is active and ready', () {
      expect(
        ClickerController.canIncrement(
          isPowerOn: true,
          isActionDelay: false,
          isPaused: false,
          isSessionActive: true,
        ),
        isTrue,
      );
      expect(
        ClickerController.canIncrement(
          isPowerOn: true,
          isActionDelay: true,
          isPaused: false,
          isSessionActive: true,
        ),
        isFalse,
      );
    });

    test('calculates timing status', () {
      expect(ClickerController.calculateStatus(60, 60), 'green');
      expect(ClickerController.calculateStatus(30, 60), 'grey');
      expect(ClickerController.calculateStatus(120, 60), 'red');
      expect(ClickerController.calculateStatus(45, 60), 'orange');
    });

    test('builds activity entry', () {
      final entry = ClickerController.buildActivityEntry(
        type: 1,
        intervalSeconds: 60,
        targetInterval: 60,
        timestamp: '10:00:00',
      );

      expect(entry['type'], 1);
      expect(entry['status'], 'green');
      expect(entry['interval'], 60);
      expect(entry['target'], 60);
      expect(entry['timestamp'], '10:00:00');
    });

    test('toggles pause state and requests pause marker', () {
      final state = ClickerController.togglePause(
        isSessionActive: false,
        isPaused: false,
      );

      expect(state.isSessionActive, isTrue);
      expect(state.isPaused, isTrue);
      expect(state.isDataHidden, isTrue);
      expect(state.shouldResetDuration, isTrue);
      expect(state.shouldAddPauseMarker, isTrue);
    });

    test('builds pause entry', () {
      final entry = ClickerController.buildPauseEntry(timestamp: '10:00:00');

      expect(entry['type'], 0);
      expect(entry['status'], 'grey');
      expect(entry['interval'], 0);
      expect(entry['timestamp'], '10:00:00');
    });

    test('turns power on into paused hidden state', () {
      final state = ClickerController.turnPowerOn();

      expect(state.isPowerOn, isTrue);
      expect(state.isPaused, isTrue);
      expect(state.isDataHidden, isTrue);
      expect(state.isSessionActive, isFalse);
      expect(state.shouldResetCounters, isFalse);
    });

    test('turns power off without resetting counters', () {
      final state = ClickerController.turnPowerOffWithoutSaving();

      expect(state.isPowerOn, isFalse);
      expect(state.isPaused, isTrue);
      expect(state.isActionDelay, isFalse);
      expect(state.delayCountdown, 0);
      expect(state.duration, Duration.zero);
      expect(state.shouldResetCounters, isFalse);
      expect(state.shouldClearActivity, isFalse);
    });

    test('resets after saved session', () {
      final state = ClickerController.resetAfterSessionSaved();

      expect(state.isPowerOn, isFalse);
      expect(state.hasHistory, isTrue);
      expect(state.shouldResetCounters, isTrue);
      expect(state.shouldClearActivity, isTrue);
      expect(state.matchInterval, const Duration(seconds: 18000));
    });

    test('formats match duration with padded minutes', () {
      expect(
        ClickerController.formatMatchDuration(
          const Duration(hours: 5, minutes: 7),
        ),
        '5:07',
      );
      expect(
        ClickerController.formatMatchDuration(
          const Duration(hours: 4, minutes: 30),
        ),
        '4:30',
      );
    });

    test('builds game session from clicker state', () {
      final session = ClickerController.buildSession(
        id: '1',
        name: 'Training',
        date: '06.06.26 10:00',
        counter1: 2,
        counter2: 3,
        tries: 1,
        total: 5,
        matchInterval: const Duration(hours: 4, minutes: 30),
        userId: ' uid-1 ',
        userEmail: ' athlete@example.com ',
        userDisplayName: ' Athlete ',
        athleteName: ' Andrew ',
        coachName: ' Coach ',
        venue: ' Lake ',
        sectorPeg: ' B7 ',
        trainingType: ' Pace drill ',
        fishingMethod: ' Feeder ',
        targetPace: ' 60s ',
        conditions: ' Wind ',
        baitNotes: ' Worms ',
        weather: const WeatherSnapshot(
          latitude: 50.45,
          longitude: 30.52,
          placeName: 'Kyiv',
          description: 'clear sky',
          temperatureCelsius: 21.5,
          feelsLikeCelsius: 20.0,
          pressureHpa: 1012,
          humidityPercent: 55,
          windSpeedMs: 3.2,
          windDirectionDegrees: 180,
          fetchedAt: '2026-06-06T10:00:00Z',
        ),
        athleteNote: ' Good drill ',
        coachComment: 'Keep pace',
        activityGrid: [
          {'type': 1, 'status': 'green'},
        ],
      );

      expect(session.id, '1');
      expect(session.name, 'Training');
      expect(session.c1, 2);
      expect(session.c2, 3);
      expect(session.tries, 1);
      expect(session.total, 5);
      expect(session.matchDuration, '4:30');
      expect(session.userId, 'uid-1');
      expect(session.userEmail, 'athlete@example.com');
      expect(session.userDisplayName, 'Athlete');
      expect(session.athleteName, 'Andrew');
      expect(session.coachName, 'Coach');
      expect(session.venue, 'Lake');
      expect(session.sectorPeg, 'B7');
      expect(session.trainingType, 'Pace drill');
      expect(session.fishingMethod, 'Feeder');
      expect(session.targetPace, '60s');
      expect(session.conditions, 'Wind');
      expect(session.baitNotes, 'Worms');
      expect(session.weatherPlace, 'Kyiv');
      expect(session.weatherDescription, 'clear sky');
      expect(session.latitude, 50.45);
      expect(session.longitude, 30.52);
      expect(session.weatherTemperatureCelsius, 21.5);
      expect(session.athleteNote, 'Good drill');
      expect(session.coachComment, 'Keep pace');
      expect(session.grid.single['type'], 1);
    });
  });
}
