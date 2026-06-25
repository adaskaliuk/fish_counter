# FishCounter Project Knowledge Base

## 📋 Project Overview
**App Name:** FishCounter  
**Type:** Flutter fish counting clicker game  
**Purpose:** Track fish counts with timing precision analytics  

## 🏗️ Architecture

### Core Files
```
lib/
├── main.dart              # App entry point, Firebase initialization
├── clicker_screen.dart    # Main counter screen (stateful)
├── history_screen.dart    # Session history list (stateful)
├── analytics_screen.dart  # Session statistics (stateless)
├── game_session.dart      # Data model for sessions
└── firebase_options.dart  # Firebase configuration
```

### Key Classes

| Class | Type | Purpose |
|-------|------|---------|
| `CatchClickerApp` | StatelessWidget | Root app widget |
| `ClickerScreen` | StatefulWidget | Main counter with LCD display |
| `HistoryScreen` | StatefulWidget | Session history browser |
| `AnalyticsScreen` | StatelessWidget | Precision analytics viewer |
| `GameSession` | Model | Session data structure |

## 🔧 Technical Stack

### Dependencies
- `firebase_core` - Firebase initialization
- `shared_preferences` - Local data persistence
- `battery_plus` - Battery level monitoring
- `intl` - Date/time formatting
- `flutter/services` - Haptic feedback

### State Management
- **Approach:** setState (local state)
- **Persistence:** SharedPreferences
- **No external state management** (Provider/Riverpod/BLoC)

## 📊 Data Model

### GameSession Fields
```dart
{
  id: String,           // Unique session ID (timestamp ms)
  name: String,         // User-defined session name
  date: String,         // Format: "dd.MM.yy HH:mm"
  matchDuration: String,// Format: "H:MM"
  c1: int,              // Counter 1 clicks
  c2: int,              // Counter 2 clicks
  tries: int,           // Failed attempts
  total: int,           // c1 + c2
  grid: List<Map>       // Activity timeline with timestamps
}
```

### Activity Grid Entry
```dart
{
  type: int,            // 0=pause, 1=C1, 2=C2, 3=try
  status: String,       // green/orange/red/grey (timing precision)
  interval: int,        // Seconds since last action
  target: int,          // Target interval (vibeInterval)
  timestamp: String     // Format: "HH:mm:ss"
}
```

## ⚙️ Key Constants

### Preference Keys (`_PrefsKeys`)
```dart
counter1, counter2, tries, total,
power, paused,
reset_delay, vibe_interval, match_seconds,
activity_grid, history_sessions
```

### Defaults (`_Defaults`)
```dart
resetDelaySeconds = 15
vibeIntervalSeconds = 60
matchDurationSeconds = 18000 (5 hours)
actionDelayMs = 600
scrollDelayMs = 100
```

## 🎯 Core Features

### 1. Counter System
- Two independent counters (C1, C2)
- "Try" button for failed attempts
- Total = C1 + C2
- Action delay prevents spam (configurable)

### 2. Timing Precision
- **Green:** ±10% of target interval (perfect)
- **Orange:** Good timing
- **Red:** >+50% late
- **Grey:** <-30% too early
- Haptic feedback on target interval

### 3. Session Management
- Start/Pause toggle
- Power button with save dialog
- Auto-save to SharedPreferences
- Session history with custom names

### 4. Analytics
- Average interval calculation
- Deviation from target
- Color-coded precision indicator
- Activity timeline with timestamps

## 🔐 Security Notes

### ⚠️ Current Issues
- Firebase API keys exposed in source code
- No encryption for local storage
- No authentication implemented

### Recommendations
- Use environment variables for Firebase config
- Consider Flutter Secure Storage for sensitive data
- Add Firebase Auth if multi-user needed

## 🐛 Known Limitations

1. **No cloud sync** - Data stored locally only
2. **No backup/restore** - Manual export not implemented
3. **Single device** - Sessions don't transfer between devices
4. **No unit tests** - Test coverage needed
5. **God class pattern** - ClickerScreen handles too much

## 📝 Code Quality Improvements (Completed)

### ✅ Fixed Issues
- [x] Memory leaks - Added `dispose()` methods
- [x] Async state safety - Added `mounted` checks
- [x] Magic numbers - Extracted to `_Defaults` class
- [x] Hardcoded strings - Extracted to `_PrefsKeys` class
- [x] Error handling - Added try-catch blocks
- [x] Type safety - Improved `GameSession.fromJson`
- [x] Loading states - Added to `HistoryScreen`
- [x] BuildContext safety - Stored refs before async gaps

### 📋 Future Improvements
- [ ] Extract business logic to services
- [ ] Add state management (Provider/Riverpod)
- [ ] Implement repository pattern
- [ ] Add unit/widget tests
- [ ] Add integration tests
- [ ] Secure Firebase keys
- [ ] Add cloud backup
- [ ] Implement named routing

## 🎨 UI/UX Details

### Theme
- Dark mode by default
- LCD-style display (#C0C7B0 background)
- Monospace fonts for numbers
- Material Design buttons

### Colors
- Power ON: Red (#b71c1c)
- Power OFF: Green (#1b5e20)
- Accent: Orange
- Precision: Green/Orange/Red/Grey

### Animations
- 300ms container transitions
- 200ms opacity changes
- 600ms haptic feedback flash

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Supported | Full features |
| iOS | ✅ Supported | Full features |
| Web | ⚠️ Partial | Firebase configured |
| macOS | ❌ Not configured | Throws error |
| Windows | ❌ Not configured | Throws error |
| Linux | ❌ Not configured | Throws error |

## 🫧 Fizzy Workflow

We use the real Fizzy board for task tracking.

**Board name:** `Fish cathcing`  
**Public board URL:** `https://app.fizzy.do/6128892/public/boards/Y79hjW8dhUyf1h4iVC5viN2u`  
**API endpoint:** `https://app.fizzy.do`  
**Account ID:** `6128892`  
**Internal board ID:** `03g9hcxgsooou3nem4gl9n4rn`  
**Current-work column:** `In Todo`  
**In Todo column ID:** `03g9kpnnzqevbchfx0a92so82`

Rules:

- Use Fizzy board `Fish cathcing` for project tasks.
- Put the task currently being worked on into column `In Todo`.
- Never write `FIZZY_TOKEN` into repository files.
- Store token only in local environment variable:

```bash
export FIZZY_TOKEN='...'
```

Useful files:

- `.env.example` — safe Fizzy config template without token.
- `.fizzy/API.md` — API notes discovered from `basecamp/fizzy` source.
- `.fizzy/BOARD.md` — local fallback only when real API is unavailable.

## 🔁 Review-Gated Loop

Use this loop for FishCounter implementation work:

1. **Design** — read the real flow first; no edits before boundary known.
2. **Review** — run a reviewer subagent before/after each round.
3. **Verify** — run targeted tests/analyze every round.
4. **Stop** — max 3 rounds; on blocker, ask instead of guessing.

FishCounter-specific rules:

- one active task only;
- active task lives in `In Todo`;
- backlog lives in `Maybe?`;
- keep changes minimal; prefer root-cause fixes over caller band-aids.

Turn checklist:

1. Read current flow + touched files.
2. State goal + stop condition.
3. Patch smallest root-cause diff.
4. Run review gate.
5. Run targeted verify.
6. Ship only when clean.

## 🌦️ Weather Capture

Weather capture for sport-fishing sessions is implemented.

Purpose:

- automatically attach local weather context to a training session;
- help athletes/coaches compare pace and performance against real conditions.

Implementation:

- location: `geolocator`;
- OpenWeather package: `weather`;
- direct OpenWeather HTTP fallback: `http`;
- API key is provided through local `.env` and passed with `--dart-define`:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY
```

Rules:

- Never commit the real `OPENWEATHER_API_KEY`.
- `.env` is ignored by git.
- Coordinates are rounded to 3 decimals before storage for privacy.

Stored in `GameSession`:

- latitude / longitude;
- weather place;
- weather description;
- temperature / feels like;
- pressure;
- humidity;
- wind speed / direction;
- fetched timestamp.

Displayed/exported in:

- Analytics Training Context;
- plain text report;
- CSV report.

## 🚀 Build & Run

```bash
# Get dependencies
flutter pub get

# Run analyzer
flutter analyze

# Run on device
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📞 Firebase Project

**Project ID:** `fish-counter-55a99`

**Configured Platforms:**
- Web
- Android
- iOS (Bundle ID: com.yukon.fishcounter)

## 📅 Session Timeline

1. User taps START
2. Timer begins counting up
3. User taps C1/C2/Try buttons
4. Each action recorded with timestamp & precision
5. User taps PAUSE to stop timer
6. User taps Power button to end session
7. Dialog prompts for session name
8. Session saved to history
9. Counters reset for next session

## 🧪 Testing Strategy (Recommended)

### Unit Tests Needed
- `GameSession.fromJson()` - JSON parsing
- `GameSession.toJson()` - JSON serialization
- `_calculateStatus()` - Timing precision logic
- `_safeInt()`, `_safeString()` - Type conversion

### Widget Tests Needed
- `ClickerScreen` - Button interactions
- `HistoryScreen` - List rendering
- `AnalyticsScreen` - Statistics display

### Integration Tests Needed
- Full session flow
- Data persistence
- Navigation between screens

---

**Last Updated:** 2026-02-24  
**Code Review Status:** ✅ All critical issues fixed  
**Analyzer Status:** ✅ No issues found

## Localization rule
- FishCounter has localization, so every feature task must include localization for all supported languages.
- New user-visible UI strings must be added to `lib/l10n/app_localizations.dart` in the same task.
- Avoid hardcoded user-visible UI strings in screens/dialogs/buttons/status labels.
- Export/report labels can be intentionally English only only if explicitly agreed; otherwise treat them as localization scope too.

## Code review rule
- After every implementation task, run code review with the
  `thermo-nuclear-code-quality-review` skill.
- Do not consider the task done until that review has no remarks and all findings are fixed.
