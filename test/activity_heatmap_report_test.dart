import 'package:fish_counter/constants.dart';
import 'package:fish_counter/models/activity_heatmap_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups activity grid into heatmap rows', () {
    final report = ActivityHeatmapReport.fromGrid([
      _entry(type: 1, status: 'green', interval: 60, timestamp: '10:00:00'),
      _entry(type: 2, status: 'orange', interval: 45, timestamp: '10:01:00'),
      _entry(type: 0, status: 'grey', interval: 0, timestamp: '10:02:00'),
      _entry(type: 3, status: 'red', interval: 90, timestamp: '10:03:00'),
      _entry(type: 9, status: 'green', interval: 12, timestamp: '10:04:00'),
    ], columns: 2);

    expect(report.hasData, isTrue);
    expect(report.cells.length, 4);
    expect(report.rowCount, 2);
    expect(report.rows, hasLength(2));
    expect(report.rows.first, hasLength(2));
    expect(report.rows.last, hasLength(2));
    expect(report.cells[2].status, Status.pause);
    expect(report.cells[3].status, Status.poor);
  });
}

Map<String, dynamic> _entry({
  required int type,
  required String status,
  required int interval,
  required String timestamp,
}) {
  return {
    'type': type,
    'status': status,
    'interval': interval,
    'timestamp': timestamp,
  };
}
