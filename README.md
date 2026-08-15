# Milo's Corner (Flutter)

A Flutter client for the **AI Wellness Pet** backend, matching the
Welcome / Home / Journey / Log Wellness screens.

## Screens → API mapping

| Screen | File | Backend calls |
|---|---|---|
| Welcome / name your pet | `lib/screens/onboarding_screen.dart` | `POST /pet/setup` |
| Home (pet mood, health/energy, quick actions) | `lib/screens/home_screen.dart` | `GET /pet/:user_id` |
| Your Journey (history list) | `lib/screens/history_screen.dart` | `GET /activity/:user_id` |
| Log My Wellness (hydration/sleep/journal) | `lib/screens/activities_screen.dart` | `POST /activity` |
| Garden (placeholder + demo tools) | `lib/screens/garden_screen.dart` | `POST /pet/:user_id/reset`, `POST /pet/:user_id/simulate-neglect` |

## ⚠️ Important: the `user_id` requirement

`POST /pet/setup` fails with **404 "user not registered"** unless the
`user_id` you send already exists as a row in the backend's `users`
table (it's a foreign key). The README you shared doesn't include a
user-registration endpoint, so this app can't create that row for you.

For now, the onboarding screen has a collapsible "advanced" field where
you can paste in a `user_id` you've already inserted (e.g. via SQL or
Supabase Auth). If you leave it blank, the app generates a random UUID
locally — **this will fail against your current backend** until either:

- you add a `POST /users` (or similar) registration endpoint, or
- you insert a matching row into `users` yourself for testing, e.g.:

```sql
insert into users (id, name, email)
values ('11111111-1111-1111-1111-111111111111', 'Test User', 'test@example.com');
```

then paste `11111111-1111-1111-1111-111111111111` into the advanced
field on the Welcome screen.

## Running it

1. Install Flutter (3.x) and run:
   ```bash
   flutter pub get
   ```
2. Point the app at your backend. Default is `http://localhost:8080/api/v1`.
   Override at build/run time:
   ```bash
   # Android emulator talking to a backend on your host machine:
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1

   # iOS simulator / web / desktop, backend on localhost:
   flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1

   # Deployed backend on Render:
   flutter run --dart-define=API_BASE_URL=https://your-service.onrender.com/api/v1
   ```
3. On first launch you'll land on the Welcome screen. Pick/type a pet
   name, optionally paste an existing `user_id`, then "Start Our Journey".

## Notes on design choices

- **State management**: a single `PetProvider` (ChangeNotifier via
  `provider`) holds the current pet, history, and in-progress log
  draft, and talks to `ApiService`. Kept intentionally simple — no
  code generation, no extra state layers.
- **Persistence**: `user_id` / `pet_name` / onboarded flag are saved
  with `shared_preferences` so returning users skip onboarding.
- **Per-log mood pills** on the History screen are a client-side
  heuristic (`DailyLog.displayMood`) since the backend only stores the
  *pet's* overall `current_state`, not a mood per historical log entry.
  Swap this out if/when the backend starts returning that.
- **Garden tab**: the mockups show it in the bottom nav but no screen
  design exists for it, so it's a placeholder that also surfaces the
  backend's demo-only `reset` / `simulate-neglect` endpoints, handy for
  showcasing pet states without waiting for real activity data.
