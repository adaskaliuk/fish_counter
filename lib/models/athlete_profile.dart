class AthleteProfile {
  const AthleteProfile({
    this.role = '',
    this.athleteName = '',
    this.coachName = '',
    this.clubTeam = '',
    this.defaultVenue = '',
    this.defaultSectorPeg = '',
    this.defaultTrainingType = '',
    this.defaultFishingMethod = '',
    this.defaultTargetPace = '',
    this.defaultSpeciesPreset = '',
    this.defaultBodyTypePreset = '',
  });

  final String role;
  final String athleteName;
  final String coachName;
  final String clubTeam;
  final String defaultVenue;
  final String defaultSectorPeg;
  final String defaultTrainingType;
  final String defaultFishingMethod;
  final String defaultTargetPace;
  final String defaultSpeciesPreset;
  final String defaultBodyTypePreset;

  bool get isCoach => role == 'coach';
  bool get isAthlete => role != 'coach';

  AthleteProfile copyWith({
    String? role,
    String? athleteName,
    String? coachName,
    String? clubTeam,
    String? defaultVenue,
    String? defaultSectorPeg,
    String? defaultTrainingType,
    String? defaultFishingMethod,
    String? defaultTargetPace,
    String? defaultSpeciesPreset,
    String? defaultBodyTypePreset,
  }) => AthleteProfile(
    role: role ?? this.role,
    athleteName: athleteName ?? this.athleteName,
    coachName: coachName ?? this.coachName,
    clubTeam: clubTeam ?? this.clubTeam,
    defaultVenue: defaultVenue ?? this.defaultVenue,
    defaultSectorPeg: defaultSectorPeg ?? this.defaultSectorPeg,
    defaultTrainingType: defaultTrainingType ?? this.defaultTrainingType,
    defaultFishingMethod: defaultFishingMethod ?? this.defaultFishingMethod,
    defaultTargetPace: defaultTargetPace ?? this.defaultTargetPace,
    defaultSpeciesPreset: defaultSpeciesPreset ?? this.defaultSpeciesPreset,
    defaultBodyTypePreset: defaultBodyTypePreset ?? this.defaultBodyTypePreset,
  );


  Map<String, dynamic> toJson() => {
    'role': role,
    'athleteName': athleteName,
    'coachName': coachName,
    'clubTeam': clubTeam,
    'defaultVenue': defaultVenue,
    'defaultSectorPeg': defaultSectorPeg,
    'defaultTrainingType': defaultTrainingType,
    'defaultFishingMethod': defaultFishingMethod,
    'defaultTargetPace': defaultTargetPace,
    'defaultSpeciesPreset': defaultSpeciesPreset,
    'defaultBodyTypePreset': defaultBodyTypePreset,
  };

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString() ?? '';
    return AthleteProfile(
      role: read('role'),
      athleteName: read('athleteName'),
      coachName: read('coachName'),
      clubTeam: read('clubTeam'),
      defaultVenue: read('defaultVenue'),
      defaultSectorPeg: read('defaultSectorPeg'),
      defaultTrainingType: read('defaultTrainingType'),
      defaultFishingMethod: read('defaultFishingMethod'),
      defaultTargetPace: read('defaultTargetPace'),
      defaultSpeciesPreset: read('defaultSpeciesPreset'),
      defaultBodyTypePreset: read('defaultBodyTypePreset'),
    );
  }
}
