class UndoState {
  final int counter1;
  final int counter2;
  final int tries;
  final int total;
  final bool isActionDelay;
  final int delayCountdown;
  final List<Map<String, dynamic>> activityGrid;

  const UndoState({
    required this.counter1,
    required this.counter2,
    required this.tries,
    required this.total,
    required this.isActionDelay,
    required this.delayCountdown,
    required this.activityGrid,
  });
}

class UndoResult {
  final bool didUndo;
  final UndoState state;

  const UndoResult({required this.didUndo, required this.state});
}

class UndoManager {
  static UndoResult undoLastAction(UndoState state) {
    if (state.activityGrid.isEmpty) {
      return UndoResult(didUndo: false, state: state);
    }

    final updatedGrid = List<Map<String, dynamic>>.from(state.activityGrid);
    final lastEntry = updatedGrid.removeLast();
    final type = _safeInt(lastEntry['type']);

    var counter1 = state.counter1;
    var counter2 = state.counter2;
    var tries = state.tries;

    if (type == 1 && counter1 > 0) counter1--;
    if (type == 2 && counter2 > 0) counter2--;
    if (type == 3 && tries > 0) tries--;

    return UndoResult(
      didUndo: true,
      state: UndoState(
        counter1: counter1,
        counter2: counter2,
        tries: tries,
        total: counter1 + counter2,
        isActionDelay: false,
        delayCountdown: 0,
        activityGrid: updatedGrid,
      ),
    );
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}
