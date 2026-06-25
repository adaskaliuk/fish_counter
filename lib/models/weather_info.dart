class WeatherInfo {
  final String place;
  final String description;
  final String fetchedAt;
  final double? latitude;
  final double? longitude;
  final double? temperatureCelsius;
  final double? feelsLikeCelsius;
  final double? pressureHpa;
  final double? humidityPercent;
  final double? windSpeedMs;
  final double? windDirectionDegrees;

  const WeatherInfo({
    this.place = '',
    this.description = '',
    this.fetchedAt = '',
    this.latitude,
    this.longitude,
    this.temperatureCelsius,
    this.feelsLikeCelsius,
    this.pressureHpa,
    this.humidityPercent,
    this.windSpeedMs,
    this.windDirectionDegrees,
  });

  WeatherInfo copyWith({
    String? place,
    String? description,
    String? fetchedAt,
    double? latitude,
    double? longitude,
    double? temperatureCelsius,
    double? feelsLikeCelsius,
    double? pressureHpa,
    double? humidityPercent,
    double? windSpeedMs,
    double? windDirectionDegrees,
  }) {
    return WeatherInfo(
      place: place ?? this.place,
      description: description ?? this.description,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      feelsLikeCelsius: feelsLikeCelsius ?? this.feelsLikeCelsius,
      pressureHpa: pressureHpa ?? this.pressureHpa,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      windSpeedMs: windSpeedMs ?? this.windSpeedMs,
      windDirectionDegrees: windDirectionDegrees ?? this.windDirectionDegrees,
    );
  }

  Map<String, dynamic> toJson() => {
    'weatherPlace': place,
    'weatherDescription': description,
    'weatherFetchedAt': fetchedAt,
    'latitude': latitude,
    'longitude': longitude,
    'weatherTemperatureCelsius': temperatureCelsius,
    'weatherFeelsLikeCelsius': feelsLikeCelsius,
    'weatherPressureHpa': pressureHpa,
    'weatherHumidityPercent': humidityPercent,
    'weatherWindSpeedMs': windSpeedMs,
    'weatherWindDirectionDegrees': windDirectionDegrees,
  };

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      place: json['weatherPlace'] ?? '',
      description: json['weatherDescription'] ?? '',
      fetchedAt: json['weatherFetchedAt'] ?? '',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      temperatureCelsius: json['weatherTemperatureCelsius'] as double?,
      feelsLikeCelsius: json['weatherFeelsLikeCelsius'] as double?,
      pressureHpa: json['weatherPressureHpa'] as double?,
      humidityPercent: json['weatherHumidityPercent'] as double?,
      windSpeedMs: json['weatherWindSpeedMs'] as double?,
      windDirectionDegrees: json['weatherWindDirectionDegrees'] as double?,
    );
  }
}
