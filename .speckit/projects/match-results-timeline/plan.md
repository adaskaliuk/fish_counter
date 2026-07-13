# Plan / План

## Data shape found / Що вже є

- `GameSession.grid` already stores activity events.
- Each grid entry already has:
  - `type`: `1=C1`, `2=C2`, `3=try`, `0=pause`;
  - `timestamp`: `HH:mm:ss`;
  - `interval`: seconds;
  - `target`;
  - `status`.
- `ActivityLog.fromJson()` already maps grid entries to typed timeline logs.
- `AnalyticsTimelineSection` already renders event label, timestamp, and interval.
- `GameSession.weatherSnapshots` already exists.
- Weather capture already happens:
  - at session start;
  - every 15 minutes while active;
  - at finish.
- `WeatherSnapshot` already has temperature, feels-like, pressure, humidity,
  wind speed, wind direction, description, fetchedAt.
- Missing: final result values (`weight`, `count`).
- Missing: explicit `startedAt` / `endedAt`; fallback can derive from saved date
  and `matchDuration`.

## Implementation plan / План реалізації

### 1. Cheap win: wire existing timeline
- Import and render `AnalyticsTimelineSection` inside `AnalyticsScreenBody`.
- Place it after summary/dashboard and before charts.
- This immediately shows which button/event happened and when.
- Add/adjust widget test that C1/C2/try/pause labels + timestamps appear.

### 2. Weather during match section
- Add `WeatherDuringMatchSection` widget.
- Input: `GameSession.weatherSnapshots` + session-level weather fallback.
- Show snapshot cards/list with:
  - fetchedAt;
  - description;
  - temperature;
  - pressure;
  - humidity;
  - wind speed;
  - wind direction.
- If multiple snapshots exist, show simple trend text:
  - temperature up/down/stable;
  - pressure up/down/stable;
  - max wind.
- If no weather exists, show readable fallback: no weather data for this match.
- Reuse existing formatting/localization where possible.

### 3. Fisherman summary
- Add small pure helper/model, no dependency:
  - best activity window from existing grid entries;
  - quietest window;
  - nearby weather snapshot if available.
- Keep language cautious: “activity was highest near …”, not “weather caused …”.
- Render summary in analytics/history result UI.

### 4. Result element: weight/count/both
- Add nullable/backward-compatible fields to `GameSession`:
  - `finalWeightKg` (`double?`);
  - `finalCount` (`int?`).
- Include in constructor/factory/builder/fromJson/toJson.
- Old sessions without fields must deserialize safely.
- Add edit/input controls in existing `SessionEditDialog` first.
  - Weight optional.
  - Count optional.
  - User may fill one or both.
- Show result values in:
  - history details;
  - analytics/result summary;
  - report exporter plain text + CSV.

### 5. Session time window fallback
- Do not add `startedAt` yet unless needed.
- For v1 derive:
  - `endAt` from `GameSession.date` when parseable;
  - `startAt = endAt - matchDuration` when parseable;
  - otherwise use event timestamps as display-only.
- Mark future upgrade: explicit `startedAt`/`endedAt` if date parsing proves unreliable.

### 6. Tests
- Unit/model tests:
  - `GameSession` weight-only round-trip;
  - count-only round-trip;
  - weight+count round-trip;
  - old JSON without result values.
- Widget tests:
  - analytics body shows timeline event labels/timestamps;
  - weather section shows temp/pressure/wind/humidity;
  - weather section fallback with no snapshots;
  - session edit preserves hidden/existing fields and saves result values.
- Export tests:
  - plain text includes final result values when present;
  - CSV includes result columns/values when present.

## Stop condition / Умова готовності

- Timeline visible with button/event + time.
- Weather during match visible when snapshots exist.
- Final result element supports weight/count/both.
- Old sessions still work.
- Focused tests pass.
- `flutter analyze --no-pub` and `flutter test` pass.
