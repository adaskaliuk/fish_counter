import 'package:fish_counter/services/astronomy_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds sun and moon context from date and location', () {
    final info = AstronomyService.build(
      date: DateTime.utc(2026, 6, 25),
      latitude: 50.45,
      longitude: 30.52,
    );

    expect(info.sunrise, isNotEmpty);
    expect(info.sunset, isNotEmpty);
    expect(info.civilDawn, isNotEmpty);
    expect(info.civilDusk, isNotEmpty);
    expect(info.solarNoon, isNotEmpty);
    expect(info.moonPhase, isNotEmpty);
    expect(info.moonIllumination, inInclusiveRange(0, 100));
    expect(info.summary, isNotEmpty);
  });
}
