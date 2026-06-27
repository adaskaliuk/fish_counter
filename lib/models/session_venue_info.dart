import 'package:fish_counter/utils/type_utils.dart';

/// Venue and location information for a game session.
class SessionVenueInfo {
  final String venue;
  final String sectorPeg;
  final String trainingType;
  final String fishingMethod;
  final String targetPace;
  final String speciesPreset;
  final String bodyTypePreset;
  final String conditions;
  final String baitNotes;

  const SessionVenueInfo({
    this.venue = '',
    this.sectorPeg = '',
    this.trainingType = '',
    this.fishingMethod = '',
    this.targetPace = '',
    this.speciesPreset = '',
    this.bodyTypePreset = '',
    this.conditions = '',
    this.baitNotes = '',
  });

  Map<String, dynamic> toJson() => {
    'venue': venue,
    'sectorPeg': sectorPeg,
    'trainingType': trainingType,
    'fishingMethod': fishingMethod,
    'targetPace': targetPace,
    'speciesPreset': speciesPreset,
    'bodyTypePreset': bodyTypePreset,
    'conditions': conditions,
    'baitNotes': baitNotes,
  };

  factory SessionVenueInfo.fromJson(Map<String, dynamic> json) {
    return SessionVenueInfo(
      venue: TypeUtils.safeString(json['venue']),
      sectorPeg: TypeUtils.safeString(json['sectorPeg']),
      trainingType: TypeUtils.safeString(json['trainingType']),
      fishingMethod: TypeUtils.safeString(json['fishingMethod']),
      targetPace: TypeUtils.safeString(json['targetPace']),
      speciesPreset: TypeUtils.safeString(json['speciesPreset']),
      bodyTypePreset: TypeUtils.safeString(json['bodyTypePreset']),
      conditions: TypeUtils.safeString(json['conditions']),
      baitNotes: TypeUtils.safeString(json['baitNotes']),
    );
  }

  SessionVenueInfo copyWith({
    String? venue,
    String? sectorPeg,
    String? trainingType,
    String? fishingMethod,
    String? targetPace,
    String? speciesPreset,
    String? bodyTypePreset,
    String? conditions,
    String? baitNotes,
  }) {
    return SessionVenueInfo(
      venue: venue ?? this.venue,
      sectorPeg: sectorPeg ?? this.sectorPeg,
      trainingType: trainingType ?? this.trainingType,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      targetPace: targetPace ?? this.targetPace,
      speciesPreset: speciesPreset ?? this.speciesPreset,
      bodyTypePreset: bodyTypePreset ?? this.bodyTypePreset,
      conditions: conditions ?? this.conditions,
      baitNotes: baitNotes ?? this.baitNotes,
    );
  }
}
