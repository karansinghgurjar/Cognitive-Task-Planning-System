import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/notifications/notification_service.dart';
import 'package:study_flow/features/routines/application/routine_reconciliation_service.dart';
import 'package:study_flow/features/routines/application/routine_recovery_service.dart';
import 'package:study_flow/features/routines/application/routine_reminder_service.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';

void main() {
  group('RoutineReconciliationService', () {
    final service = RoutineReconciliationService();

    test('title-only edits do not touch future occurrences', () {
      final previous = _buildRoutine(title: 'Reading');
      final next = previous.copyWith(title: 'Deep Reading');
      final plan = service.reconcile(
        previousRoutine: previous,
        nextRoutine: next,
        existingOccurrences: [
          _buildPendingOccurrence(
            id: 'occ-1',
            date: DateTime(2026, 4, 10),
          ),
        ],
        now: DateTime(2026, 4, 9, 9),
      );

      expect(plan.hasChanges, isFalse);
      expect(plan.shouldRunSchedulingIntegration, isFalse);
    });

    test('repeat edits reconcile future pending set without touching manual override', () {
      final previous = _buildRoutine(
        title: 'Workout',
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      );
      final next = previous.copyWith(
        repeatRule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: [DateTime.monday],
        ),
      );
      final plan = service.reconcile(
        previousRoutine: previous,
        nextRoutine: next,
        existingOccurrences: [
          _buildPendingOccurrence(
            id: 'fri',
            date: DateTime(2026, 4, 10),
          ),
          _buildPendingOccurrence(
            id: 'mon-manual',
            date: DateTime(2026, 4, 13),
            isManualOverride: true,
          ),
        ],
        now: DateTime(2026, 4, 9, 9),
      );

      expect(plan.occurrenceIdsToRemove, contains('fri'));
      expect(plan.occurrenceIdsToRemove, isNot(contains('mon-manual')));
    });

    test('archive removes future pending pressure while preserving history', () {
      final previous = _buildRoutine(title: 'Reading');
      final next = previous.copyWith(isArchived: true);
      final plan = service.reconcile(
        previousRoutine: previous,
        nextRoutine: next,
        existingOccurrences: [
          _buildPendingOccurrence(
            id: 'future',
            date: DateTime(2026, 4, 10),
          ),
          RoutineOccurrence(
            id: 'done',
            routineId: previous.id,
            occurrenceDate: DateTime(2026, 4, 8),
            status: RoutineOccurrenceStatus.completed,
            createdAt: DateTime(2026, 4, 8, 8),
            completedAt: DateTime(2026, 4, 8, 9),
          ),
        ],
        now: DateTime(2026, 4, 9, 9),
      );

      expect(plan.occurrenceIdsToRemove, ['future']);
      expect(plan.occurrencesToUpsert, isEmpty);
    });
  });

  group('RoutineReminderService', () {
    test('eligible scheduled pending occurrence gets reminder', () async {
      final notifications = _FakeNotificationService();
      final service = RoutineReminderService(notificationService: notifications);
      final routine = _buildRoutine(
        title: 'Study',
        remindersEnabled: true,
        reminderLeadMinutes: 15,
      );
      final occurrence = _buildPendingOccurrence(
        id: 'occ-1',
        date: DateTime(2026, 4, 10),
        start: DateTime(2026, 4, 10, 18),
        end: DateTime(2026, 4, 10, 19),
      );

      await service.syncRoutineReminders(
        routines: [routine],
        occurrences: [occurrence],
        now: DateTime(2026, 4, 9, 9),
      );

      expect(notifications.scheduledOccurrenceIds, ['occ-1']);
      expect(notifications.canceledOccurrenceIds, isEmpty);
    });

    test('ineligible occurrence cancels stale reminder', () async {
      final notifications = _FakeNotificationService();
      final service = RoutineReminderService(notificationService: notifications);

      await service.syncRoutineReminders(
        routines: [
          _buildRoutine(
            title: 'Study',
            remindersEnabled: true,
            reminderLeadMinutes: 10,
          ),
        ],
        occurrences: [
          _buildPendingOccurrence(
            id: 'occ-1',
            date: DateTime(2026, 4, 10),
          ),
        ],
        now: DateTime(2026, 4, 9, 9),
      );

      expect(notifications.scheduledOccurrenceIds, isEmpty);
      expect(notifications.canceledOccurrenceIds, ['occ-1']);
    });
  });

  group('RoutineRecoveryService', () {
    test('dismissed missed occurrence does not resurface as recovery suggestion', () {
      final routine = _buildRoutine(title: 'Review', autoRescheduleMissed: true);
      final dismissed = RoutineOccurrence(
        id: 'missed',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 8),
        status: RoutineOccurrenceStatus.missed,
        createdAt: DateTime(2026, 4, 8, 8),
        missedAt: DateTime(2026, 4, 8, 22),
        recoveryDismissedAt: DateTime(2026, 4, 9, 8),
      );

      final suggestions = RoutineRecoveryService().buildRecoverySuggestions(
        routines: [routine],
        occurrences: [dismissed],
        now: DateTime(2026, 4, 9, 10),
      );

      expect(suggestions, isEmpty);
    });
  });
}

Routine _buildRoutine({
  required String title,
  RoutineRepeatRule? repeatRule,
  bool remindersEnabled = false,
  int? reminderLeadMinutes,
  bool autoRescheduleMissed = false,
}) {
  return Routine(
    id: 'routine-1',
    title: title,
    createdAt: DateTime(2026, 4, 1),
    anchorDate: DateTime(2026, 4, 1),
    repeatRule: repeatRule ?? RoutineRepeatRule(type: RoutineRepeatType.daily),
    remindersEnabled: remindersEnabled,
    reminderLeadMinutes: reminderLeadMinutes,
    autoRescheduleMissed: autoRescheduleMissed,
  );
}

RoutineOccurrence _buildPendingOccurrence({
  required String id,
  required DateTime date,
  DateTime? start,
  DateTime? end,
  bool isManualOverride = false,
}) {
  return RoutineOccurrence(
    id: id,
    routineId: 'routine-1',
    occurrenceDate: date,
    scheduledStart: start,
    scheduledEnd: end,
    createdAt: DateTime(2026, 4, 9, 8),
    isManualOverride: isManualOverride,
  );
}

class _FakeNotificationService extends NotificationService {
  final List<String> scheduledOccurrenceIds = [];
  final List<String> canceledOccurrenceIds = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleRoutineReminder({
    required String occurrenceId,
    required String routineId,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduledOccurrenceIds.add(occurrenceId);
  }

  @override
  Future<void> cancelRoutineReminder(String occurrenceId) async {
    canceledOccurrenceIds.add(occurrenceId);
  }
}
