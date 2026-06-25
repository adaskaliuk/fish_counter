part of 'clicker_screen.dart';

Future<void> _showSettingsDialog(_ClickerScreenState state) async {
  final l10n = AppLocalizations.of(state.context);
  final repoFuture = PrefsRepository.create();
  final rCtrl = TextEditingController(text: state.resetDelay.toString());
  final vCtrl = TextEditingController(text: state.vibeInterval.toString());
  final dCtrl = TextEditingController(
    text: state.matchInterval.inDays.toString(),
  );
  final hCtrl = TextEditingController(
    text: (state.matchInterval.inHours % 24).toString(),
  );
  final mCtrl = TextEditingController(
    text: (state.matchInterval.inMinutes % 60).toString(),
  );
  var dialogSyncHistoryEnabled = state.isSyncHistoryEnabled;
  var dialogShakeUndoEnabled = state.isShakeUndoEnabled;
  var dialogShakeSensitivity = state.shakeSensitivity;
  final athleteCtrl = TextEditingController();
  final coachCtrl = TextEditingController();
  final clubCtrl = TextEditingController();
  final venueCtrl = TextEditingController();
  final sectorCtrl = TextEditingController();
  final trainingCtrl = TextEditingController();
  final methodCtrl = TextEditingController();
  final paceCtrl = TextEditingController();
  final dialogContext = state.context;

  try {
    final repo = await repoFuture;
    final profile = repo.loadAthleteProfile();
    athleteCtrl.text = profile.athleteName;
    coachCtrl.text = profile.coachName;
    clubCtrl.text = profile.clubTeam;
    venueCtrl.text = profile.defaultVenue;
    sectorCtrl.text = profile.defaultSectorPeg;
    trainingCtrl.text = profile.defaultTrainingType;
    methodCtrl.text = profile.defaultFishingMethod;
    paceCtrl.text = profile.defaultTargetPace;

    if (!dialogContext.mounted) return;

    await showDialog(
    context: dialogContext,
    builder: (c) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.settingsTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rCtrl,
                decoration: InputDecoration(labelText: l10n.actionDelay),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: vCtrl,
                decoration: InputDecoration(labelText: l10n.vibeInterval),
                keyboardType: TextInputType.number,
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.syncHistory),
                subtitle: Text(l10n.syncHistoryDescription),
                value: dialogSyncHistoryEnabled,
                onChanged: (value) {
                  setDialogState(() => dialogSyncHistoryEnabled = value);
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shakeUndo),
                value: dialogShakeUndoEnabled,
                onChanged: (value) {
                  setDialogState(() => dialogShakeUndoEnabled = value);
                },
              ),
              DropdownButtonFormField<ShakeSensitivity>(
                initialValue: dialogShakeSensitivity,
                decoration: InputDecoration(labelText: l10n.shakeSensitivity),
                items: ShakeSensitivity.values
                    .map(
                      (sensitivity) => DropdownMenuItem(
                        value: sensitivity,
                        child: Text(shakeSensitivityLabel(l10n, sensitivity)),
                      ),
                    )
                    .toList(),
                onChanged: dialogShakeUndoEnabled
                    ? (value) {
                        if (value == null) return;
                        setDialogState(() => dialogShakeSensitivity = value);
                      }
                    : null,
              ),
              const Divider(),
              Text(l10n.athleteProfile),
              TextField(
                controller: athleteCtrl,
                decoration: InputDecoration(labelText: l10n.athleteName),
              ),
              TextField(
                controller: coachCtrl,
                decoration: InputDecoration(labelText: l10n.coachName),
              ),
              TextField(
                controller: clubCtrl,
                decoration: InputDecoration(labelText: l10n.clubTeam),
              ),
              TextField(
                controller: venueCtrl,
                decoration: InputDecoration(labelText: l10n.venue),
              ),
              TextField(
                controller: sectorCtrl,
                decoration: InputDecoration(labelText: l10n.sectorPeg),
              ),
              TextField(
                controller: trainingCtrl,
                decoration: InputDecoration(labelText: l10n.trainingType),
              ),
              TextField(
                controller: methodCtrl,
                decoration: InputDecoration(labelText: l10n.fishingMethod),
              ),
              TextField(
                controller: paceCtrl,
                decoration: InputDecoration(labelText: l10n.targetPace),
              ),
              const Divider(),
              Text(l10n.matchDuration),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dCtrl,
                      decoration: InputDecoration(labelText: l10n.days),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: hCtrl,
                      decoration: InputDecoration(labelText: l10n.hours),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: mCtrl,
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
            onPressed: () async {
              final navigator = Navigator.of(c);
              final messenger = ScaffoldMessenger.of(c);
              final repo = await repoFuture;
              final currentProfile = repo.loadAthleteProfile();
              final newResetDelay = parseStrictInt(rCtrl.text, min: 0);
              final newVibeInterval = parseStrictInt(vCtrl.text, min: 1);
              final newMatchInterval = parseStrictDuration(
                dCtrl.text,
                hCtrl.text,
                mCtrl.text,
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
                athleteName: athleteCtrl.text.trim(),
                coachName: coachCtrl.text.trim(),
                clubTeam: clubCtrl.text.trim(),
                defaultVenue: venueCtrl.text.trim(),
                defaultSectorPeg: sectorCtrl.text.trim(),
                defaultTrainingType: trainingCtrl.text.trim(),
                defaultFishingMethod: methodCtrl.text.trim(),
                defaultTargetPace: paceCtrl.text.trim(),
              );
              final changed =
                  newResetDelay != state.resetDelay ||
                  newVibeInterval != state.vibeInterval ||
                  newMatchInterval != state.matchInterval ||
                  dialogSyncHistoryEnabled != state.isSyncHistoryEnabled ||
                  dialogShakeUndoEnabled != state.isShakeUndoEnabled ||
                  dialogShakeSensitivity != state.shakeSensitivity ||
                  newProfile.toJson().toString() !=
                      currentProfile.toJson().toString();

              if (!changed) {
                navigator.pop();
                return;
              }

              if (!c.mounted) return;
              final shouldSave = await showDialog<bool>(
                context: c,
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

              state._applySettings(
                resetDelay: newResetDelay,
                vibeInterval: newVibeInterval,
                matchInterval: newMatchInterval,
                syncHistoryEnabled: dialogSyncHistoryEnabled,
                shakeUndoEnabled: dialogShakeUndoEnabled,
                shakeSensitivity: dialogShakeSensitivity,
              );
              await state._saveData();
              await repo.saveAthleteProfile(newProfile);
              await repo.touchSettingsUpdatedAt();
              try {
                await CloudSettingsService().uploadLocalSettings(repo);
              } catch (e) {
                debugPrint('Error syncing settings: $e');
              }
              if (state.isSyncHistoryEnabled) {
                try {
                  await CloudHistoryService().syncLocalAndRemote(repo);
                } catch (e) {
                  debugPrint('Error syncing history: $e');
                }
              }
              navigator.pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
    );
  } finally {
    rCtrl.dispose();
    vCtrl.dispose();
    dCtrl.dispose();
    hCtrl.dispose();
    mCtrl.dispose();
    athleteCtrl.dispose();
    coachCtrl.dispose();
    clubCtrl.dispose();
    venueCtrl.dispose();
    sectorCtrl.dispose();
    trainingCtrl.dispose();
    methodCtrl.dispose();
    paceCtrl.dispose();
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
