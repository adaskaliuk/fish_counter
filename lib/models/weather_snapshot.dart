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

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'placeName': placeName,
    'description': description,
    'temperatureCelsius': temperatureCelsius,
    'feelsLikeCelsius': feelsLikeCelsius,
    'pressureHpa': pressureHpa,
    'humidityPercent': humidityPercent,
    'windSpeedMs': windSpeedMs,
    'windDirectionDegrees': windDirectionDegrees,
    'fetchedAt': fetchedAt,
  };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      placeName: json['placeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      temperatureCelsius: _toDouble(json['temperatureCelsius']),
      feelsLikeCelsius: _toDouble(json['feelsLikeCelsius']),
      pressureHpa: _toDouble(json['pressureHpa']),
      humidityPercent: _toDouble(json['humidityPercent']),
      windSpeedMs: _toDouble(json['windSpeedMs']),
      windDirectionDegrees: _toDouble(json['windDirectionDegrees']),
      fetchedAt: json['fetchedAt']?.toString() ?? '',
    );
  }

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

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
