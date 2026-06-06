import 'package:fish_counter/shake_undo_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShakeSensitivity', () {
    test('parses saved values', () {
      expect(ShakeSensitivity.fromValue('low'), ShakeSensitivity.low);
      expect(ShakeSensitivity.fromValue('medium'), ShakeSensitivity.medium);
      expect(ShakeSensitivity.fromValue('high'), ShakeSensitivity.high);
    });

    test('falls back to medium for unknown values', () {
      expect(ShakeSensitivity.fromValue(null), ShakeSensitivity.medium);
      expect(ShakeSensitivity.fromValue('unknown'), ShakeSensitivity.medium);
    });

    test('uses lower thresholds for higher sensitivity', () {
      expect(
        ShakeSensitivity.low.threshold,
        greaterThan(ShakeSensitivity.medium.threshold),
      );
      expect(
        ShakeSensitivity.medium.threshold,
        greaterThan(ShakeSensitivity.high.threshold),
      );
    });
  });
}
