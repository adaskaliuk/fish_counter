class AstronomyInfo {
  final String sunrise;
  final String sunset;
  final String civilDawn;
  final String civilDusk;
  final String solarNoon;
  final String moonPhase;
  final int moonIllumination;

  const AstronomyInfo({
    this.sunrise = '',
    this.sunset = '',
    this.civilDawn = '',
    this.civilDusk = '',
    this.solarNoon = '',
    this.moonPhase = '',
    this.moonIllumination = 0,
  });

  const AstronomyInfo.empty()
    : sunrise = '',
      sunset = '',
      civilDawn = '',
      civilDusk = '',
      solarNoon = '',
      moonPhase = '',
      moonIllumination = 0;

  bool get isEmpty =>
      sunrise.isEmpty &&
      sunset.isEmpty &&
      civilDawn.isEmpty &&
      civilDusk.isEmpty &&
      solarNoon.isEmpty &&
      moonPhase.isEmpty;

  String get summary {
    if (isEmpty) return '';
    final parts = <String>[];
    if (sunrise.isNotEmpty && sunset.isNotEmpty) {
      parts.add('sunrise $sunrise / sunset $sunset');
    }
    if (civilDawn.isNotEmpty && civilDusk.isNotEmpty) {
      parts.add('twilight $civilDawn / $civilDusk');
    }
    if (solarNoon.isNotEmpty) parts.add('solar noon $solarNoon');
    if (moonPhase.isNotEmpty) {
      final moon = moonIllumination > 0
          ? '$moonPhase $moonIllumination%'
          : moonPhase;
      parts.add('moon $moon');
    }
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() => {
    'astronomySunrise': sunrise,
    'astronomySunset': sunset,
    'astronomyCivilDawn': civilDawn,
    'astronomyCivilDusk': civilDusk,
    'astronomySolarNoon': solarNoon,
    'astronomyMoonPhase': moonPhase,
    'astronomyMoonIllumination': moonIllumination,
  };

  factory AstronomyInfo.fromJson(Map<String, dynamic> json) {
    int readInt(String key) => int.tryParse(json[key]?.toString() ?? '') ?? 0;
    return AstronomyInfo(
      sunrise: json['astronomySunrise']?.toString() ?? '',
      sunset: json['astronomySunset']?.toString() ?? '',
      civilDawn: json['astronomyCivilDawn']?.toString() ?? '',
      civilDusk: json['astronomyCivilDusk']?.toString() ?? '',
      solarNoon: json['astronomySolarNoon']?.toString() ?? '',
      moonPhase: json['astronomyMoonPhase']?.toString() ?? '',
      moonIllumination: readInt('astronomyMoonIllumination'),
    );
  }

  AstronomyInfo copyWith({
    String? sunrise,
    String? sunset,
    String? civilDawn,
    String? civilDusk,
    String? solarNoon,
    String? moonPhase,
    int? moonIllumination,
  }) {
    return AstronomyInfo(
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      civilDawn: civilDawn ?? this.civilDawn,
      civilDusk: civilDusk ?? this.civilDusk,
      solarNoon: solarNoon ?? this.solarNoon,
      moonPhase: moonPhase ?? this.moonPhase,
      moonIllumination: moonIllumination ?? this.moonIllumination,
    );
  }
}
