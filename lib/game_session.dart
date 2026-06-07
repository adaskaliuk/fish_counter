// ==========================================
// SESSION MODEL
// ==========================================
class GameSession {
  final String id, name, date, matchDuration;
  final String userId, userEmail, userDisplayName;
  final String athleteName, coachName, venue, sectorPeg;
  final String trainingType, fishingMethod, targetPace, conditions, baitNotes;
  final String weatherPlace, weatherDescription, weatherFetchedAt;
  final double? latitude, longitude;
  final double? weatherTemperatureCelsius, weatherFeelsLikeCelsius;
  final double? weatherPressureHpa, weatherHumidityPercent;
  final double? weatherWindSpeedMs, weatherWindDirectionDegrees;
  final String athleteNote, coachComment;
  final int c1, c2, tries, total;
  final List<Map<String, dynamic>> grid;

  GameSession({
    required this.id,
    required this.name,
    required this.date,
    required this.c1,
    required this.c2,
    required this.tries,
    required this.total,
    required this.matchDuration,
    required this.grid,
    this.userId = '',
    this.userEmail = '',
    this.userDisplayName = '',
    this.athleteName = '',
    this.coachName = '',
    this.venue = '',
    this.sectorPeg = '',
    this.trainingType = '',
    this.fishingMethod = '',
    this.targetPace = '',
    this.conditions = '',
    this.baitNotes = '',
    this.weatherPlace = '',
    this.weatherDescription = '',
    this.weatherFetchedAt = '',
    this.latitude,
    this.longitude,
    this.weatherTemperatureCelsius,
    this.weatherFeelsLikeCelsius,
    this.weatherPressureHpa,
    this.weatherHumidityPercent,
    this.weatherWindSpeedMs,
    this.weatherWindDirectionDegrees,
    this.athleteNote = '',
    this.coachComment = '',
  });

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
    'userId': userId,
    'userEmail': userEmail,
    'userDisplayName': userDisplayName,
    'athleteName': athleteName,
    'coachName': coachName,
    'venue': venue,
    'sectorPeg': sectorPeg,
    'trainingType': trainingType,
    'fishingMethod': fishingMethod,
    'targetPace': targetPace,
    'conditions': conditions,
    'baitNotes': baitNotes,
    'weatherPlace': weatherPlace,
    'weatherDescription': weatherDescription,
    'weatherFetchedAt': weatherFetchedAt,
    'latitude': latitude,
    'longitude': longitude,
    'weatherTemperatureCelsius': weatherTemperatureCelsius,
    'weatherFeelsLikeCelsius': weatherFeelsLikeCelsius,
    'weatherPressureHpa': weatherPressureHpa,
    'weatherHumidityPercent': weatherHumidityPercent,
    'weatherWindSpeedMs': weatherWindSpeedMs,
    'weatherWindDirectionDegrees': weatherWindDirectionDegrees,
    'athleteNote': athleteNote,
    'coachComment': coachComment,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: _safeString(json['id']),
      name: _safeString(json['name'], defaultValue: 'Session'),
      date: _safeString(json['date'], defaultValue: '--'),
      c1: _safeInt(json['c1']),
      c2: _safeInt(json['c2']),
      tries: _safeInt(json['tries']),
      total: _safeInt(json['total']),
      matchDuration: _safeString(
        json['matchDuration'],
        defaultValue: '00:00:00',
      ),
      grid: _safeGridList(json['grid']),
      userId: _safeString(json['userId']),
      userEmail: _safeString(json['userEmail']),
      userDisplayName: _safeString(json['userDisplayName']),
      athleteName: _safeString(json['athleteName']),
      coachName: _safeString(json['coachName']),
      venue: _safeString(json['venue']),
      sectorPeg: _safeString(json['sectorPeg']),
      trainingType: _safeString(json['trainingType']),
      fishingMethod: _safeString(json['fishingMethod']),
      targetPace: _safeString(json['targetPace']),
      conditions: _safeString(json['conditions']),
      baitNotes: _safeString(json['baitNotes']),
      weatherPlace: _safeString(json['weatherPlace']),
      weatherDescription: _safeString(json['weatherDescription']),
      weatherFetchedAt: _safeString(json['weatherFetchedAt']),
      latitude: _safeDouble(json['latitude']),
      longitude: _safeDouble(json['longitude']),
      weatherTemperatureCelsius: _safeDouble(json['weatherTemperatureCelsius']),
      weatherFeelsLikeCelsius: _safeDouble(json['weatherFeelsLikeCelsius']),
      weatherPressureHpa: _safeDouble(json['weatherPressureHpa']),
      weatherHumidityPercent: _safeDouble(json['weatherHumidityPercent']),
      weatherWindSpeedMs: _safeDouble(json['weatherWindSpeedMs']),
      weatherWindDirectionDegrees: _safeDouble(
        json['weatherWindDirectionDegrees'],
      ),
      athleteNote: _safeString(json['athleteNote']),
      coachComment: _safeString(json['coachComment']),
    );
  }

  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static List<Map<String, dynamic>> _safeGridList(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
}
