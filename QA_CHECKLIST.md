# Cognitive Task Planning System QA Checklist

## Startup and onboarding
- First launch shows onboarding
- Skip onboarding reaches the main app
- Finish onboarding prevents it from showing again
- Replay onboarding from Settings works

## Tasks
- Add task with valid required fields
- Validation blocks empty title and invalid duration
- Toggle task completion
- Delete task with confirmation

## Timetable
- Add timetable slot
- Edit timetable slot
- Overlap validation prevents conflicting slots
- Delete timetable slot with confirmation
- Computed free windows display correctly

## Schedule generation and recovery
- Generate schedule with valid tasks and timetable
- Generate schedule shows confirmation and success message
- Missed sessions appear after their end time passes
- Recover & Reschedule preserves completed sessions
- Recover banner appears when missed sessions exist

## Focus session
- Start focus from Today
- Pause and resume focus session
- Complete session manually
- Auto-complete when timer reaches zero
- Cancel session follows the chosen cancellation rule
- Active focus banner resumes the running session

## Goals and AI planning
- Create goal manually
- Add milestone to goal
- Generate tasks from goal
- Create plan from natural-language prompt
- Review and edit AI-generated draft before import
- Imported tasks respect dependencies in scheduling

## Recommendations and analytics
- Today shows best-next-task recommendation when data exists
- Insights tab renders weekly summary and charts
- Empty states explain next steps when no data exists
- Goal detail shows feasibility/risk section

## Backup and restore
- Create full JSON backup
- Import backup preview shows counts and warnings
- Replace All restore requires explicit confirmation
- CSV export works for tasks, sessions, goals, analytics
- Integrity check runs and renders report

## Sync
- Sign in flow works when Supabase config is present
- Sync status shows pending, failed, and last sync state
- Sync Now works
- Retry Failed works when failures exist
- Sign out warns if pending local changes exist

## Notifications
- Session reminder test notification works
- Daily summary preference saves
- Deadline warning preference saves
- Reminder lead time changes persist

## Settings and about
- Settings home links to notifications, sync, backup, onboarding replay, and about
- About screen shows app version/build

## Accessibility and desktop sanity
- Keyboard shortcuts switch tabs on desktop
- Buttons have clear labels for screen readers on key actions
- Text scaling does not immediately break core screens
- Desktop layouts stay centered and readable on wide windows
