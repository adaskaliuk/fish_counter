class FishingPresetWeights {
  final double stability;
  final double fishCount;
  final double tries;
  final double pace;

  const FishingPresetWeights({
    this.stability = 1,
    this.fishCount = 1,
    this.tries = 1,
    this.pace = 1,
  });

  FishingPresetWeights operator *(FishingPresetWeights other) {
    return FishingPresetWeights(
      stability: stability * other.stability,
      fishCount: fishCount * other.fishCount,
      tries: tries * other.tries,
      pace: pace * other.pace,
    );
  }
}

class FishingPresets {
  static const none = '';

  static const speciesCarp = 'carp';
  static const speciesBream = 'bream';
  static const speciesRoach = 'roach';

  static const bodyStocky = 'stocky';
  static const bodyBalanced = 'balanced';
  static const bodySlim = 'slim';

  static const defaultSpecies = none;
  static const defaultBodyType = none;

  static const speciesOptions = [
    none,
    speciesCarp,
    speciesBream,
    speciesRoach,
  ];

  static const bodyTypeOptions = [
    none,
    bodyStocky,
    bodyBalanced,
    bodySlim,
  ];

  static FishingPresetWeights weightsFor({
    required String speciesPreset,
    required String bodyTypePreset,
  }) {
    return _speciesWeights(speciesPreset) * _bodyWeights(bodyTypePreset);
  }

  static FishingPresetWeights _speciesWeights(String preset) {
    switch (preset) {
      case speciesCarp:
        return const FishingPresetWeights(
          stability: 1.25,
          fishCount: 1.18,
          tries: 0.92,
          pace: 0.9,
        );
      case speciesBream:
        return const FishingPresetWeights(
          stability: 1.1,
          fishCount: 1.05,
          tries: 1,
          pace: 1.05,
        );
      case speciesRoach:
        return const FishingPresetWeights(
          stability: 0.95,
          fishCount: 1.12,
          tries: 1.02,
          pace: 1.15,
        );
      case none:
      default:
        return const FishingPresetWeights();
    }
  }

  static FishingPresetWeights _bodyWeights(String preset) {
    switch (preset) {
      case bodyStocky:
        return const FishingPresetWeights(
          stability: 1.12,
          fishCount: 1.04,
          tries: 0.97,
          pace: 0.95,
        );
      case bodyBalanced:
        return const FishingPresetWeights(
          stability: 1.02,
          fishCount: 1,
          tries: 1,
          pace: 1.02,
        );
      case bodySlim:
        return const FishingPresetWeights(
          stability: 0.96,
          fishCount: 1.02,
          tries: 1.02,
          pace: 1.08,
        );
      case none:
      default:
        return const FishingPresetWeights();
    }
  }
}
