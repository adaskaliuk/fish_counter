import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/models/analytics_report.dart';
import 'package:fish_counter/models/historical_catch_tuning_report.dart';
import 'package:fish_counter/services/readiness_score_calculator.dart';
import 'package:intl/intl.dart';

class FishingWindowForecastDay {
  final DateTime date;
  final int score;
  final int startHour;
  final int endHour;

  const FishingWindowForecastDay({
    required this.date,
    required this.score,
    required this.startHour,
    required this.endHour,
  });

  String windowLabel() {
    return '${_twoDigits(startHour)}:00–${_twoDigits(endHour)}:00';
  }

  String dayLabel([String? locale]) {
    return DateFormat.E(locale).format(date);
  }
}

class FishingWindowForecastReport {
  final int baseScore;
  final List<FishingWindowForecastDay> days;

  const FishingWindowForecastReport({
    required this.baseScore,
    required this.days,
  });

  FishingWindowForecastDay get bestDay {
    return days.reduce((best, day) => day.score > best.score ? day : best);
  }

  static FishingWindowForecastReport fromSession(
    GameSession session,
    AnalyticsReport report,
    {HistoricalCatchTuningReport? tuning}
  ) {
    final baseScore = _baseScore(session, report, tuning: tuning);
    final anchorDate = _anchorDate(session);
    final startHour = _startHour(session);
    const dailySwing = [0, 3, 5, 4, 2, 0, -2];

    final days = List.generate(7, (index) {
      final date = anchorDate.add(Duration(days: index));
      final score = (baseScore + dailySwing[index] - index).round();
      return FishingWindowForecastDay(
        date: date,
        score: score,
        startHour: (startHour + (index >= 4 ? 1 : 0)) % 24,
        endHour: (startHour + 3 + (index >= 4 ? 1 : 0)) % 24,
      );
    });

    return FishingWindowForecastReport(baseScore: baseScore, days: days);
  }

  static int _baseScore(
    GameSession session,
    AnalyticsReport report, {
    HistoricalCatchTuningReport? tuning,
  }) {
    var score = ReadinessScoreCalculator.calculate(
      session,
      report,
      tuning: tuning,
    );

    final weather = session.weatherInfo;
    final description = weather.description.toLowerCase();

    final wind = weather.windSpeedMs;
    if (wind != null) {
      if (wind <= 2) {
        score += 7;
      } else if (wind <= 5) {
        score += 11;
      } else if (wind <= 8) {
        score += 2;
      } else {
        score -= 10;
      }
    }

    final temperature = weather.temperatureCelsius;
    if (temperature != null) {
      if (temperature >= 14 && temperature <= 24) {
        score += 8;
      } else if (temperature < 4 || temperature > 30) {
        score -= 8;
      }
    }

    final pressure = weather.pressureHpa;
    if (pressure != null) {
      if (pressure >= 1008 && pressure <= 1025) {
        score += 5;
      } else if (pressure < 995 || pressure > 1035) {
        score -= 5;
      }
    }

    final humidity = weather.humidityPercent;
    if (humidity != null) {
      if (humidity >= 45 && humidity <= 80) {
        score += 3;
      } else if (humidity > 90) {
        score -= 4;
      }
    }

    if (description.contains('storm') ||
        description.contains('thunder') ||
        description.contains('rain')) {
      score -= 7;
    } else if (description.contains('cloud')) {
      score += 3;
    } else if (description.contains('clear')) {
      score += 5;
    }

    return score.round();
  }

  static DateTime _anchorDate(GameSession session) {
    final parsed = _parseDdMmYy(session.date);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }

    final iso = DateTime.tryParse(session.date);
    if (iso != null) {
      return DateTime(iso.year, iso.month, iso.day);
    }

    final updated = DateTime.tryParse(session.updatedAt);
    if (updated != null) {
      return DateTime(updated.year, updated.month, updated.day);
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int _startHour(GameSession session) {
    final weather = session.weatherInfo;
    final description = weather.description.toLowerCase();
    final temperature = weather.temperatureCelsius ?? 0;
    final wind = weather.windSpeedMs ?? 0;

    if (description.contains('storm') || description.contains('rain')) {
      return 6;
    }

    if (temperature >= 24) {
      return 18;
    }

    if (wind >= 7) {
      return 5;
    }

    if (description.contains('cloud')) {
      return 7;
    }

    return 6;
  }

  static DateTime? _parseDdMmYy(String value) {
    final parts = value.split('.');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year < 100 ? 2000 + year : year, month, day);
  }
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
