import 'package:fish_counter/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Status.fromName', () {
    test('parses stored enum names', () {
      expect(Status.fromName('perfect'), Status.perfect);
      expect(Status.fromName('average'), Status.average);
      expect(Status.fromName('poor'), Status.poor);
      expect(Status.fromName('early'), Status.early);
    });

    test('parses legacy color status values', () {
      expect(Status.fromName('green'), Status.perfect);
      expect(Status.fromName('orange'), Status.average);
      expect(Status.fromName('red'), Status.poor);
      expect(Status.fromName('grey'), Status.early);
    });
  });
}
