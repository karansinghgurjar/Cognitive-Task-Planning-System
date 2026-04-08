import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/application/routine_diagnostics_service.dart';
import 'package:study_flow/features/routines/application/routine_history_policy_service.dart';
import 'package:study_flow/features/routines/application/routine_sync_readiness_service.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_group.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/routines/models/routine_template.dart';

void main() {
  group('RoutineHistoryPolicyService', () {
    test('active and recent windows stay bounded and deterministic', () {
      const service = RoutineHistoryPolicyService(
        activePlanningHorizonDays: 30,
        recentHistoryDays: 60,
      );
      final now = DateTime(2026, 4, 9, 14, 30);

      final active = service.activePlanningWindow(now: now);
      final recent = service.recentHistoryWindow(now: now);

      expect(active.startDate, DateTime(2026, 4, 2));
      expect(active.endDate, DateTime(2026, 5, 9));
      expect(recent.startDate, DateTime(2026, 2, 8));
      expect(recent.endDate, DateTime(2026, 5, 9));
    });
  });

  group('RoutineDiagnosticsService', () {
    test('diagnostics snapshot reports stable counts and duration', () {
      const service = RoutineDiagnosticsService();
      final snapshot = service.summarize(
        startedAt: DateTime(2026, 4, 9, 10, 0, 0),
        finishedAt: DateTime(2026, 4, 9, 10, 0, 2),
        scannedOccurrences: 42,
        missedMarked: 3,
        recoverySuggestions: 2,
        autoScheduled: 10,
        unscheduled: 1,
        remindersScheduled: 8,
        remindersCancelled: 4,
        notes: const ['bounded window'],
      );

      expect(snapshot.duration.inSeconds, 2);
      expect(snapshot.scannedOccurrences, 42);
      expect(snapshot.notes.single, 'bounded window');
    });
  });

  group('RoutineSyncReadinessService', () {
    test('descriptors preserve stable ids and merge rules for routine entities', () {
      const service = RoutineSyncReadinessService();
      final routine = Routine(
        id: 'routine-1',
        title: 'Deep Work',
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 9),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(),
      );
      final occurrence = RoutineOccurrence(
        id: 'occ-1',
        routineId: 'routine-1',
        occurrenceDate: DateTime(2026, 4, 9),
        createdAt: DateTime(2026, 4, 1),
      );
      final template = RoutineTemplate(
        id: 'template-1',
        name: 'Study Template',
        createdAt: DateTime(2026, 4, 1),
      );
      final group = RoutineGroup(
        id: 'group-1',
        name: 'Study System',
        createdAt: DateTime(2026, 4, 1),
      );

      final routineDescriptor = service.describeRoutine(routine);
      final occurrenceDescriptor = service.describeOccurrence(occurrence);
      final templateDescriptor = service.describeTemplate(template);
      final groupDescriptor = service.describeGroup(group);

      expect(routineDescriptor.stableId, 'routine-1');
      expect(occurrenceDescriptor.stableId, occurrence.occurrenceKey);
      expect(templateDescriptor.conflictStrategy, contains('Last-write-wins'));
      expect(groupDescriptor.tombstoneStrategy, contains('Group deletion'));
    });
  });
}
