import 'package:fish_counter/clicker_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseStrictInt rejects invalid or too-small values', () {
    expect(parseStrictInt('', min: 0), isNull);
    expect(parseStrictInt('abc', min: 0), isNull);
    expect(parseStrictInt('-1', min: 0), isNull);
    expect(parseStrictInt('5', min: 0), 5);
  });

  test('parseStrictDuration rejects overflow and zero-length durations', () {
    expect(parseStrictDuration('0', '0', '0'), isNull);
    expect(parseStrictDuration('0', '24', '0'), isNull);
    expect(parseStrictDuration('0', '1', '60'), isNull);
    expect(parseStrictDuration('1', '2', '3')?.inMinutes, 1563);
  });
}
