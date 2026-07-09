import 'package:fish_counter/models/athlete_profile.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'storage_test_utils.dart';

void main() {
  test('AthleteProfile serializes defaults', () {
    const profile = AthleteProfile(
      role: 'coach',
      athleteName: 'Athlete',
      coachName: 'Coach',
      clubTeam: 'Club',
      defaultVenue: 'Lake',
      defaultSectorPeg: 'A1',
      defaultTrainingType: 'Pace',
      defaultFishingMethod: 'Feeder',
      defaultTargetPace: '60s',
    );

    final parsed = AthleteProfile.fromJson(profile.toJson());

    expect(parsed.role, 'coach');
    expect(parsed.athleteName, 'Athlete');
    expect(parsed.clubTeam, 'Club');
    expect(parsed.defaultFishingMethod, 'Feeder');
  });

  test('PrefsRepository saves and loads athlete profile', () async {
    await useMemoryStorage();
    addTearDown(resetMemoryStorage);
    final repo = await PrefsRepository.create();

    await repo.saveAthleteProfile(const AthleteProfile(role: 'coach', athleteName: 'A'));

    expect(repo.loadAthleteProfile().role, 'coach');
    expect(repo.loadAthleteProfile().athleteName, 'A');
  });
}
