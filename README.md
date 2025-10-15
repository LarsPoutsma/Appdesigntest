# Homework Tracker

Cross-platform Flutter application for tracking homework with offline-first storage, secure sync, and powerful import automation.

## Features

- Dashboard and calendar views with drag-ready architecture for due date changes.
- Offline-first storage using SQLCipher via `sqflite_sqlcipher`, encrypted per-device.
- Secure cloud sync via Supabase (Firestore compatible architecture) with conflict resolution.
- Import wizard supporting ICS, CSV, and HTML sources; normalization preview before commit.
- Quick-add natural language parser (“Lab 3 due Fri 11:59pm for Chem 121”).
- Review queue for conflict resolution and change approval.
- Local notifications (24h & 2h defaults) and ICS export feed.
- Setup wizard, course/source managers, settings with telemetry toggle.

## Getting Started

1. Install Flutter 3.19+ with desktop/mobile toolchains.
2. Configure Supabase credentials using `.env` or `--dart-define`:
   ```
   SUPABASE_URL=https://your.supabase.co
   SUPABASE_ANON_KEY=anon-key
   ```
3. Run `flutter create .` once to generate platform runners, then `flutter pub get` and `flutter test`.
4. Launch with `flutter run -d macos` (or target of choice).

For packaging instructions see [`docs/scripts/build.md`](docs/scripts/build.md).

## Testing

Unit tests cover fingerprinting, date parsing, and import normalization.
Run via:

```
flutter test
```

## Architecture

- `lib/domain`: entities, repositories, use cases.
- `lib/data`: local/remote datasources with repository implementations.
- `lib/services`: notifications, import/export, sync.
- `lib/presentation`: providers and screens using `provider` + `go_router`.

## Security

- Secrets stored via `flutter_secure_storage` on each platform keychain.
- SQLCipher encrypted database ensures data at rest protection.
- Supabase Row-Level Security recommended for cloud tables.

## Sync Notes

Background sync is wired via `workmanager` (Android) with placeholder callback; extend per-platform to suit scheduling requirements (e.g., BGTaskScheduler for iOS).
