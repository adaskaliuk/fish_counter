class AthleteProfile {
  const AthleteProfile({
    this.athleteName = '',
    this.coachName = '',
    this.clubTeam = '',
    this.defaultVenue = '',
    this.defaultSectorPeg = '',
    this.defaultTrainingType = '',
    this.defaultFishingMethod = '',
    this.defaultTargetPace = '',
  });

  final String athleteName;
  final String coachName;
  final String clubTeam;
  final String defaultVenue;
  final String defaultSectorPeg;
  final String defaultTrainingType;
  final String defaultFishingMethod;
  final String defaultTargetPace;

  Map<String, dynamic> toJson() => {
    'athleteName': athleteName,
    'coachName': coachName,
    'clubTeam': clubTeam,
    'defaultVenue': defaultVenue,
    'defaultSectorPeg': defaultSectorPeg,
    'defaultTrainingType': defaultTrainingType,
    'defaultFishingMethod': defaultFishingMethod,
    'defaultTargetPace': defaultTargetPace,
  };

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString() ?? '';
    return AthleteProfile(
      athleteName: read('athleteName'),
      coachName: read('coachName'),
      clubTeam: read('clubTeam'),
      defaultVenue: read('defaultVenue'),
      defaultSectorPeg: read('defaultSectorPeg'),
      defaultTrainingType: read('defaultTrainingType'),
      defaultFishingMethod: read('defaultFishingMethod'),
      defaultTargetPace: read('defaultTargetPace'),
    );
  }
}
