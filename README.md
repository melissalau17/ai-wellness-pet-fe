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
