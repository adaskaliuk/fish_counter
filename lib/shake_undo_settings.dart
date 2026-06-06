enum ShakeSensitivity {
  low('low', 30),
  medium('medium', 24),
  high('high', 18);

  final String value;
  final double threshold;

  const ShakeSensitivity(this.value, this.threshold);

  static ShakeSensitivity fromValue(String? value) {
    return ShakeSensitivity.values.firstWhere(
      (sensitivity) => sensitivity.value == value,
      orElse: () => ShakeSensitivity.medium,
    );
  }
}
