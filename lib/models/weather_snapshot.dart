class WeatherSnapshot {
  final double latitude;
  final double longitude;
  final String placeName;
  final String description;
  final double? temperatureCelsius;
  final double? feelsLikeCelsius;
  final double? pressureHpa;
  final double? humidityPercent;
  final double? windSpeedMs;
  final double? windDirectionDegrees;
  final String fetchedAt;

  const WeatherSnapshot({
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.description,
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.pressureHpa,
    required this.humidityPercent,
    required this.windSpeedMs,
    required this.windDirectionDegrees,
    required this.fetchedAt,
  });

  String get summary {
    final parts = <String>[];
    if (placeName.isNotEmpty) parts.add(placeName);
    if (description.isNotEmpty) parts.add(description);
    if (temperatureCelsius != null) {
      parts.add('${temperatureCelsius!.toStringAsFixed(1)}°C');
    }
    if (windSpeedMs != null) {
      parts.add('wind ${windSpeedMs!.toStringAsFixed(1)} m/s');
    }
    return parts.join(' • ');
  }
}
