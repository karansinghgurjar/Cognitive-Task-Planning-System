# CogniPlan Portfolio Case Study

## What It Is
CogniPlan is a local-first planning system built for serious individual execution rather than lightweight task capture. It combines structured planning, routine orchestration, focus execution, review, and knowledge workflows in one Flutter app that runs on Android and Windows.

## Problem
Most productivity tools either stay shallow or become noisy. I wanted a system that could help with real work: M.Tech thesis progress, DSA interview preparation, recurring routines, recovery after missed work, and revision-driven study.

## Product Direction
CogniPlan is designed around a few principles:
- local-first reliability
- deterministic scheduling and planning logic
- explicit user control over risky changes
- explainable assistance instead of opaque automation
- support for both planning work and remembering it

## Core Capabilities
- tasks, goals, dependencies, and milestones
- timetable-aware planning and schedule generation
- routines with recovery, reconciliation, reminders, templates, and sync
- focus sessions and execution tracking
- analytics, weekly review, and planning insights
- planning assistant with deterministic natural-language drafting
- knowledge items, revision workflows, and focus-linked note capture
- backup, restore, integrity checks, and cross-device sync
- sample data and maintenance tools for safe demos and repair

## Architecture Highlights
- Flutter + Riverpod for app structure and state flow
- Isar for local-first persistence
- deterministic domain services for scheduling, sync merge rules, insights, and revision planning
- backup and sync layers designed to preserve local trust and reduce silent data loss risk
- modular feature slices so routines, planning assistant, sync, and knowledge can evolve independently

## Why It Stands Out
This project is stronger than a standard CRUD productivity app because it solves coordination problems across time:
- planning around real capacity
- surviving missed work without churn
- syncing without losing local-first trust
- turning knowledge into revision and action
- keeping generated suggestions explainable and editable

## Platforms
- Android
- Windows desktop

## Phase 12 Focus
Phase 12 turns the system into a more portfolio-ready product by adding:
- navigation cleanup with a planner hub
- refined onboarding
- settings cleanup and appearance defaults
- data maintenance tools
- sample/demo data mode
- release-readiness documentation and packaging polish

## Future Work
- richer focus-session knowledge actions
- explicit note-to-routine support conversion
- stronger release smoke automation for Android and Windows
- optional cloud-assisted summaries layered on top of deterministic planning
