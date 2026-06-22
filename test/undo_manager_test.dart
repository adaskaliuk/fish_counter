import 'package:fish_counter/undo_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('undoLastAction', () {
    test('does nothing when activity grid is empty', () {
      final result = undoLastAction(
        counter1: 1,
        counter2: 2,
        tries: 3,
        isActionDelay: true,
        delayCountdown: 5,
        activityGrid: [],
      );

      expect(result.didUndo, isFalse);
      expect(result.counter1, 1);
      expect(result.counter2, 2);
      expect(result.tries, 3);
    });

    test('undoes C1 click and resets action delay', () {
      final result = undoLastAction(
        counter1: 2,
        counter2: 1,
        tries: 0,
        isActionDelay: true,
        delayCountdown: 10,
        activityGrid: [_entry(1)],
      );

      expect(result.didUndo, isTrue);
      expect(result.counter1, 1);
      expect(result.counter2, 1);
      expect(result.tries, 0);
      expect(result.total, 2);
      expect(result.isActionDelay, isFalse);
      expect(result.delayCountdown, 0);
      expect(result.activityGrid, isEmpty);
    });

    test('undoes C2 click', () {
      final result = undoLastAction(
        counter1: 1,
        counter2: 2,
        tries: 0,
        isActionDelay: true,
        delayCountdown: 10,
        activityGrid: [_entry(2)],
      );

      expect(result.didUndo, isTrue);
      expect(result.counter1, 1);
      expect(result.counter2, 1);
      expect(result.total, 2);
    });

    test('undoes Try click without changing total', () {
      final result = undoLastAction(
        counter1: 1,
        counter2: 1,
        tries: 2,
        isActionDelay: true,
        delayCountdown: 10,
        activityGrid: [_entry(3)],
      );

      expect(result.didUndo, isTrue);
      expect(result.counter1, 1);
      expect(result.counter2, 1);
      expect(result.tries, 1);
      expect(result.total, 2);
    });

    test('undoes pause marker without changing counters', () {
      final result = undoLastAction(
        counter1: 1,
        counter2: 1,
        tries: 1,
        isActionDelay: false,
        delayCountdown: 0,
        activityGrid: [_entry(0)],
      );

      expect(result.didUndo, isTrue);
      expect(result.counter1, 1);
      expect(result.counter2, 1);
      expect(result.tries, 1);
      expect(result.total, 2);
      expect(result.activityGrid, isEmpty);
    });

    test('never makes counters negative', () {
      final result = undoLastAction(
        counter1: 0,
        counter2: 0,
        tries: 0,
        isActionDelay: true,
        delayCountdown: 10,
        activityGrid: [_entry(1), _entry(2), _entry(3)],
      );

      expect(result.counter1, 0);
      expect(result.counter2, 0);
      expect(result.tries, 0);
      expect(result.total, 0);
    });
  });
}

Map<String, dynamic> _entry(int type) => {
  'type': type,
  'status': 'green',
  'interval': 60,
  'target': 60,
  'timestamp': '12:00:00',
};
