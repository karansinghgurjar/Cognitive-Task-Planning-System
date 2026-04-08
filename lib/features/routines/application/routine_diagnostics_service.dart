class RoutineDiagnosticsSnapshot {
  const RoutineDiagnosticsSnapshot({
    required this.startedAt,
    required this.finishedAt,
    required this.scannedOccurrences,
    required this.missedMarked,
    required this.recoverySuggestions,
    required this.autoScheduled,
    required this.unscheduled,
    required this.remindersScheduled,
    required this.remindersCancelled,
    required this.notes,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final int scannedOccurrences;
  final int missedMarked;
  final int recoverySuggestions;
  final int autoScheduled;
  final int unscheduled;
  final int remindersScheduled;
  final int remindersCancelled;
  final List<String> notes;

  Duration get duration => finishedAt.difference(startedAt);
}

class RoutineDiagnosticsService {
  const RoutineDiagnosticsService();

  RoutineDiagnosticsSnapshot summarize({
    required DateTime startedAt,
    required DateTime finishedAt,
    required int scannedOccurrences,
    required int missedMarked,
    required int recoverySuggestions,
    required int autoScheduled,
    required int unscheduled,
    required int remindersScheduled,
    required int remindersCancelled,
    List<String> notes = const [],
  }) {
    return RoutineDiagnosticsSnapshot(
      startedAt: startedAt,
      finishedAt: finishedAt,
      scannedOccurrences: scannedOccurrences,
      missedMarked: missedMarked,
      recoverySuggestions: recoverySuggestions,
      autoScheduled: autoScheduled,
      unscheduled: unscheduled,
      remindersScheduled: remindersScheduled,
      remindersCancelled: remindersCancelled,
      notes: notes,
    );
  }
}
