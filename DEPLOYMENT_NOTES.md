# Cognitive Task Planning System Deployment Notes

## Overview
- App name: `Cognitive Task Planning System`
- Platforms: Android, Windows
- Local storage: Isar
- Optional remote sync: Supabase

## Prerequisites
- Flutter SDK matching the project's Dart SDK constraint
- Android Studio or Android SDK command-line tools for Android builds
- Visual Studio with Desktop development with C++ for Windows builds
- Windows Developer Mode enabled for plugin symlink support
- Internet access for `flutter pub get`

## Environment configuration
- Sync remains optional.
- To enable Supabase-backed sync, provide:
  - `--dart-define=SUPABASE_URL=...`
  - `--dart-define=SUPABASE_ANON_KEY=...`
- Apply the SQL in [sync_schema.sql](c:\Users\hp\Desktop\TaskManagement\study_flow\supabase\sync_schema.sql) before using sync against a new project.

## Android release build
1. Run `flutter pub get`
2. Run `dart run build_runner build --delete-conflicting-outputs` if models changed
3. Run `flutter analyze`
4. Run `flutter test`
5. Run `flutter build apk --release`

Optional:
6. Configure signing for Play-distribution-ready output
7. Run `flutter build appbundle --release`

## Windows release build
1. Enable Windows Developer Mode
2. Install Visual Studio C++ desktop tooling
3. Run `flutter pub get`
4. Run `flutter analyze`
5. Run `flutter test`
6. Run `flutter build windows --release`

## Notification notes
- Android notification flows are the primary supported target.
- Windows notification behavior depends on local OS/plugin support and should be validated manually on the target machine.
- Background worker behavior is Android-first.

## Backup and sync safety
- Create a JSON backup before:
  - reinstalling
  - changing devices
  - testing destructive restore flows
  - changing sync configuration
- Do not sign out of sync while pending local changes exist unless you accept leaving them unsynced on that device.

## Release sanity checks
- Confirm onboarding shows only on first launch
- Confirm schedule generation and recovery still work after a fresh install
- Confirm backup export/import on each target platform
- Confirm sync sign-in/bootstrap only after Supabase configuration is verified

## Known machine caveats
- `flutter build windows` can fail when Windows Developer Mode is disabled.
- File-picker and notification behavior should be validated on a real device or desktop session, not only in tests.
