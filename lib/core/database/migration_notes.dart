class MigrationNote {
  const MigrationNote({required this.version, required this.description});

  final int version;
  final String description;
}

class MigrationNotes {
  const MigrationNotes._();

  static const notes = [
    MigrationNote(
      version: 1,
      description:
          'Initial Cognitive Task Planning System schema with tasks, timetable, schedule, goals, notifications, analytics, and backup metadata.',
    ),
    MigrationNote(
      version: 2,
      description:
          'Added Quick Capture inbox storage for low-friction brain-dump items.',
    ),
    MigrationNote(
      version: 3,
      description:
          'Added contextual notes and resource attachments for tasks and goals.',
    ),
    MigrationNote(
      version: 4,
      description:
          'Added weekly review reflections and end-of-week productivity summaries.',
    ),
    MigrationNote(
      version: 5,
      description:
          'Added smart repeating routines and routine occurrences for recurring habit blocks.',
    ),
    MigrationNote(
      version: 6,
      description:
          'Hardened routine lifecycle behavior with reconciliation, reminder preferences, and recovery dismissal state.',
    ),
  ];
}
