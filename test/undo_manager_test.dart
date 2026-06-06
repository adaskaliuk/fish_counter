import 'package:fish_counter/undo_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UndoManager', () {
    test('does nothing when activity grid is empty', () {
      const state = UndoState(
        counter1: 1,
        counter2: 2,
        tries: 3,
        total: 3,
        isActionDelay: true,
        delayCountdown: 5,
        activityGrid: [],
      );

      final result = UndoManager.undoLastAction(state);

      expect(result.didUndo, isFalse);
      expect(result.state, same(state));
    });

    test('undoes C1 click and resets action delay', () {
      final result = UndoManager.undoLastAction(
        UndoState(
          counter1: 2,
          counter2: 1,
          tries: 0,
          total: 3,
          isActionDelay: true,
          delayCountdown: 10,
          activityGrid: [_entry(1)],
        ),
      );

      expect(result.didUndo, isTrue);
      expect(result.state.counter1, 1);
      expect(result.state.counter2, 1);
      expect(result.state.tries, 0);
      expect(result.state.total, 2);
      expect(result.state.isActionDelay, isFalse);
      expect(result.state.delayCountdown, 0);
      expect(result.state.activityGrid, isEmpty);
    });

    test('undoes C2 click', () {
      final result = UndoManager.undoLastAction(
        UndoState(
          counter1: 1,
          counter2: 2,
          tries: 0,
          total: 3,
          isActionDelay: true,
          delayCountdown: 10,
          activityGrid: [_entry(2)],
        ),
      );

      expect(result.didUndo, isTrue);
      expect(result.state.counter1, 1);
      expect(result.state.counter2, 1);
      expect(result.state.total, 2);
    });

    test('undoes Try click without changing total', () {
      final result = UndoManager.undoLastAction(
        UndoState(
          counter1: 1,
          counter2: 1,
          tries: 2,
          total: 2,
          isActionDelay: true,
          delayCountdown: 10,
          activityGrid: [_entry(3)],
        ),
      );

      expect(result.didUndo, isTrue);
      expect(result.state.counter1, 1);
      expect(result.state.counter2, 1);
      expect(result.state.tries, 1);
      expect(result.state.total, 2);
    });

    test('undoes pause marker without changing counters', () {
      final result = UndoManager.undoLastAction(
        UndoState(
          counter1: 1,
          counter2: 1,
          tries: 1,
          total: 2,
          isActionDelay: false,
          delayCountdown: 0,
          activityGrid: [_entry(0)],
        ),
      );

      expect(result.didUndo, isTrue);
      expect(result.state.counter1, 1);
      expect(result.state.counter2, 1);
      expect(result.state.tries, 1);
      expect(result.state.total, 2);
      expect(result.state.activityGrid, isEmpty);
    });

    test('never makes counters negative', () {
      final result = UndoManager.undoLastAction(
        UndoState(
          counter1: 0,
          counter2: 0,
          tries: 0,
          total: 0,
          isActionDelay: true,
          delayCountdown: 10,
          activityGrid: [_entry(1), _entry(2), _entry(3)],
        ),
      );

      expect(result.state.counter1, 0);
      expect(result.state.counter2, 0);
      expect(result.state.tries, 0);
      expect(result.state.total, 0);
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
