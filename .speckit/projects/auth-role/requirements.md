# Requirements / Вимоги

## 1. Role selection at auth / Вибір ролі під час авторизації
**EN:** Role selection is required during registration. If a signed-in user has no stored role, prompt them to choose or confirm one before entering the app.

**UA:** Вибір ролі є обов’язковим під час реєстрації. Якщо користувач увійшов без збереженої ролі, перед входом у застосунок треба попросити його обрати або підтвердити роль.

## 2. Persist role / Зберігати роль
**EN:** Persist the selected role in settings/profile storage so it survives app restart and login sessions.

**UA:** Зберігати вибрану роль у профілі/налаштуваннях так, щоб вона переживала перезапуск застосунку та сесії входу.

## 3. Role-based visibility / Видимість залежно від ролі
**EN:** Hide coach-only fields from athletes. Show only the fields, notes, and dashboards relevant to the current role.

**UA:** Приховати тренерські поля від спортсмена. Показувати лише ті поля, нотатки та дашборди, які відповідають поточній ролі.

## 4. Validation / Валідація
**EN:** Do not allow registration without a role. Do not require hidden fields for the inactive role.

**UA:** Не дозволяти реєстрацію без ролі. Не вимагати приховані поля для неактивної ролі.

## 5. Localization / Локалізація
**EN:** Add all new role labels, prompts, and validation messages to localization files. Avoid hardcoded user-facing strings.

**UA:** Додати всі нові назви ролей, підказки та повідомлення валідації у файли локалізації. Не використовувати hardcoded текст для інтерфейсу.
