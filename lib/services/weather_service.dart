import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart' as open_weather;

class SessionWeatherService {
  static const String apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

  Future<WeatherSnapshot> fetchCurrentWeather() async {
    if (apiKey.isEmpty) {
      throw const WeatherServiceException(
        'OPENWEATHER_API_KEY is missing. Run with --dart-define=OPENWEATHER_API_KEY=...',
      );
    }

    final position = await _currentPosition();
    final latitude = _roundCoordinate(position.latitude);
    final longitude = _roundCoordinate(position.longitude);

    final factory = open_weather.WeatherFactory(apiKey);
    final weather = await factory.currentWeatherByLocation(latitude, longitude);

    return WeatherSnapshot(
      latitude: latitude,
      longitude: longitude,
      placeName: weather.areaName ?? '',
      description: weather.weatherDescription ?? weather.weatherMain ?? '',
      temperatureCelsius: weather.temperature?.celsius,
      feelsLikeCelsius: weather.tempFeelsLike?.celsius,
      pressureHpa: weather.pressure,
      humidityPercent: weather.humidity,
      windSpeedMs: weather.windSpeed,
      windDirectionDegrees: weather.windDegree,
      fetchedAt: DateTime.now().toIso8601String(),
    );
  }

  Future<Position> _currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherServiceException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const WeatherServiceException('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const WeatherServiceException(
        'Location permission permanently denied.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }

  static double _roundCoordinate(double value) =>
      double.parse(value.toStringAsFixed(3));
}

class WeatherServiceException implements Exception {
  final String message;

  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}
