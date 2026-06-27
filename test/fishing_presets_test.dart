import 'package:fish_counter/models/fishing_presets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines species and body type weights', () {
    final weights = FishingPresets.weightsFor(
      speciesPreset: FishingPresets.speciesCarp,
      bodyTypePreset: FishingPresets.bodyStocky,
    );

    expect(weights.stability, greaterThan(1.3));
    expect(weights.fishCount, greaterThan(1.2));
    expect(weights.tries, lessThan(1));
    expect(weights.pace, lessThan(1));
  });
}
