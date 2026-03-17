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
  ];
}
