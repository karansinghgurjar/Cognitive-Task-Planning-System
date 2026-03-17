# BUG AUDIT

## Critical

### Startup could fail before the app rendered
- Affected feature/screen: app startup
- Likely cause: optional sync backend initialization could throw before `runApp`.
- Impact: app might never open even though local-only usage should remain possible.
- Fix status: Fixed

### Backup restore used nested Isar write transactions
- Affected feature/screen: backup import / restore
- Likely cause: `replaceAll()` opened `writeTxn()` and then called another method that opened a second `writeTxn()`.
- Impact: restore could fail during a critical recovery flow.
- Fix status: Fixed

## High

### Task deletion left orphan planned sessions and dependency edges
- Affected feature/screen: tasks, Today, scheduling, recommendations
- Likely cause: task deletion removed only the task row.
- Impact: stale scheduled work and broken dependency relationships.
- Fix status: Fixed

### Notification coordinator could surface uncaught plugin/runtime errors
- Affected feature/screen: app startup, notifications, notification-driven refresh
- Likely cause: notification initialization and async sync calls were not guarded.
- Impact: runtime plugin errors could break coordinator behavior or leak as uncaught exceptions.
- Fix status: Fixed

### Sync remote repository could fail unpredictably when backend config existed but init had not completed safely
- Affected feature/screen: sync/auth/bootstrap
- Likely cause: direct `Supabase.instance.client` access without a safe initialization guard.
- Impact: sync/bootstrap actions could fail in unclear ways during real runtime use.
- Fix status: Fixed

### Focus session completion could race and double-run terminal session updates
- Affected feature/screen: focus timer, Today refresh, session completion
- Likely cause: timer completion and manual completion could overlap while the active session still existed.
- Impact: duplicate completion writes or inconsistent terminal state.
- Fix status: Fixed

## Medium

### Startup fallback hid onboarding-state failures by routing home
- Affected feature/screen: startup / first run
- Likely cause: startup error branch fell through to home instead of surfacing a safe error.
- Impact: app could open in an invalid state while masking the local-data problem.
- Fix status: Fixed

### Action controllers started in loading state due to empty async build methods
- Affected feature/screen: tasks, timetable, onboarding, goals, backup, settings, schedule, rescheduling, sync
- Likely cause: no-op async `build()` methods on action controllers.
- Impact: first actions could be rejected as already in progress.
- Fix status: Fixed

### Sign-in/sign-out did not invalidate all sync status surfaces
- Affected feature/screen: sync status / account
- Likely cause: only the account provider was invalidated.
- Impact: sync-related screens could remain stale until additional navigation or refresh.
- Fix status: Fixed

### File picker/save dialog errors were not wrapped cleanly
- Affected feature/screen: backup export/import
- Likely cause: raw platform/file-selector errors could bubble up.
- Impact: poor runtime UX and harder recovery when file operations failed.
- Fix status: Fixed

### Raw exception text leaked into key screens and snackbars
- Affected feature/screen: Today, Tasks, Goals, Timetable, Settings, Recommendations, Analytics
- Likely cause: direct `error.toString()` usage.
- Impact: confusing UX and poor recovery guidance.
- Fix status: Fixed

## Low

### Timetable free-window text contained a mojibake separator
- Affected feature/screen: Timetable computed free windows
- Likely cause: encoding artifact.
- Impact: UI polish issue only.
- Fix status: Fixed

## Remaining known risks
- End-to-end sync with live Supabase credentials still needs manual runtime verification.
- Notification delivery, permission UX, and background behavior still need manual Android/Windows verification.
- File picker and save dialog behavior were hardened, but still need manual runtime verification on both platforms.
