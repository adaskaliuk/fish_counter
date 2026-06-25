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

Future<void> _handlePowerPress(_ClickerScreenState state) async {
  if (!state.isPowerOn) {
    state._applyPowerState(ClickerController.turnPowerOn());
    await state._saveData();
    return;
  }

  final l10n = AppLocalizations.of(state.context);
  final profile = (await PrefsRepository.create()).loadAthleteProfile();
  final nameCtrl = TextEditingController(
    text:
        '${l10n.sessionDefaultName} ${DateFormat('HH:mm').format(DateTime.now())}',
  );
  final athleteNameCtrl = TextEditingController(text: profile.athleteName);
  final coachNameCtrl = TextEditingController(text: profile.coachName);
  final venueCtrl = TextEditingController(text: profile.defaultVenue);
  final sectorPegCtrl = TextEditingController(text: profile.defaultSectorPeg);
  final trainingTypeCtrl = TextEditingController(
    text: profile.defaultTrainingType,
  );
  final fishingMethodCtrl = TextEditingController(
    text: profile.defaultFishingMethod,
  );
  final targetPaceCtrl = TextEditingController(text: profile.defaultTargetPace);
  final goalFishCtrl = TextEditingController(text: '0');
  final goalPaceCtrl = TextEditingController(text: '0');
  final goalTriesCtrl = TextEditingController(text: '0');
  final goalStabilityCtrl = TextEditingController(text: '0');
  final conditionsCtrl = TextEditingController();
  final baitNotesCtrl = TextEditingController();
  WeatherSnapshot? weatherSnapshot;
  var isLoadingWeather = false;
  final athleteNoteCtrl = TextEditingController();
  final coachCommentCtrl = TextEditingController();

  if (!state.mounted) return;

  await showDialog(
    context: state.context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.saveSessionTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl),
              const SizedBox(height: 8),
              Text(l10n.trainingContext),
              TextField(
                controller: athleteNameCtrl,
                decoration: InputDecoration(labelText: l10n.athleteName),
              ),
              TextField(
                controller: coachNameCtrl,
                decoration: InputDecoration(labelText: l10n.coachName),
              ),
              TextField(
                controller: venueCtrl,
                decoration: InputDecoration(labelText: l10n.venue),
              ),
              TextField(
                controller: sectorPegCtrl,
                decoration: InputDecoration(labelText: l10n.sectorPeg),
              ),
              TextField(
                controller: trainingTypeCtrl,
                decoration: InputDecoration(labelText: l10n.trainingType),
              ),
              TextField(
                controller: fishingMethodCtrl,
                decoration: InputDecoration(labelText: l10n.fishingMethod),
              ),
              TextField(
                controller: targetPaceCtrl,
                decoration: InputDecoration(labelText: l10n.targetPace),
              ),
              const Divider(),
              Text(l10n.trainingGoals),
              TextField(
                controller: goalFishCtrl,
                decoration: InputDecoration(labelText: l10n.targetFishCount),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: goalPaceCtrl,
                decoration: InputDecoration(labelText: l10n.targetPaceSeconds),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: goalTriesCtrl,
                decoration: InputDecoration(labelText: l10n.maxTries),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: goalStabilityCtrl,
                decoration: InputDecoration(labelText: l10n.stabilityTarget),
                keyboardType: TextInputType.number,
              ),
              const Divider(),
              TextField(
                controller: conditionsCtrl,
                decoration: InputDecoration(labelText: l10n.conditions),
                minLines: 1,
                maxLines: 2,
              ),
              TextField(
                controller: baitNotesCtrl,
                decoration: InputDecoration(labelText: l10n.baitNotes),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isLoadingWeather
                    ? null
                    : () async {
                        setDialogState(() => isLoadingWeather = true);
                        try {
                          final snapshot = await SessionWeatherService()
                              .fetchCurrentWeather();
                          if (!state.mounted) return;
                          setDialogState(() => weatherSnapshot = snapshot);
                        } catch (e) {
                          debugPrint('Weather load error: $e');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l10n.weatherLoadFailed}: $e'),
                            ),
                          );
                        } finally {
                          if (state.mounted) {
                            setDialogState(() => isLoadingWeather = false);
                          }
                        }
                      },
                icon: isLoadingWeather
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud),
                label: Text(l10n.autoFillWeather),
              ),
              if (weatherSnapshot != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${l10n.weatherSummary}: ${weatherSnapshot!.summary}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const Divider(),
              TextField(
                controller: athleteNoteCtrl,
                decoration: InputDecoration(labelText: l10n.athleteNote),
                minLines: 1,
                maxLines: 3,
              ),
              TextField(
                controller: coachCommentCtrl,
                decoration: InputDecoration(labelText: l10n.coachComment),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              state._countdownTimer?.cancel();
              state._applyPowerState(
                ClickerController.turnPowerOffWithoutSaving(),
              );
              await state._saveData();
            },
            child: Text(l10n.off),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              Object? syncError;

              try {
                final repo = await PrefsRepository.create();
                final user = FirebaseAuth.instance.currentUser;
                final goalFishCount = parseStrictInt(goalFishCtrl.text.trim(), min: 0);
                final goalTargetPaceSeconds = parseStrictInt(
                  goalPaceCtrl.text.trim(),
                  min: 0,
                );
                final goalMaxTries = parseStrictInt(
                  goalTriesCtrl.text.trim(),
                  min: 0,
                );
                final goalStabilityPercent = parseStrictInt(
                  goalStabilityCtrl.text.trim(),
                  min: 0,
                );

                if (goalFishCount == null ||
                    goalTargetPaceSeconds == null ||
                    goalMaxTries == null ||
                    goalStabilityPercent == null) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.errorSavingSession)),
                  );
                  return;
                }

                final session = ClickerController.buildSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  date: DateFormat('dd.MM.yy HH:mm').format(DateTime.now()),
                  counter1: state.counter1,
                  counter2: state.counter2,
                  tries: state.tries,
                  total: state.total,
                  matchInterval: state.matchInterval,
                  activityGrid: state.activityGrid,
                  userId: user?.uid ?? '',
                  userEmail: user?.email ?? '',
                  userDisplayName: user?.displayName ?? '',
                  athleteName: athleteNameCtrl.text,
                  coachName: coachNameCtrl.text,
                  venue: venueCtrl.text,
                  sectorPeg: sectorPegCtrl.text,
                  trainingType: trainingTypeCtrl.text,
                  fishingMethod: fishingMethodCtrl.text,
                  targetPace: targetPaceCtrl.text,
                  goalFishCount: goalFishCount,
                  goalTargetPaceSeconds: goalTargetPaceSeconds,
                  goalMaxTries: goalMaxTries,
                  goalStabilityPercent: goalStabilityPercent,
                  conditions: conditionsCtrl.text,
                  baitNotes: baitNotesCtrl.text,
                  weather: weatherSnapshot,
                  athleteNote: athleteNoteCtrl.text,
                  coachComment: coachCommentCtrl.text,
                );

                await repo.addHistorySession(session);
                if (state.isSyncHistoryEnabled) {
                  try {
                    await CloudHistoryService().uploadSession(session);
                  } catch (e) {
                    syncError = e;
                    debugPrint('Cloud history sync error: $e');
                  }
                }

                if (!state.mounted) return;

                state._countdownTimer?.cancel();
                state._applyPowerState(
                  ClickerController.resetAfterSessionSaved(),
                );

                await state._saveData();

                if (!state.mounted) return;
                navigator.pop();
                if (syncError != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.sessionSavedCloudFailed}: $syncError',
                      ),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error saving session: $e');
                if (!state.mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text('${l10n.errorSavingSession}: $e')),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );

  nameCtrl.dispose();
  athleteNameCtrl.dispose();
  coachNameCtrl.dispose();
  venueCtrl.dispose();
  sectorPegCtrl.dispose();
  trainingTypeCtrl.dispose();
  fishingMethodCtrl.dispose();
  targetPaceCtrl.dispose();
  goalFishCtrl.dispose();
  goalPaceCtrl.dispose();
  goalTriesCtrl.dispose();
  goalStabilityCtrl.dispose();
  conditionsCtrl.dispose();
  baitNotesCtrl.dispose();
  athleteNoteCtrl.dispose();
  coachCommentCtrl.dispose();
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
