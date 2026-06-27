import 'dart:math' as math;

import 'package:fish_counter/models/astronomy_info.dart';

class AstronomyService {
  static AstronomyInfo build({
    required DateTime date,
    double? latitude,
    double? longitude,
  }) {
    if (latitude == null || longitude == null) {
      return const AstronomyInfo.empty();
    }

    final sunrise = _solarEvent(date, latitude, longitude, sunrise: true);
    final sunset = _solarEvent(date, latitude, longitude, sunrise: false);
    final civilDawn = _solarEvent(
      date,
      latitude,
      longitude,
      sunrise: true,
      zenith: 96,
    );
    final civilDusk = _solarEvent(
      date,
      latitude,
      longitude,
      sunrise: false,
      zenith: 96,
    );

    return AstronomyInfo(
      sunrise: _formatTime(sunrise),
      sunset: _formatTime(sunset),
      civilDawn: _formatTime(civilDawn),
      civilDusk: _formatTime(civilDusk),
      solarNoon: _formatTime(_solarNoon(sunrise, sunset)),
      moonPhase: _moonPhase(date),
      moonIllumination: _moonIllumination(date),
    );
  }

  static DateTime? _solarEvent(
    DateTime date,
    double latitude,
    double longitude, {
    required bool sunrise,
    double zenith = 90.833,
  }) {
    final day = _dayOfYear(date);
    final lngHour = longitude / 15.0;
    final t = day + ((sunrise ? 6.0 : 18.0) - lngHour) / 24.0;

    final m = 0.9856 * t - 3.289;
    var l = m + 1.916 * math.sin(_degToRad(m)) +
        0.020 * math.sin(2 * _degToRad(m)) + 282.634;
    l = _normalizeDegrees(l);

    var ra = _radToDeg(math.atan(0.91764 * math.tan(_degToRad(l))));
    ra = _normalizeQuadrant(ra, l) / 15.0;

    final sinDec = 0.39782 * math.sin(_degToRad(l));
    final cosDec = math.cos(math.asin(sinDec));

    final cosH = (math.cos(_degToRad(zenith)) - (sinDec * math.sin(_degToRad(latitude)))) /
        (cosDec * math.cos(_degToRad(latitude)));
    if (cosH > 1 || cosH < -1) return null;

    var h = sunrise
        ? 360.0 - _radToDeg(math.acos(cosH))
        : _radToDeg(math.acos(cosH));
    h /= 15.0;

    final tLocal = h + ra - (0.06571 * t) - 6.622;
    var ut = tLocal - lngHour;
    ut = _normalizeHours(ut);

    final localMinutes = (ut * 60 + longitude * 4).round();
    return DateTime(date.year, date.month, date.day).add(
      Duration(minutes: _normalizeMinutes(localMinutes)),
    );
  }

  static DateTime? _solarNoon(DateTime? sunrise, DateTime? sunset) {
    if (sunrise == null || sunset == null) return null;
    return sunrise.add(Duration(milliseconds: sunset.difference(sunrise).inMilliseconds ~/ 2));
  }

  static String _moonPhase(DateTime date) {
    final age = _moonAge(date);
    if (age < 1.84566) return 'new';
    if (age < 5.53699) return 'waxing crescent';
    if (age < 9.22831) return 'first quarter';
    if (age < 12.91963) return 'waxing gibbous';
    if (age < 16.61096) return 'full';
    if (age < 20.30228) return 'waning gibbous';
    if (age < 23.99361) return 'last quarter';
    if (age < 27.68493) return 'waning crescent';
    return 'new';
  }

  static int _moonIllumination(DateTime date) {
    final age = _moonAge(date);
    final phase = age / 29.53058867;
    final illumination = (1 - math.cos(2 * math.pi * phase)) / 2 * 100;
    return illumination.round().clamp(0, 100);
  }

  static double _moonAge(DateTime date) {
    final reference = DateTime.utc(2000, 1, 6, 18, 14);
    final synodicMonth = 29.53058867;
    final days = date.toUtc().difference(reference).inMilliseconds /
        Duration.millisecondsPerDay;
    final age = days % synodicMonth;
    return age < 0 ? age + synodicMonth : age;
  }

  static String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static double _degToRad(double value) => value * math.pi / 180;
  static double _radToDeg(double value) => value * 180 / math.pi;

  static double _normalizeDegrees(double value) {
    var result = value % 360;
    if (result < 0) result += 360;
    return result;
  }

  static double _normalizeHours(double value) {
    var result = value % 24;
    if (result < 0) result += 24;
    return result;
  }

  static double _normalizeQuadrant(double ra, double l) {
    final lQuadrant = (l / 90).floor() * 90;
    final raQuadrant = (ra / 90).floor() * 90;
    return ra + (lQuadrant - raQuadrant);
  }

  static int _normalizeMinutes(int value) {
    var result = value % (24 * 60);
    if (result < 0) result += 24 * 60;
    return result;
  }

  static int _dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }
}
