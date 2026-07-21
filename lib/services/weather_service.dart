import 'dart:convert';

import 'package:fish_counter/models/weather_snapshot.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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

    try {
      final factory = open_weather.WeatherFactory(apiKey);
      final weather = await factory.currentWeatherByLocation(
        latitude,
        longitude,
      );

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
    } catch (_) {
      // Fallback to direct OpenWeather API call. This keeps the app usable if
      // the package request fails while the API key itself is valid.
      return _fetchDirect(latitude, longitude);
    }
  }

  Future<WeatherSnapshot> _fetchDirect(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'appid': apiKey,
      'units': 'metric',
      'lang': 'en',
    });

    final response = await http.get(uri);
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? response.body
          : response.body;
      throw WeatherServiceException(
        'OpenWeather ${response.statusCode}: $message',
      );
    }

    final data = decoded as Map<String, dynamic>;
    final weatherList = data['weather'] as List?;
    final weather = weatherList != null && weatherList.isNotEmpty
        ? weatherList.first as Map
        : null;
    final main = data['main'] as Map<String, dynamic>?;
    final wind = data['wind'] as Map<String, dynamic>?;

    return WeatherSnapshot(
      latitude: latitude,
      longitude: longitude,
      placeName: data['name']?.toString() ?? '',
      description: weather?['description']?.toString() ?? '',
      temperatureCelsius: _toDouble(main?['temp']),
      feelsLikeCelsius: _toDouble(main?['feels_like']),
      pressureHpa: _toDouble(main?['pressure']),
      humidityPercent: _toDouble(main?['humidity']),
      windSpeedMs: _toDouble(wind?['speed']),
      windDirectionDegrees: _toDouble(wind?['deg']),
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

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class WeatherServiceException implements Exception {
  final String message;

  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}
