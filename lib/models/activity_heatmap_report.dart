import 'package:fish_counter/constants.dart';

class ActivityHeatmapReport {
  ActivityHeatmapReport(this.cells, {this.columns = 12});

  factory ActivityHeatmapReport.fromGrid(
    List<Map<String, dynamic>> grid, {
    int columns = 12,
  }) {
    final cells = <ActivityHeatmapCell>[];
    for (final entry in grid) {
      final type = ActivityType.fromValue(_safeInt(entry['type']));
      if (type == ActivityType.unknown) continue;
      cells.add(
        ActivityHeatmapCell(
          type: type,
          status: _statusForEntry(entry),
          intervalSeconds: _safeInt(entry['interval']),
          timestamp: entry['timestamp']?.toString() ?? '--:--:--',
        ),
      );
    }

    return ActivityHeatmapReport(cells, columns: columns);
  }

  final List<ActivityHeatmapCell> cells;
  final int columns;

  bool get hasData => cells.isNotEmpty;
  int get rowCount => (cells.length / columns).ceil();

  List<List<ActivityHeatmapCell>> get rows {
    final rows = <List<ActivityHeatmapCell>>[];
    for (var i = 0; i < cells.length; i += columns) {
      final end = i + columns > cells.length ? cells.length : i + columns;
      rows.add(cells.sublist(i, end));
    }
    return rows;
  }

  static Status _statusForEntry(Map<String, dynamic> entry) {
    final type = ActivityType.fromValue(_safeInt(entry['type']));
    if (type == ActivityType.manualPause) return Status.pause;
    return Status.fromName(entry['status']?.toString());
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}

class ActivityHeatmapCell {
  const ActivityHeatmapCell({
    required this.type,
    required this.status,
    required this.intervalSeconds,
    required this.timestamp,
  });

  final ActivityType type;
  final Status status;
  final int intervalSeconds;
  final String timestamp;
}
