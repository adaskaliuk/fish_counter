part of 'clicker_screen.dart';

abstract final class SettingsDialogKeys {
  static const actionDelayKey = ValueKey('settings_action_delay');
  static const vibeIntervalKey = ValueKey('settings_vibe_interval');
  static const saveButtonKey = ValueKey('settings_save_button');
}

Future<void> _showSettingsDialog(_ClickerScreenState state) async {
  final l10n = AppLocalizations.of(state.context);
  final repo = state._prefsRepository;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final profile =
      repo?.loadAthleteProfile(userId: userId) ?? const AthleteProfile();

  final dialogContext = state.context;
  if (!dialogContext.mounted) return;

  await showDialog(
    context: dialogContext,
    builder: (_) => _SettingsDialogBody(
      state: state,
      repo: repo,
      l10n: l10n,
      profile: profile,
    ),
  );
}

class _SettingsDialogBody extends StatefulWidget {
  const _SettingsDialogBody({
    required this.state,
    required this.l10n,
    required this.repo,
    required this.profile,
  });

  final _ClickerScreenState state;
  final PrefsRepository? repo;
  final AppLocalizations l10n;
  final AthleteProfile profile;

  @override
  State<_SettingsDialogBody> createState() => _SettingsDialogBodyState();
}

class _SettingsDialogBodyState extends State<_SettingsDialogBody> {
  late final TextEditingController _rCtrl;
  late final TextEditingController _vCtrl;
  late final TextEditingController _dCtrl;
  late final TextEditingController _hCtrl;
  late final TextEditingController _mCtrl;
  late final TextEditingController _athleteCtrl;
  late final TextEditingController _coachCtrl;
  late final TextEditingController _clubCtrl;
  late final TextEditingController _venueCtrl;
  late final TextEditingController _sectorCtrl;
  late final TextEditingController _trainingCtrl;
  late final TextEditingController _methodCtrl;
  late final TextEditingController _paceCtrl;

  var _dialogSyncHistoryEnabled = false;
  var _dialogShakeUndoEnabled = false;
  var _dialogShakeSensitivity = ShakeSensitivity.medium;
  var _dialogSpeciesPreset = FishingPresets.defaultSpecies;
  var _dialogBodyTypePreset = FishingPresets.defaultBodyType;
  var _dialogRole = 'athlete';

  @override
  void initState() {
    super.initState();
    final state = widget.state;
    _rCtrl = TextEditingController(text: state.resetDelay.toString());
    _vCtrl = TextEditingController(text: state.vibeInterval.toString());
    _dCtrl = TextEditingController(text: state.matchInterval.inDays.toString());
    _hCtrl = TextEditingController(
      text: (state.matchInterval.inHours % 24).toString(),
    );
    _mCtrl = TextEditingController(
      text: (state.matchInterval.inMinutes % 60).toString(),
    );
    _dialogSyncHistoryEnabled = state.isSyncHistoryEnabled;
    _dialogShakeUndoEnabled = state.isShakeUndoEnabled;
    _dialogShakeSensitivity = state.shakeSensitivity;
    _dialogRole = widget.profile.isCoach ? 'coach' : 'athlete';

    _athleteCtrl = TextEditingController();
    _coachCtrl = TextEditingController();
    _clubCtrl = TextEditingController();
    _venueCtrl = TextEditingController();
    _sectorCtrl = TextEditingController();
    _trainingCtrl = TextEditingController();
    _methodCtrl = TextEditingController();
    _paceCtrl = TextEditingController();

    _athleteCtrl.text = widget.profile.athleteName;
    _coachCtrl.text = widget.profile.coachName;
    _clubCtrl.text = widget.profile.clubTeam;
    _venueCtrl.text = widget.profile.defaultVenue;
    _sectorCtrl.text = widget.profile.defaultSectorPeg;
    _trainingCtrl.text = widget.profile.defaultTrainingType;
    _methodCtrl.text = widget.profile.defaultFishingMethod;
    _paceCtrl.text = widget.profile.defaultTargetPace;
    _dialogSpeciesPreset = widget.profile.defaultSpeciesPreset.isEmpty
        ? FishingPresets.defaultSpecies
        : widget.profile.defaultSpeciesPreset;
    _dialogBodyTypePreset = widget.profile.defaultBodyTypePreset.isEmpty
        ? FishingPresets.defaultBodyType
        : widget.profile.defaultBodyTypePreset;
  }

  @override
  void dispose() {
    _rCtrl.dispose();
    _vCtrl.dispose();
    _dCtrl.dispose();
    _hCtrl.dispose();
    _mCtrl.dispose();
    _athleteCtrl.dispose();
    _coachCtrl.dispose();
    _clubCtrl.dispose();
    _venueCtrl.dispose();
    _sectorCtrl.dispose();
    _trainingCtrl.dispose();
    _methodCtrl.dispose();
    _paceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.settingsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: SettingsDialogKeys.actionDelayKey,
              controller: _rCtrl,
              decoration: InputDecoration(labelText: l10n.actionDelay),
              keyboardType: TextInputType.number,
            ),
            TextField(
              key: SettingsDialogKeys.vibeIntervalKey,
              controller: _vCtrl,
              decoration: InputDecoration(labelText: l10n.vibeInterval),
              keyboardType: TextInputType.number,
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.syncHistory),
              subtitle: Text(l10n.syncHistoryDescription),
              value: _dialogSyncHistoryEnabled,
              onChanged: (value) =>
                  setState(() => _dialogSyncHistoryEnabled = value),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.shakeUndo),
              value: _dialogShakeUndoEnabled,
              onChanged: (value) =>
                  setState(() => _dialogShakeUndoEnabled = value),
            ),
            DropdownButtonFormField<ShakeSensitivity>(
              initialValue: _dialogShakeSensitivity,
              decoration: InputDecoration(labelText: l10n.shakeSensitivity),
              items: ShakeSensitivity.values
                  .map(
                    (sensitivity) => DropdownMenuItem(
                      value: sensitivity,
                      child: Text(shakeSensitivityLabel(l10n, sensitivity)),
                    ),
                  )
                  .toList(),
              onChanged: _dialogShakeUndoEnabled
                  ? (value) {
                      if (value == null) return;
                      setState(() => _dialogShakeSensitivity = value);
                    }
                  : null,
            ),
            const Divider(),
            Text(l10n.athleteProfile),
            DropdownButtonFormField<String>(
              initialValue: _dialogRole,
              decoration: InputDecoration(labelText: l10n.roleLabel),
              items: [
                DropdownMenuItem(
                  value: 'athlete',
                  child: Text(l10n.roleAthlete),
                ),
                DropdownMenuItem(value: 'coach', child: Text(l10n.roleCoach)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _dialogRole = value);
              },
            ),
            TextField(
              controller: _athleteCtrl,
              decoration: InputDecoration(labelText: l10n.athleteName),
            ),
            if (_dialogRole == 'coach') ...[
              TextField(
                controller: _coachCtrl,
                decoration: InputDecoration(labelText: l10n.coachName),
              ),
              TextField(
                controller: _clubCtrl,
                decoration: InputDecoration(labelText: l10n.clubTeam),
              ),
              TextField(
                controller: _trainingCtrl,
                decoration: InputDecoration(labelText: l10n.trainingType),
              ),
              TextField(
                controller: _methodCtrl,
                decoration: InputDecoration(labelText: l10n.fishingMethod),
              ),
            ],
            TextField(
              controller: _venueCtrl,
              decoration: InputDecoration(labelText: l10n.venue),
            ),
            TextField(
              controller: _sectorCtrl,
              decoration: InputDecoration(labelText: l10n.sectorPeg),
            ),
            TextField(
              controller: _paceCtrl,
              decoration: InputDecoration(labelText: l10n.targetPace),
            ),
            DropdownButtonFormField<String>(
              initialValue: _dialogSpeciesPreset,
              decoration: InputDecoration(labelText: l10n.speciesPreset),
              items: [
                DropdownMenuItem(
                  value: FishingPresets.defaultSpecies,
                  child: Text(l10n.presetNone),
                ),
                DropdownMenuItem(
                  value: FishingPresets.speciesCarp,
                  child: Text(l10n.speciesCarp),
                ),
                DropdownMenuItem(
                  value: FishingPresets.speciesBream,
                  child: Text(l10n.speciesBream),
                ),
                DropdownMenuItem(
                  value: FishingPresets.speciesRoach,
                  child: Text(l10n.speciesRoach),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _dialogSpeciesPreset = value);
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _dialogBodyTypePreset,
              decoration: InputDecoration(labelText: l10n.bodyTypePreset),
              items: [
                DropdownMenuItem(
                  value: FishingPresets.defaultBodyType,
                  child: Text(l10n.presetNone),
                ),
                DropdownMenuItem(
                  value: FishingPresets.bodyStocky,
                  child: Text(l10n.bodyStocky),
                ),
                DropdownMenuItem(
                  value: FishingPresets.bodyBalanced,
                  child: Text(l10n.bodyBalanced),
                ),
                DropdownMenuItem(
                  value: FishingPresets.bodySlim,
                  child: Text(l10n.bodySlim),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _dialogBodyTypePreset = value);
              },
            ),
            const Divider(),
            Text(l10n.matchDuration),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dCtrl,
                    decoration: InputDecoration(labelText: l10n.days),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _hCtrl,
                    decoration: InputDecoration(labelText: l10n.hours),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _mCtrl,
                    decoration: InputDecoration(labelText: l10n.minutes),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          key: SettingsDialogKeys.saveButtonKey,
          onPressed: () async {
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final repo = widget.repo ?? await PrefsRepository.create();
            final currentProfile = widget.profile;
            final newResetDelay = parseStrictInt(_rCtrl.text, min: 0);
            final newVibeInterval = parseStrictInt(_vCtrl.text, min: 1);
            final newMatchInterval = parseStrictDuration(
              _dCtrl.text,
              _hCtrl.text,
              _mCtrl.text,
            );

            if (newResetDelay == null ||
                newVibeInterval == null ||
                newMatchInterval == null) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.errorSavingSession)),
              );
              return;
            }
            final newProfile = AthleteProfile(
              role: _dialogRole,
              athleteName: _athleteCtrl.text.trim(),
              coachName: _coachCtrl.text.trim(),
              clubTeam: _clubCtrl.text.trim(),
              defaultVenue: _venueCtrl.text.trim(),
              defaultSectorPeg: _sectorCtrl.text.trim(),
              defaultTrainingType: _trainingCtrl.text.trim(),
              defaultFishingMethod: _methodCtrl.text.trim(),
              defaultTargetPace: _paceCtrl.text.trim(),
              defaultSpeciesPreset: _dialogSpeciesPreset,
              defaultBodyTypePreset: _dialogBodyTypePreset,
            );
            final changed =
                newResetDelay != widget.state.resetDelay ||
                newVibeInterval != widget.state.vibeInterval ||
                newMatchInterval != widget.state.matchInterval ||
                _dialogSyncHistoryEnabled !=
                    widget.state.isSyncHistoryEnabled ||
                _dialogShakeUndoEnabled != widget.state.isShakeUndoEnabled ||
                _dialogShakeSensitivity != widget.state.shakeSensitivity ||
                newProfile.toJson().toString() !=
                    currentProfile.toJson().toString();

            if (!changed) {
              navigator.pop();
              return;
            }

            if (!context.mounted) return;
            final shouldSave = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (confirmContext) => AlertDialog(
                title: Text(l10n.saveSettingsQuestion),
                content: Text(l10n.saveSettingsWarning),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(confirmContext).pop(false),
                    child: Text(l10n.dontSave),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(confirmContext).pop(true),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            );

            if (shouldSave == false) {
              navigator.pop();
              return;
            }
            if (shouldSave != true) return;

            await widget.state._ensureProvider();
            widget.state._applySettings(
              resetDelay: newResetDelay,
              vibeInterval: newVibeInterval,
              matchInterval: newMatchInterval,
              syncHistoryEnabled: _dialogSyncHistoryEnabled,
              shakeUndoEnabled: _dialogShakeUndoEnabled,
              shakeSensitivity: _dialogShakeSensitivity,
            );
            await widget.state._saveData();
            await repo.saveAthleteProfile(
              newProfile,
              userId: FirebaseAuth.instance.currentUser?.uid,
            );
            await repo.touchSettingsUpdatedAt();
            try {
              await CloudSettingsService().uploadLocalSettings(repo);
            } catch (_) {
              debugPrint('Settings sync failed');
            }
            if (widget.state.isSyncHistoryEnabled) {
              try {
                await CloudHistoryService().syncLocalAndRemote(repo);
              } catch (_) {
                debugPrint('History sync failed');
              }
            }
            await widget.state._refreshSyncState(repo);
            navigator.pop();
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

String shakeSensitivityLabel(
  AppLocalizations l10n,
  ShakeSensitivity sensitivity,
) {
  switch (sensitivity) {
    case ShakeSensitivity.low:
      return l10n.shakeSensitivityLow;
    case ShakeSensitivity.medium:
      return l10n.shakeSensitivityMedium;
    case ShakeSensitivity.high:
      return l10n.shakeSensitivityHigh;
  }
}

int? parseStrictInt(String value, {required int min}) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < min) return null;
  return parsed;
}

Duration? parseStrictDuration(String days, String hours, String minutes) {
  final parsedDays = parseStrictInt(days, min: 0);
  final parsedHours = parseStrictInt(hours, min: 0);
  final parsedMinutes = parseStrictInt(minutes, min: 0);
  if (parsedDays == null || parsedHours == null || parsedMinutes == null) {
    return null;
  }
  if (parsedHours >= 24 || parsedMinutes >= 60) {
    return null;
  }

  final duration = Duration(
    days: parsedDays,
    hours: parsedHours,
    minutes: parsedMinutes,
  );
  return duration.inSeconds > 0 ? duration : null;
}
