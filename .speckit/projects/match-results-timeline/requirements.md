# Requirements / Вимоги

1. Match timeline / Таймлайн матчу
   - Show match progress over time from start to finish.
   - Show catch/activity events on the timeline.
   - Show which button/event type was pressed: C1, C2, try/miss, undo/other if recorded.
   - Show event time or relative minute inside the match.
   - Group events into readable time buckets.

2. Weather during match / Погода під час матчу
   - Show weather snapshots that fall inside the match time window.
   - Include temperature, pressure, wind speed/direction, humidity, and description.
   - Show changes over time, not only one latest value.

3. Result element / Результатний елемент
   - Add a match result element that can be weight, count, or both.
   - Let user enter/edit final weight and/or final count for a match.
   - Show selected result values in result/history/export views.
   - Preserve old sessions without result values.

4. Fisherman summary / Рибацький висновок
   - Explain best/worst time windows in human-readable form.
   - Highlight weather changes near activity spikes.
   - Keep wording practical: what helped, what changed, what to watch next time.

5. Current data first / Спочатку наявні дані
   - Reuse existing `GameSession.grid`, weather snapshots, duration, and date fields.
   - Do not add new dependencies unless existing data cannot support the feature.

6. Backward compatibility / Сумісність
   - Old sessions without weather snapshots still render useful results.
   - Missing timestamps/weather data should degrade gracefully.
