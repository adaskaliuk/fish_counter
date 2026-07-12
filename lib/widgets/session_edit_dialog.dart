import 'package:fish_counter/game_session.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SessionEditDialog extends StatefulWidget {
  final GameSession session;
  final bool isCoach;

  const SessionEditDialog({
    super.key,
    required this.session,
    this.isCoach = false,
  });

  @override
  State<SessionEditDialog> createState() => _SessionEditDialogState();

  static Future<GameSession?> show(
    BuildContext context,
    GameSession session, {
    bool isCoach = false,
  }) {
    return showDialog<GameSession>(
      context: context,
      builder: (context) =>
          SessionEditDialog(session: session, isCoach: isCoach),
    );
  }
}

class _SessionEditDialogState extends State<SessionEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _athleteCtrl;
  late final TextEditingController _coachCtrl;
  late final TextEditingController _venueCtrl;
  late final TextEditingController _sectorCtrl;
  late final TextEditingController _trainingCtrl;
  late final TextEditingController _methodCtrl;
  late final TextEditingController _paceCtrl;
  late final TextEditingController _conditionsCtrl;
  late final TextEditingController _baitCtrl;
  late final TextEditingController _athleteNoteCtrl;
  late final TextEditingController _coachCommentCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.session.name);
    _athleteCtrl = TextEditingController(text: widget.session.athleteName);
    _coachCtrl = TextEditingController(text: widget.session.coachName);
    _venueCtrl = TextEditingController(text: widget.session.venueInfo.venue);
    _sectorCtrl = TextEditingController(
      text: widget.session.venueInfo.sectorPeg,
    );
    _trainingCtrl = TextEditingController(
      text: widget.session.venueInfo.trainingType,
    );
    _methodCtrl = TextEditingController(
      text: widget.session.venueInfo.fishingMethod,
    );
    _paceCtrl = TextEditingController(
      text: widget.session.venueInfo.targetPace,
    );
    _conditionsCtrl = TextEditingController(
      text: widget.session.venueInfo.conditions,
    );
    _baitCtrl = TextEditingController(text: widget.session.venueInfo.baitNotes);
    _athleteNoteCtrl = TextEditingController(text: widget.session.athleteNote);
    _coachCommentCtrl = TextEditingController(
      text: widget.session.coachComment,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _athleteCtrl.dispose();
    _coachCtrl.dispose();
    _venueCtrl.dispose();
    _sectorCtrl.dispose();
    _trainingCtrl.dispose();
    _methodCtrl.dispose();
    _paceCtrl.dispose();
    _conditionsCtrl.dispose();
    _baitCtrl.dispose();
    _athleteNoteCtrl.dispose();
    _coachCommentCtrl.dispose();
    super.dispose();
  }

  GameSession getUpdatedSession() {
    return widget.session.copyWith(
      name: _nameCtrl.text.trim().isEmpty
          ? widget.session.name
          : _nameCtrl.text.trim(),
      athleteName: _athleteCtrl.text.trim(),
      coachName: _coachCtrl.text.trim(),
      venueInfo: widget.session.venueInfo.copyWith(
        venue: _venueCtrl.text.trim(),
        sectorPeg: _sectorCtrl.text.trim(),
        trainingType: _trainingCtrl.text.trim(),
        fishingMethod: _methodCtrl.text.trim(),
        targetPace: _paceCtrl.text.trim(),
        conditions: _conditionsCtrl.text.trim(),
        baitNotes: _baitCtrl.text.trim(),
      ),
      athleteNote: _athleteNoteCtrl.text.trim(),
      coachComment: _coachCommentCtrl.text.trim(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editSession),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editField(l10n.sessionName, _nameCtrl),
            _editField(l10n.athleteName, _athleteCtrl),
            if (widget.isCoach) _editField(l10n.coachName, _coachCtrl),
            _editField(l10n.venue, _venueCtrl),
            _editField(l10n.sectorPeg, _sectorCtrl),
            if (widget.isCoach) _editField(l10n.trainingType, _trainingCtrl),
            if (widget.isCoach) _editField(l10n.fishingMethod, _methodCtrl),
            _editField(l10n.targetPace, _paceCtrl),
            _editField(l10n.conditions, _conditionsCtrl),
            _editField(l10n.baitNotes, _baitCtrl),
            _editField(l10n.athleteNote, _athleteNoteCtrl, maxLines: 3),
            if (widget.isCoach)
              _editField(l10n.coachComment, _coachCommentCtrl, maxLines: 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(getUpdatedSession()),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _editField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
