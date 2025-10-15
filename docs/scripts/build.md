# Build & Packaging Guide

This project targets macOS, Windows, iOS, and Android. Install Flutter (3.19+) with the corresponding platform SDKs.

## Prerequisites

* Flutter SDK with desktop and mobile targets enabled (`flutter config --enable-macos-desktop --enable-windows-desktop --enable-ios --enable-android`).
* Xcode 15+ with command-line tools for iOS/macOS builds.
* Android Studio with Android SDK and NDK (for WorkManager).
* Windows 11 with Desktop App Installer (for .msix packaging) or WiX Toolset (for .exe) when building on Windows.
* Supabase project (or Firebase) – populate `.env` or `dart-define` values with `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## macOS (.app + .dmg)

```bash
flutter clean
flutter build macos --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
create-dmg build/macos/Build/Products/Release/homework_tracker.app --output HomeworkTracker.dmg
```

To notarize, upload `HomeworkTracker.dmg` to Apple Notary Service via Xcode or `xcrun notarytool`.

## Windows (.msix)

```powershell
flutter build windows --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
msix-packaging create --publisher "CN=HomeworkTracker" --build-root build\windows\runner\Release --output HomeworkTracker.msix
```

Enable push notifications by registering the app with Windows Notification Service. Optional `.exe` packaging can be created with WiX.

## iOS (TestFlight IPA)

```bash
flutter build ipa --release --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
```

Open `ios/Runner.xcworkspace` in Xcode to configure push notifications, keychain sharing, and upload to App Store Connect for TestFlight.

## Android (.aab + .apk)

```bash
flutter build appbundle --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
flutter build apk --split-per-abi --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<anon>
```

Upload the `.aab` to Play Console; distribute `.apk` for sideload testing.

## One-click scripts

Create helper scripts if desired (macOS example):

```bash
#!/bin/bash
set -e
flutter pub get
flutter build macos --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
open build/macos/Build/Products/Release
```

Store platform automation in `docs/scripts/` or dedicated CI workflows.

## Environment configuration

* Add a `.env` file for local development:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

* Sensitive credentials (refresh tokens, session secrets) are stored via `flutter_secure_storage` using platform keychain APIs.
* Local database encryption uses SQLCipher; ensure the passphrase is injected at runtime via secure storage.

## Testing

Run automated tests before packaging:

```bash
flutter test
```

UI/integration tests can be added under `integration_test/` for import and sync flows.
