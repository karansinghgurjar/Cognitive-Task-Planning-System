# Cognitive Task Planning System

Cognitive Task Planning System is a Flutter application for planning study or task-driven work across goals, tasks, schedules, focus sessions, reminders, backups, analytics, and optional cloud sync.

The app is designed for local-first usage with Isar as the primary datastore and an optional Supabase sync layer. It currently targets Android and Windows.

## Highlights

- Local-first task planning with offline startup fallback
- Goal and milestone management with dependency-aware task generation
- Timetable-driven schedule generation and missed-session recovery
- Focus sessions with pause, resume, cancel, and completion flows
- Recommendations and analytics dashboards for workload and progress visibility
- JSON backup/restore, CSV export, and integrity checks
- Optional Supabase-based sync and account flows
- Notification and reminder infrastructure with background-worker support

## Implemented Modules

### Core planning flows

- `Today`: daily schedule view, recovery prompts, and recommended next action
- `Tasks`: task creation, completion, deletion, and task-level planning metadata
- `Goals`: goal creation, milestones, progress, and goal detail insights
- `Timetable`: availability slots and overlap validation for planning windows
- `AI planning`: generate a draft plan from a natural-language prompt, review it, edit it, and import it into the system

### Productivity support

- `Focus sessions`: timed work sessions with lifecycle safeguards
- `Recommendations`: feasibility, workload warning, and next-step suggestions
- `Analytics`: progress summaries, charts, streaks, day review, and time allocation views

### Safety and operations

- `Backup & Restore`: full JSON backups, import preview, CSV export, and integrity checks
- `Sync & Account`: sign-in, status, queue visibility, and bootstrap flows when Supabase is configured
- `Notifications`: session reminders, daily summary preferences, deadline warnings, and backup reminder cadence
- `Settings`: notification preferences, sync entry points, onboarding replay, and about/release context

## Tech Stack

- `Flutter` + `Dart`
- `flutter_riverpod` for state management
- `Isar` for local persistence
- `Supabase Flutter` for optional sync/auth
- `flutter_local_notifications` for reminders
- `workmanager` for background execution
- `fl_chart` for analytics visualizations
- `file_selector` for backup import/export flows

## Platforms

- `Android`: primary target for reminders/background behavior
- `Windows`: supported desktop runtime with keyboard shortcuts and wide-layout handling

Current desktop shortcuts:

- `Ctrl+1` to `Ctrl+5`: switch main tabs
- `Ctrl+,`: open settings

## Architecture Overview

The codebase is organized around feature modules under `lib/features`, with shared infrastructure in `lib/core` and app bootstrapping in `lib/app`.

High-level flow:

1. `main.dart` initializes optional sync backend support.
2. `AppBootstrap` creates the Material app shell.
3. `StartupGate` decides whether to show onboarding or the main application.
4. `HomeShell` hosts the primary tabs: Today, Tasks, Goals, Insights, and Timetable.
5. Settings provides access to notifications, backup/restore, sync, onboarding replay, and about details.

The app is intentionally resilient to optional-service failures. If sync initialization fails at startup, the app can still continue in offline mode.

## Repository Structure

```text
lib/
  app/        App bootstrap, startup gate, shell, routing
  core/       Shared services, notifications, database, theme, widgets
  features/   Domain modules such as tasks, goals, analytics, sync, backup
assets/
  branding/   Source app icon and branding assets
supabase/
  sync_schema.sql   Database schema for optional sync setup
test/
  app/ core/ features/   Widget and domain/service tests
tool/
  dev_windows.ps1
  prepare_app_icon.py
  sync_app_icon.ps1
android/
windows/
```

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.11.0`
- Android Studio or Android command-line tooling for Android builds
- Visual Studio with Desktop development with C++ for Windows builds
- Windows Developer Mode for plugin symlink support on Windows

### Install dependencies

```bash
flutter pub get
```

### Regenerate generated files when models change

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the app

```bash
flutter run -d windows
```

```bash
flutter run -d android
```

## Sync Configuration

Sync is optional. The app works in local-only mode without Supabase configuration.

To enable sync, provide runtime defines:

```bash
flutter run -d windows --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Apply the schema in [`supabase/sync_schema.sql`](supabase/sync_schema.sql) before connecting a fresh Supabase project.

Important notes:

- Sync should not be treated as production-safe until verified with real credentials and a reachable backend.
- Sign-out with pending local changes can leave those changes unsynced on the device.
- Startup continues offline if optional sync initialization fails.

## Quality Commands

```bash
dart analyze lib test
```

```bash
flutter test
```

Recommended pre-release flow:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart analyze lib test
flutter test
flutter build apk --release
flutter build windows --release
```

## Release and Deployment Notes

### Android

- Primary platform for reminder flows and background-worker behavior
- Release APK build:

```bash
flutter build apk --release
```

- For store-oriented distribution, configure signing and build an app bundle:

```bash
flutter build appbundle --release
```

### Windows

- Validate Windows Developer Mode and Visual Studio C++ tooling first
- Release build:

```bash
flutter build windows --release
```

## User Workflow Summary

Typical workflow inside the app:

1. Complete onboarding on first launch.
2. Add tasks and long-term goals.
3. Define timetable availability.
4. Generate or refine plans from goals or natural-language prompts.
5. Review the Today screen for sessions, recovery actions, and recommended next move.
6. Run focus sessions while tracking completion and progress.
7. Use analytics and recommendations to adjust workload.
8. Export backups regularly and enable sync only after backend setup is verified.

## Current Verification Status

Verified in this repository's recent stabilization pass:

- `dart analyze lib test`
- `flutter test`
- `flutter run -d windows`
- direct Windows debug executable launch stability checks

Recent hardening work focused on:

- startup failure handling and offline continuation
- safer notification coordinator behavior
- sync/auth state invalidation and guarded backend access
- focus-session lifecycle race prevention
- backup/restore transaction safety
- file dialog error wrapping

## Known Limitations

- Live Supabase sign-in, bootstrap, push/pull, retry, and sign-out behavior were not end-to-end verified with real credentials in the current validation pass.
- Notification delivery and permission UX still require manual platform-level verification.
- Android-specific background execution should be revalidated on a real device.
- File-picker and save-dialog flows were hardened, but still need manual verification on Windows and Android.
- The technical package/binary identifiers still use `study_flow` for compatibility, even though the user-facing app name is `Cognitive Task Planning System`.

## QA Coverage Areas

The existing test and QA checklist cover these areas:

- startup and onboarding
- task CRUD
- timetable management and overlap validation
- schedule generation and recovery
- focus session lifecycle
- goals and AI planning
- recommendations and analytics
- backup and restore
- sync surfaces
- notifications
- settings and about
- desktop accessibility and keyboard shortcuts

## Supporting Project Documents

- [`DEPLOYMENT_NOTES.md`](DEPLOYMENT_NOTES.md)
- [`QA_CHECKLIST.md`](QA_CHECKLIST.md)
- [`STABILIZATION_REPORT.md`](STABILIZATION_REPORT.md)
- [`RUNTIME_VERIFICATION_REPORT.md`](RUNTIME_VERIFICATION_REPORT.md)
- [`KNOWN_LIMITATIONS_RUNTIME.md`](KNOWN_LIMITATIONS_RUNTIME.md)

## Status

The project is beyond scaffold stage and contains substantial domain logic, tests, and operational tooling. Local-only daily use is in a stronger state than sync-enabled daily use; treat cloud sync and notification behavior as features that still require environment-specific verification.
