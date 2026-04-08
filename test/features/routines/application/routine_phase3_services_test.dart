import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/routines/application/routine_consistency_service.dart';
import 'package:study_flow/features/routines/application/routine_goal_link_service.dart';
import 'package:study_flow/features/routines/application/routine_recovery_service.dart';
import 'package:study_flow/features/routines/application/routine_scheduler_integration_service.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('RoutineSchedulerIntegrationService', () {
    final service = const RoutineSchedulerIntegrationService();

    test('fixed routine stays at preferred time', () {
      final routine = Routine(
        id: 'routine-1',
        title: 'Workout',
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        preferredStartMinuteOfDay: 18 * 60,
        preferredDurationMinutes: 60,
        isFlexible: false,
      );
      final occurrence = RoutineOccurrence(
        id: 'occ-1',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 9),
        createdAt: DateTime(2026, 4, 9, 8),
      );

      final result = service.integrate(
        routines: [routine],
        occurrences: [occurrence],
        weeklyAvailability: {
          DateTime.thursday: [
            const AvailabilityWindow(
              weekday: DateTime.thursday,
              startHour: 6,
              startMinute: 0,
              endHour: 23,
              endMinute: 0,
            ),
          ],
        },
        plannedSessions: const [],
        startDate: DateTime(2026, 4, 9),
        endDate: DateTime(2026, 4, 9),
        now: DateTime(2026, 4, 9, 9),
      );

      expect(result.updatedOccurrences.single.scheduledStart, DateTime(2026, 4, 9, 18));
      expect(result.updatedOccurrences.single.needsAttention, isFalse);
    });

    test('flexible routine is placed in nearest valid free slot', () {
      final routine = Routine(
        id: 'routine-1',
        title: 'Reading',
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        preferredStartMinuteOfDay: 20 * 60,
        preferredDurationMinutes: 60,
        timeWindowStartMinuteOfDay: 19 * 60,
        timeWindowEndMinuteOfDay: 22 * 60,
      );
      final occurrence = RoutineOccurrence(
        id: 'occ-1',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 9),
        createdAt: DateTime(2026, 4, 9, 8),
      );

      final result = service.integrate(
        routines: [routine],
        occurrences: [occurrence],
        weeklyAvailability: {
          DateTime.thursday: [
            const AvailabilityWindow(
              weekday: DateTime.thursday,
              startHour: 18,
              startMinute: 0,
              endHour: 23,
              endMinute: 0,
            ),
          ],
        },
        plannedSessions: [
          PlannedSession(
            id: 'task-1',
            taskId: 'task-1',
            start: DateTime(2026, 4, 9, 19),
            end: DateTime(2026, 4, 9, 20),
          ),
        ],
        startDate: DateTime(2026, 4, 9),
        endDate: DateTime(2026, 4, 9),
        now: DateTime(2026, 4, 9, 9),
      );

      expect(result.updatedOccurrences.single.scheduledStart, DateTime(2026, 4, 9, 20));
      expect(result.updatedOccurrences.single.isAutoScheduled, isTrue);
    });

    test('no placement when no valid slot exists', () {
      final routine = Routine(
        id: 'routine-1',
        title: 'Project',
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        preferredDurationMinutes: 120,
      );
      final occurrence = RoutineOccurrence(
        id: 'occ-1',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 9),
        createdAt: DateTime(2026, 4, 9, 8),
      );

      final result = service.integrate(
        routines: [routine],
        occurrences: [occurrence],
        weeklyAvailability: {
          DateTime.thursday: [
            const AvailabilityWindow(
              weekday: DateTime.thursday,
              startHour: 18,
              startMinute: 0,
              endHour: 18,
              endMinute: 30,
            ),
          ],
        },
        plannedSessions: const [],
        startDate: DateTime(2026, 4, 9),
        endDate: DateTime(2026, 4, 9),
        now: DateTime(2026, 4, 9, 9),
      );

      expect(result.updatedOccurrences.single.needsAttention, isTrue);
      expect(result.unscheduledOccurrences, hasLength(1));
    });
  });

  group('RoutineRecoveryService', () {
    final service = RoutineRecoveryService();

    test('untimed past pending occurrence becomes missed', () {
      final occurrence = RoutineOccurrence(
        id: 'occ-1',
        routineId: 'routine-1',
        occurrenceDate: DateTime(2026, 4, 8),
        createdAt: DateTime(2026, 4, 8, 8),
      );

      final updates = service.detectMissedOccurrences(
        occurrences: [occurrence],
        now: DateTime(2026, 4, 9, 12),
      );

      expect(updates.single.status, RoutineOccurrenceStatus.missed);
      expect(updates.single.missedAt, DateTime(2026, 4, 9, 12));
    });

    test('recovery suggestions avoid duplicates when recovery already exists', () {
      final routine = Routine(
        id: 'routine-1',
        title: 'Reading',
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        preferredStartMinuteOfDay: 20 * 60,
        autoRescheduleMissed: true,
      );
      final missed = RoutineOccurrence(
        id: 'occ-1',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 8),
        status: RoutineOccurrenceStatus.missed,
        createdAt: DateTime(2026, 4, 8, 8),
        missedAt: DateTime(2026, 4, 8, 22),
      );
      final recovery = RoutineOccurrence(
        id: 'occ-2',
        routineId: routine.id,
        occurrenceDate: DateTime(2026, 4, 9),
        createdAt: DateTime(2026, 4, 9, 8),
        isRecoveryInstance: true,
        recoveredFromOccurrenceId: missed.id,
      );

      final suggestions = service.buildRecoverySuggestions(
        routines: [routine],
        occurrences: [missed, recovery],
        now: DateTime(2026, 4, 9, 10),
      );

      expect(suggestions, isEmpty);
    });
  });

  test('RoutineGoalLinkService computes positive contribution safely', () {
    final goal = LearningGoal(
      id: 'goal-1',
      title: 'M.Tech Thesis',
      priority: 1,
      createdAt: DateTime(2026, 4, 1),
    );
    final routine = Routine(
      id: 'routine-1',
      title: 'Reading',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      linkedGoalId: goal.id,
      preferredDurationMinutes: 45,
    );
    final contribution = const RoutineGoalLinkService().contributionForGoal(
      goal: goal,
      routines: [routine],
      occurrences: [
        RoutineOccurrence(
          id: 'occ-1',
          routineId: routine.id,
          occurrenceDate: DateTime(2026, 4, 8),
          status: RoutineOccurrenceStatus.completed,
          createdAt: DateTime(2026, 4, 8, 8),
          completedAt: DateTime(2026, 4, 8, 9),
          scheduledStart: DateTime(2026, 4, 8, 8),
          scheduledEnd: DateTime(2026, 4, 8, 8, 45),
        ),
      ],
    );

    expect(contribution, isNotNull);
    expect(contribution!.completedOccurrenceCount, 1);
    expect(contribution.completedMinutes, 45);
  });

  test('RoutineConsistencyService computes rate excluding pending items', () {
    final routine = Routine(
      id: 'routine-1',
      title: 'Workout',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      preferredDurationMinutes: 60,
    );
    final summary = const RoutineConsistencyService().summarize(
      routine: routine,
      occurrences: [
        RoutineOccurrence(
          id: 'c1',
          routineId: routine.id,
          occurrenceDate: DateTime(2026, 4, 7),
          status: RoutineOccurrenceStatus.completed,
          createdAt: DateTime(2026, 4, 7, 8),
          completedAt: DateTime(2026, 4, 7, 9),
          scheduledStart: DateTime(2026, 4, 7, 8),
          scheduledEnd: DateTime(2026, 4, 7, 9),
        ),
        RoutineOccurrence(
          id: 's1',
          routineId: routine.id,
          occurrenceDate: DateTime(2026, 4, 8),
          status: RoutineOccurrenceStatus.skipped,
          createdAt: DateTime(2026, 4, 8, 8),
        ),
        RoutineOccurrence(
          id: 'p1',
          routineId: routine.id,
          occurrenceDate: DateTime(2026, 4, 9),
          createdAt: DateTime(2026, 4, 9, 8),
        ),
      ],
      now: DateTime(2026, 4, 9, 12),
      range: RoutineAnalyticsRange.last7Days,
    );

    expect(summary.completedCount, 1);
    expect(summary.skippedCount, 1);
    expect(summary.pendingCount, 1);
    expect(summary.completionRate, 0.5);
    expect(summary.totalCompletedMinutes, 60);
  });
}
