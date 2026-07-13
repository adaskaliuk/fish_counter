# Field matrix / Матриця даних

## Existing likely inputs / Наявні джерела
- `GameSession.date`
- `GameSession.matchDuration`
- `GameSession.grid`
- `GameSession.weatherSnapshots`
- `weatherDescription`
- `weatherTemperatureCelsius`
- `weatherPressureHpa`
- `weatherHumidityPercent`
- `weatherWindSpeedMs`
- `weatherWindDirectionDegrees`
- `astronomySummary`
- final result fields (new if missing): weight, count, or both

## Derived outputs / Похідні результати
- match start/end time
- time buckets, e.g. 5/10/15 min chunks
- button/event sequence: C1, C2, try/miss, undo/other if recorded
- event timestamp or relative minute
- final weight/count result and display unit
- catches/activity per bucket
- best activity window
- quietest window
- weather per bucket
- weather trend summary
- practical fisherman notes

## Unknowns / Ризики
- `grid` timestamps may be relative intervals, not absolute timestamps.
- Some old sessions may only have one weather snapshot.
- Match date parsing may be locale/string-format dependent.
