# Plan / План

## 1. Model + storage / Модель + сховище
- Add persisted role to profile/settings model.
- Save/load role through existing preferences repository.
- Keep role round-tripping through app settings.

## 2. Auth flow / Auth flow
- Require role selection on signup.
- If role is missing on login, force role setup before app entry.

## 3. UI visibility / Видимість UI
- Hide coach-only profile fields for athletes.
- Keep shared fields visible to both roles.
- Hide coach-only analytics and notes from athletes.

## 4. Localization / Локалізація
- Add role labels, prompts, and validation text to localization.

## 5. Tests / Тести
- Add unit tests for role persistence.
- Add widget tests for role-based visibility.
- Add integration coverage for signup/login flows.
