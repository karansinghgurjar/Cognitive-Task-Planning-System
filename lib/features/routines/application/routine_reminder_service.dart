import '../../../core/notifications/notification_service.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineReminderSyncResult {
  const RoutineReminderSyncResult({
    required this.scheduledCount,
    required this.cancelledCount,
  });

  final int scheduledCount;
  final int cancelledCount;
}

class RoutineReminderService {
  const RoutineReminderService({required NotificationService notificationService})
      : _notificationService = notificationService;

  final NotificationService _notificationService;

  Future<RoutineReminderSyncResult> syncRoutineReminders({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
  }) async {
    final routineById = {for (final routine in routines) routine.id: routine};
    var scheduledCount = 0;
    var cancelledCount = 0;
    for (final occurrence in occurrences) {
      final routine = routineById[occurrence.routineId];
      if (routine == null || !_isEligible(routine: routine, occurrence: occurrence, now: now)) {
        await _notificationService.cancelRoutineReminder(occurrence.id);
        cancelledCount += 1;
        continue;
      }

      final scheduledStart = occurrence.scheduledStart!;
      final leadMinutes = routine.reminderLeadMinutes ?? 10;
      final reminderTime = scheduledStart.subtract(Duration(minutes: leadMinutes));
      if (!reminderTime.isAfter(now)) {
        await _notificationService.cancelRoutineReminder(occurrence.id);
        cancelledCount += 1;
        continue;
      }

      await _notificationService.scheduleRoutineReminder(
        occurrenceId: occurrence.id,
        routineId: routine.id,
        when: reminderTime,
        title: '${routine.title} starts soon',
        body: leadMinutes == 0
            ? 'It is time for your routine block.'
            : 'Starts in $leadMinutes minutes.',
      );
      scheduledCount += 1;
    }
    return RoutineReminderSyncResult(
      scheduledCount: scheduledCount,
      cancelledCount: cancelledCount,
    );
  }

  Future<void> cancelRemovedRoutineReminders({
    required List<RoutineOccurrence> previousOccurrences,
    required List<RoutineOccurrence> currentOccurrences,
  }) async {
    final currentIds = currentOccurrences.map((occurrence) => occurrence.id).toSet();
    for (final previous in previousOccurrences) {
      if (!currentIds.contains(previous.id)) {
        await _notificationService.cancelRoutineReminder(previous.id);
      }
    }
  }

  bool _isEligible({
    required Routine routine,
    required RoutineOccurrence occurrence,
    required DateTime now,
  }) {
    return routine.generatesOccurrences &&
        routine.remindersEnabled &&
        occurrence.status == RoutineOccurrenceStatus.pending &&
        occurrence.scheduledStart != null &&
        occurrence.scheduledStart!.isAfter(now);
  }
}
