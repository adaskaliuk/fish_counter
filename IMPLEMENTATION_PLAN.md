# Fish Counter Implementation Plan

## Product Focus

Fish Counter is a training and competition support app for sport anglers, athletes, and coaches. The goal is to help users count actions, control pace, review rhythm stability, and analyze training sessions.

## Current Status

Completed:

- Flutter project builds successfully for Web and iOS.
- `flutter analyze` passes with no issues.
- iOS CocoaPods leftovers were removed and the project builds with Swift Package Manager.
- SharedPreferences keys were unified.
- Settings are available before the session starts.
- Localization support was added for:
  - English
  - German
  - French
  - Polish
  - Italian
  - Dutch
  - Romanian
  - Ukrainian
- Undo was added through:
  - UI button
  - phone shake gesture

## Next Implementation Steps

### 1. Field Test on iPhone

Goal: validate the current MVP in real fishing/training conditions.

Checklist:

- Test button size and placement with one hand.
- Test visibility outdoors and in sunlight.
- Test vibration feedback strength.
- Test action delay behavior.
- Test session start/pause/save flow.
- Test history and analytics flow.
- Test accidental taps.
- Test shake undo reliability.
- Check whether shake undo triggers accidentally during normal handling.

Expected outcome:

- List of UX issues from real usage.
- Decision on whether button layout needs changes.
- Decision on shake undo sensitivity defaults.

---

### 2. Shake Undo Settings

Goal: make shake undo safe for field usage.

Add to Settings:

- Shake Undo: On/Off
- Shake Sensitivity:
  - Low
  - Medium
  - High

Recommended defaults:

- Shake Undo: On
- Sensitivity: Medium
- Cooldown: 1500 ms

Implementation notes:

- Store settings in SharedPreferences.
- Disable accelerometer listener if Shake Undo is off.
- Map sensitivity to acceleration thresholds.
- Keep UI undo always available regardless of shake setting.

---

### 3. Notes / Coach Comment

Goal: turn session history into a training journal.

Add fields to saved session:

- Athlete note
- Coach comment
- What worked
- What failed
- What to improve next time

Possible UI placement:

- Add note fields to the Save Session dialog.
- Show notes on Analytics screen.
- Allow editing notes from History/Analytics.

Expected value:

- Coaches can leave structured feedback.
- Athletes can review lessons from past sessions.

---

### 4. Training Session Metadata

Goal: make each session meaningful outside raw counters.

Add optional metadata:

- Athlete name
- Coach name
- Venue / water body
- Sector / peg
- Training type
- Target pace
- Weather / conditions
- Bait / method notes

Suggested training types:

- Speed fishing
- Match simulation
- Pace drill
- Final sprint
- Accuracy drill
- Custom

Possible UI placement:

- Add pre-session setup screen.
- Or extend Save Session dialog for MVP.

---

### 5. Better Analytics

Goal: create a real coach report.

Add metrics:

- Green count
- Orange count
- Red count
- Grey count
- Best interval
- Worst interval
- Average interval
- Average deviation
- Stability score
- Early action count
- Late action count
- Try/error count
- Longest stable streak
- Pace drop periods

Potential visualizations:

- Timeline list
- Color distribution bar
- Interval chart
- Pace over time chart

MVP analytics priority:

1. Status counts
2. Best/worst interval
3. Stability score
4. Simple chart

---

### 6. Export / Share Report

Goal: allow athletes and coaches to share training results.

Formats:

- CSV
- PDF
- Plain text summary

Share targets:

- Messenger
- Email
- Files
- Coach/team chat

Report should include:

- Session metadata
- Counters
- Timing statistics
- Status distribution
- Timeline
- Notes / coach comment

Recommended order:

1. Plain text share
2. CSV export
3. PDF export

---

## Recommended Priority

1. Field test current build on iPhone.
2. Add Shake Undo settings.
3. Add Notes / Coach Comment.
4. Add Training Session metadata.
5. Improve Analytics.
6. Add Export / Share Report.

## Product Positioning

Suggested positioning:

> A training and pace-control tool for sport anglers and coaches.

Alternative product names to consider:

- Catch Pace
- Angler Pace
- Match Catch Tracker
- Fishing Coach Counter
- Catch Rhythm
- Sport Fishing Counter

## UX Principles

The app should work well:

- with wet hands;
- with one hand;
- under sunlight;
- under stress during competition;
- with minimal screen attention;
- with strong haptic feedback;
- with simple recovery from mistakes through Undo.
