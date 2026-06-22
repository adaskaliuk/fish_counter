typedef UndoResult = ({
  bool didUndo,
  int counter1,
  int counter2,
  int tries,
  int total,
  bool isActionDelay,
  int delayCountdown,
  List<Map<String, dynamic>> activityGrid,
});

UndoResult undoLastAction({
  required int counter1,
  required int counter2,
  required int tries,
  required bool isActionDelay,
  required int delayCountdown,
  required List<Map<String, dynamic>> activityGrid,
}) {
  if (activityGrid.isEmpty) {
    return (
      didUndo: false,
      counter1: counter1,
      counter2: counter2,
      tries: tries,
      total: counter1 + counter2,
      isActionDelay: isActionDelay,
      delayCountdown: delayCountdown,
      activityGrid: activityGrid,
    );
  }

  final updatedGrid = List<Map<String, dynamic>>.from(activityGrid);
  final lastEntry = updatedGrid.removeLast();
  final type = _safeInt(lastEntry['type']);

  if (type == 1 && counter1 > 0) counter1--;
  if (type == 2 && counter2 > 0) counter2--;
  if (type == 3 && tries > 0) tries--;

  return (
    didUndo: true,
    counter1: counter1,
    counter2: counter2,
    tries: tries,
    total: counter1 + counter2,
    isActionDelay: false,
    delayCountdown: 0,
    activityGrid: updatedGrid,
  );
}

int _safeInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}
