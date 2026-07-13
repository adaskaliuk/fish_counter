## Review
- Correct: `GameSession` result fields are backward-compatible: nullable fields at `lib/game_session.dart:18-19`, emitted only when present at `lib/game_session.dart:302-303`, parsed safely at `lib/game_session.dart:328-329`.
- Correct: report export writes final result values in both CSV and text: `lib/services/report_exporter.dart:30-33`, `lib/services/report_exporter.dart:179-182`.
- Correct: timeline is wired into analytics body at `lib/widgets/analytics_screen_body.dart:60`; widget test covers labels/timestamps in `test/match_results_timeline_test.dart:24-35`.
- Correct: weather snapshots are carried into saved sessions through `finishSessionAndPowerOff()` at `lib/providers/clicker_provider.dart:493-509`.

- Fixed: none; review-only task.

- Blocker: `lib/providers/clicker_provider.dart:212` awaits final weather capture before applying expiry state at `lib/providers/clicker_provider.dart:230-235`. With real weather enabled, `fetchCurrentWeather()` can await GPS/network (`lib/services/weather_service.dart:24`, `lib/services/weather_service.dart:61`, `lib/services/weather_service.dart:117`), so the match remains active/countable after the timer reaches zero. `TimerManager` also does not await async ticks (`lib/services/timer_manager.dart:10-14`), allowing overlap. Simplest fix: apply timer-expired state before starting/awaiting weather capture, or fire final capture after expiry state is committed.

- Note: fix worth doing: `WeatherDuringMatchSection` is outside the coach-only block (`lib/widgets/analytics_screen_body.dart:48-61`) while the existing weather section is coach-only at `lib/widgets/analytics_screen_body.dart:57` and athlete exports hide weather. If weather/location is coach-only, gate this new section too.
- Note: optional defer: CSV export has result rows in code, but the CSV test creates final result values at `test/report_exporter_test.dart:66-67` and never asserts `"result","final_weight_kg"` / `"result","final_count"` at `test/report_exporter_test.dart:85-90`.
- Note: optional defer: new weather/timeline summary strings are hard-coded English at `lib/widgets/weather_during_match_section.dart:23`, `:31`, `:73`, `:85`, `:105`.