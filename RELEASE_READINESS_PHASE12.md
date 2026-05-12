# Phase 12 Release Readiness

## Scope
This phase is focused on product polish rather than another major planning subsystem.

## Included
- planner hub and cleaner top-level navigation
- refined onboarding with use case and setup direction choices
- safer settings hub with appearance, planning horizon, sync, backup, sample data, and maintenance entry points
- sample data workflow for demos and screenshots
- data maintenance screen for rebuild and dedupe actions
- persisted theme and planning horizon preferences
- portfolio case study documentation
- version bump to 1.2.0+12

## Packaging Notes
- Android label remains `CogniPlan`
- Windows title remains `CogniPlan`
- Launcher icon config remains in `pubspec.yaml`
- local notifications and exact-alarm permissions are already declared in Android manifest

## Manual Verification Checklist
- launch app on Android and Windows
- verify onboarding completion and skip paths
- verify theme switching persists
- load sample data, inspect dashboard, then clear sample data
- run backup and integrity scan
- trigger routine rebuild and dedupe from maintenance screen
- confirm sync and settings surfaces remain reachable

## Known Gaps
- no fully automated Android or Windows release smoke pipeline yet
- focus-session surface still favors quick note capture over the full knowledge action set
- release screenshots and store-style assets should be captured from sample data before external presentation
