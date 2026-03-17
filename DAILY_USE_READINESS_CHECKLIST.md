# DAILY USE READINESS CHECKLIST

## First Run
- Launch the app on a clean state.
- Confirm the startup screen does not crash.
- Confirm onboarding appears on first run.
- Confirm onboarding can be skipped and completed.
- If sync is not configured, confirm the app still works locally without startup failure.

## Tasks
- Add one task with a title, type, duration, and priority.
- Edit that task and confirm the list refreshes correctly.
- Mark the task complete, then incomplete.
- Delete the task and confirm it disappears cleanly.

## Timetable
- Add one busy slot.
- Add one free slot.
- Try creating an overlapping slot and confirm it is rejected.
- Delete a slot and confirm computed free windows update.

## Scheduling
- With at least one task and timetable availability, generate the next 7 days.
- Confirm sessions appear only inside free windows.
- Generate again and confirm future pending sessions do not duplicate.
- Confirm completed sessions are preserved.

## Focus Session
- Start a pending planned session.
- Pause and resume it.
- Manually complete one session.
- Start another session and cancel it.
- Confirm Today reflects the correct final session state.
- Confirm a quick double-tap on completion does not duplicate the completion outcome.

## Recovery
- Move one pending session into the past or use existing missed-session detection conditions.
- Confirm it becomes missed.
- Run Recover & Reschedule.
- Confirm completed sessions remain unchanged.

## Goals
- Create one goal.
- Add milestones.
- Generate linked tasks.
- Delete or complete a milestone and confirm goal detail stays stable.

## Recommendations and Analytics
- Open Recommendations and confirm the screen loads without raw errors.
- Open Analytics and confirm the dashboard loads for the current range.
- Confirm empty states are helpful when no data exists.

## Backup
- Create a full JSON backup.
- Load the backup into import preview.
- Try importing malformed JSON and confirm it is rejected safely.
- Confirm `replaceAll` shows a destructive warning before restore.
- Cancel a save/open dialog once and confirm the app remains stable.

## Sync
- If sync is configured, sign in.
- Trigger Sync Now.
- Confirm sync status and recent run summary update.
- Attempt sign out with pending changes and confirm the warning is shown.
- If sync is not configured, confirm Sync/Account screens stay usable and clearly indicate local-only behavior.

## Notifications
- Open notification settings.
- Toggle reminders and daily summary.
- Send a test notification.
- If on Android, verify the notification actually arrives.
- If notification permissions are denied, confirm the app stays usable and the feature degrades gracefully.

## AI Planning
- Create a plan from a natural-language prompt.
- Review the preview.
- Import the plan and confirm goals/tasks are created without duplicates.

## Final Sanity
- Reopen the app after closing it.
- Confirm startup still succeeds.
- Confirm Today, Tasks, Timetable, Goals, Settings, Backup, and Sync screens all open without crashes.
