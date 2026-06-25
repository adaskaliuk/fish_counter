import 'package:fish_counter/models/session_goals.dart';
import 'package:fish_counter/models/session_user_info.dart';
import 'package:fish_counter/models/session_venue_info.dart';
import 'package:fish_counter/models/weather_info.dart';
import 'package:fish_counter/utils/type_utils.dart';

// ==========================================
// SESSION MODEL
// ==========================================
class GameSession {
  final String id, name, date, matchDuration;
  final String athleteName, coachName;
  final String updatedAt;
  final String athleteNote, coachComment;
  final int c1, c2, tries, total;
  final List<Map<String, dynamic>> grid;
  final SessionUserInfo userInfo;
  final SessionVenueInfo venueInfo;
  final SessionGoals goals;
  final WeatherInfo weatherInfo;

  // Backward-compatible flat accessors.
  String get userId => userInfo.userId;
  String get userEmail => userInfo.userEmail;
  String get userDisplayName => userInfo.userDisplayName;
  String get venue => venueInfo.venue;
  String get sectorPeg => venueInfo.sectorPeg;
  String get trainingType => venueInfo.trainingType;
  String get fishingMethod => venueInfo.fishingMethod;
  String get targetPace => venueInfo.targetPace;
  String get conditions => venueInfo.conditions;
  String get baitNotes => venueInfo.baitNotes;
  int get goalFishCount => goals.goalFishCount;
  int get goalTargetPaceSeconds => goals.goalTargetPaceSeconds;
  int get goalMaxTries => goals.goalMaxTries;
  int get goalStabilityPercent => goals.goalStabilityPercent;
  String get weatherPlace => weatherInfo.place;
  String get weatherDescription => weatherInfo.description;
  String get weatherFetchedAt => weatherInfo.fetchedAt;
  double? get latitude => weatherInfo.latitude;
  double? get longitude => weatherInfo.longitude;
  double? get weatherTemperatureCelsius => weatherInfo.temperatureCelsius;
  double? get weatherFeelsLikeCelsius => weatherInfo.feelsLikeCelsius;
  double? get weatherPressureHpa => weatherInfo.pressureHpa;
  double? get weatherHumidityPercent => weatherInfo.humidityPercent;
  double? get weatherWindSpeedMs => weatherInfo.windSpeedMs;
  double? get weatherWindDirectionDegrees => weatherInfo.windDirectionDegrees;

  GameSession._({
    required this.id,
    required this.name,
    required this.date,
    required this.c1,
    required this.c2,
    required this.tries,
    required this.total,
    required this.matchDuration,
    required this.grid,
    SessionUserInfo? userInfo,
    SessionVenueInfo? venueInfo,
    SessionGoals? goals,
    WeatherInfo? weatherInfo,
    String weatherPlace = '',
    String weatherDescription = '',
    String weatherFetchedAt = '',
    double? latitude,
    double? longitude,
    double? weatherTemperatureCelsius,
    double? weatherFeelsLikeCelsius,
    double? weatherPressureHpa,
    double? weatherHumidityPercent,
    double? weatherWindSpeedMs,
    double? weatherWindDirectionDegrees,
    required this.updatedAt,
    this.athleteName = '',
    this.coachName = '',
    this.athleteNote = '',
    this.coachComment = '',
  })  : userInfo = userInfo ?? const SessionUserInfo(),
        venueInfo = venueInfo ?? const SessionVenueInfo(),
        goals = goals ?? const SessionGoals(),
        weatherInfo =
            weatherInfo ??
            WeatherInfo(
              place: weatherPlace,
              description: weatherDescription,
              fetchedAt: weatherFetchedAt,
              latitude: latitude,
              longitude: longitude,
              temperatureCelsius: weatherTemperatureCelsius,
              feelsLikeCelsius: weatherFeelsLikeCelsius,
              pressureHpa: weatherPressureHpa,
              humidityPercent: weatherHumidityPercent,
              windSpeedMs: weatherWindSpeedMs,
              windDirectionDegrees: weatherWindDirectionDegrees,
            );

  factory GameSession({
    required String id,
    required String name,
    required String date,
    required int c1,
    required int c2,
    required int tries,
    required int total,
    required String matchDuration,
    required List<Map<String, dynamic>> grid,
    SessionUserInfo? userInfo,
    SessionVenueInfo? venueInfo,
    SessionGoals? goals,
    WeatherInfo? weatherInfo,
    String userId = '',
    String userEmail = '',
    String userDisplayName = '',
    String venue = '',
    String sectorPeg = '',
    String trainingType = '',
    String fishingMethod = '',
    String targetPace = '',
    String conditions = '',
    String baitNotes = '',
    int goalFishCount = 0,
    int goalTargetPaceSeconds = 0,
    int goalMaxTries = 0,
    int goalStabilityPercent = 0,
    String weatherPlace = '',
    String weatherDescription = '',
    String weatherFetchedAt = '',
    double? latitude,
    double? longitude,
    double? weatherTemperatureCelsius,
    double? weatherFeelsLikeCelsius,
    double? weatherPressureHpa,
    double? weatherHumidityPercent,
    double? weatherWindSpeedMs,
    double? weatherWindDirectionDegrees,
    String athleteNote = '',
    String coachComment = '',
    String? updatedAt,
    String athleteName = '',
    String coachName = '',
  }) {
    return GameSession._(
      id: id,
      name: name,
      date: date,
      c1: c1,
      c2: c2,
      tries: tries,
      total: total,
      matchDuration: matchDuration,
      grid: grid,
      userInfo: userInfo ?? SessionUserInfo(
        userId: userId,
        userEmail: userEmail,
        userDisplayName: userDisplayName,
      ),
      venueInfo: venueInfo ?? SessionVenueInfo(
        venue: venue,
        sectorPeg: sectorPeg,
        trainingType: trainingType,
        fishingMethod: fishingMethod,
        targetPace: targetPace,
        conditions: conditions,
        baitNotes: baitNotes,
      ),
      goals: goals ?? SessionGoals(
        goalFishCount: goalFishCount,
        goalTargetPaceSeconds: goalTargetPaceSeconds,
        goalMaxTries: goalMaxTries,
        goalStabilityPercent: goalStabilityPercent,
      ),
      weatherInfo: weatherInfo ?? WeatherInfo(
        place: weatherPlace,
        description: weatherDescription,
        fetchedAt: weatherFetchedAt,
        latitude: latitude,
        longitude: longitude,
        temperatureCelsius: weatherTemperatureCelsius,
        feelsLikeCelsius: weatherFeelsLikeCelsius,
        pressureHpa: weatherPressureHpa,
        humidityPercent: weatherHumidityPercent,
        windSpeedMs: weatherWindSpeedMs,
        windDirectionDegrees: weatherWindDirectionDegrees,
      ),
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
      athleteName: athleteName,
      coachName: coachName,
      athleteNote: athleteNote,
      coachComment: coachComment,
    );
  }

  GameSession copyWith({
    String? name,
    String? venue,
    String? sectorPeg,
    String? trainingType,
    String? fishingMethod,
    String? targetPace,
    String? conditions,
    String? baitNotes,
    String? athleteName,
    String? coachName,
    String? athleteNote,
    String? coachComment,
    String? updatedAt,
    SessionUserInfo? userInfo,
    SessionVenueInfo? venueInfo,
    SessionGoals? goals,
    WeatherInfo? weatherInfo,
  }) {
    return GameSession._(
      id: id,
      name: name ?? this.name,
      date: date,
      c1: c1,
      c2: c2,
      tries: tries,
      total: total,
      matchDuration: matchDuration,
      grid: List<Map<String, dynamic>>.from(grid),
      userInfo: userInfo ?? this.userInfo,
      venueInfo: venueInfo ??
          (venue == null &&
                  sectorPeg == null &&
                  trainingType == null &&
                  fishingMethod == null &&
                  targetPace == null &&
                  conditions == null &&
                  baitNotes == null
              ? this.venueInfo
              : this.venueInfo.copyWith(
                  venue: venue,
                  sectorPeg: sectorPeg,
                  trainingType: trainingType,
                  fishingMethod: fishingMethod,
                  targetPace: targetPace,
                  conditions: conditions,
                  baitNotes: baitNotes,
                )),
      goals: goals ?? this.goals,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      updatedAt: updatedAt ?? this.updatedAt,
      athleteName: athleteName ?? this.athleteName,
      coachName: coachName ?? this.coachName,
      athleteNote: athleteNote ?? this.athleteNote,
      coachComment: coachComment ?? this.coachComment,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date,
    'c1': c1,
    'c2': c2,
    'tries': tries,
    'total': total,
    'matchDuration': matchDuration,
    'grid': grid,
    'athleteName': athleteName,
    'coachName': coachName,
    'updatedAt': updatedAt,
    'athleteNote': athleteNote,
    'coachComment': coachComment,
    ...userInfo.toJson(),
    ...venueInfo.toJson(),
    ...goals.toJson(),
    ...weatherInfo.toJson(),
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession._(
      id: TypeUtils.safeString(json['id']),
      name: TypeUtils.safeString(json['name'], defaultValue: 'Session'),
      date: TypeUtils.safeString(json['date'], defaultValue: '--'),
      c1: TypeUtils.safeInt(json['c1']),
      c2: TypeUtils.safeInt(json['c2']),
      tries: TypeUtils.safeInt(json['tries']),
      total: TypeUtils.safeInt(json['total']),
      matchDuration: TypeUtils.safeString(
        json['matchDuration'],
        defaultValue: '00:00:00',
      ),
      grid: TypeUtils.safeMapList(json['grid']),
      userInfo: SessionUserInfo.fromJson(json),
      venueInfo: SessionVenueInfo.fromJson(json),
      goals: SessionGoals.fromJson(json),
      weatherInfo: WeatherInfo.fromJson(json),
      updatedAt: TypeUtils.safeString(
        json['updatedAt'],
        defaultValue: TypeUtils.safeString(json['id']),
      ),
      athleteName: TypeUtils.safeString(json['athleteName']),
      coachName: TypeUtils.safeString(json['coachName']),
      athleteNote: TypeUtils.safeString(json['athleteNote']),
      coachComment: TypeUtils.safeString(json['coachComment']),
    );
  }
}

class GameSessionBuilder {
  String? _id, _name, _date, _matchDuration;
  int? _c1, _c2, _tries, _total;
  List<Map<String, dynamic>>? _grid;
  SessionUserInfo? _userInfo;
  SessionVenueInfo? _venueInfo;
  SessionGoals? _goals;
  String? _updatedAt;
  String? _athleteName, _coachName;
  String? _weatherPlace, _weatherDescription, _weatherFetchedAt;
  double? _latitude, _longitude;
  double? _weatherTemperatureCelsius, _weatherFeelsLikeCelsius;
  double? _weatherPressureHpa, _weatherHumidityPercent;
  double? _weatherWindSpeedMs, _weatherWindDirectionDegrees;
  String? _athleteNote, _coachComment;

  GameSessionBuilder id(String value) {
    _id = value;
    return this;
  }

  GameSessionBuilder name(String value) {
    _name = value;
    return this;
  }

  GameSessionBuilder date(String value) {
    _date = value;
    return this;
  }

  GameSessionBuilder counters({
    required int c1,
    required int c2,
    required int tries,
    required int total,
  }) {
    _c1 = c1;
    _c2 = c2;
    _tries = tries;
    _total = total;
    return this;
  }

  GameSessionBuilder matchDuration(String value) {
    _matchDuration = value;
    return this;
  }

  GameSessionBuilder grid(List<Map<String, dynamic>> value) {
    _grid = value;
    return this;
  }

  GameSessionBuilder userInfo(SessionUserInfo value) {
    _userInfo = value;
    return this;
  }

  GameSessionBuilder venueInfo(SessionVenueInfo value) {
    _venueInfo = value;
    return this;
  }

  GameSessionBuilder goals(SessionGoals value) {
    _goals = value;
    return this;
  }

  GameSessionBuilder athleteName(String value) {
    _athleteName = value;
    return this;
  }

  GameSessionBuilder coachName(String value) {
    _coachName = value;
    return this;
  }

  GameSessionBuilder weatherPlace(String value) {
    _weatherPlace = value;
    return this;
  }

  GameSessionBuilder weatherDescription(String value) {
    _weatherDescription = value;
    return this;
  }

  GameSessionBuilder weatherFetchedAt(String value) {
    _weatherFetchedAt = value;
    return this;
  }

  GameSessionBuilder location({double? latitude, double? longitude}) {
    _latitude = latitude;
    _longitude = longitude;
    return this;
  }

  GameSessionBuilder weatherData({
    double? temperatureCelsius,
    double? feelsLikeCelsius,
    double? pressureHpa,
    double? humidityPercent,
    double? windSpeedMs,
    double? windDirectionDegrees,
  }) {
    _weatherTemperatureCelsius = temperatureCelsius;
    _weatherFeelsLikeCelsius = feelsLikeCelsius;
    _weatherPressureHpa = pressureHpa;
    _weatherHumidityPercent = humidityPercent;
    _weatherWindSpeedMs = windSpeedMs;
    _weatherWindDirectionDegrees = windDirectionDegrees;
    return this;
  }

  GameSessionBuilder notes({
    String? athleteNote,
    String? coachComment,
  }) {
    _athleteNote = athleteNote;
    _coachComment = coachComment;
    return this;
  }

  GameSessionBuilder updatedAt(String value) {
    _updatedAt = value;
    return this;
  }

  GameSession build() {
    return GameSession._(
      id: _id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name ?? 'Session',
      date: _date ?? '--',
      c1: _c1 ?? 0,
      c2: _c2 ?? 0,
      tries: _tries ?? 0,
      total: _total ?? 0,
      matchDuration: _matchDuration ?? '00:00:00',
      grid: _grid ?? [],
      userInfo: _userInfo ?? const SessionUserInfo(),
      venueInfo: _venueInfo ?? const SessionVenueInfo(),
      goals: _goals ?? const SessionGoals(),
      updatedAt: _updatedAt ?? DateTime.now().toIso8601String(),
      athleteName: _athleteName ?? '',
      coachName: _coachName ?? '',
      weatherPlace: _weatherPlace ?? '',
      weatherDescription: _weatherDescription ?? '',
      weatherFetchedAt: _weatherFetchedAt ?? '',
      latitude: _latitude,
      longitude: _longitude,
      weatherTemperatureCelsius: _weatherTemperatureCelsius,
      weatherFeelsLikeCelsius: _weatherFeelsLikeCelsius,
      weatherPressureHpa: _weatherPressureHpa,
      weatherHumidityPercent: _weatherHumidityPercent,
      weatherWindSpeedMs: _weatherWindSpeedMs,
      weatherWindDirectionDegrees: _weatherWindDirectionDegrees,
      athleteNote: _athleteNote ?? '',
      coachComment: _coachComment ?? '',
    );
  }
}
