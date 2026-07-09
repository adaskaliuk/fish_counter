import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('role localization strings exist for supported locales', () {
    final en = AppLocalizations(const Locale('en'));
    final uk = AppLocalizations(const Locale('uk'));

    expect(en.roleLabel, 'Role');
    expect(en.rolePlaceholder, 'Choose role');
    expect(en.roleAthlete, 'Athlete');
    expect(en.roleCoach, 'Coach');
    expect(en.roleRequired, 'Select a role');

    expect(uk.roleLabel, 'Роль');
    expect(uk.roleAthlete, 'Спортсмен');
    expect(uk.roleCoach, 'Тренер');
    expect(uk.roleRequired, 'Оберіть роль');
  });
}
