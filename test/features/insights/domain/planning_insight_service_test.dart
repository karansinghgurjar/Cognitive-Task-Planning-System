import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/insights/domain/insight_fatigue_service.dart';
import 'package:study_flow/features/insights/domain/planning_insight_action_router.dart';
import 'package:study_flow/features/insights/domain/planning_insight_models.dart';
import 'package:study_flow/features/insights/domain/planning_insight_service.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  final now = DateTime(2026, 5, 12, 9);
  const service = PlanningInsightService();

  group('PlanningInsightService', () {
    test('detects daily and evening overload deterministically', () {
      final context = _context(
        now: now,
        sessions: [
          PlannedSession(
            id: 'long-day',
            taskId: 'task-1',
            start: DateTime(2026, 5, 12, 9),
            end: DateTime(2026, 5, 12, 18, 30),
          ),
          PlannedSession(
            id: 'evening',
            taskId: 'task-2',
            start: DateTime(2026, 5, 12, 18),
            end: DateTime(2026, 5, 12, 22),
          ),
        ],
        timetableSlots: [
          TimetableSlot(
            id: 'busy',
            weekday: DateTime.tuesday,
            startHour: 8,
            startMinute: 0,
            endHour: 12,
            endMinute: 0,
            isBusy: true,
            label: 'College',
          ),
        ],
      );

      final insights = service.generateInsights(context);

      expect(
        insights.where((item) => item.type == InsightType.overload),
        isNotEmpty,
      );
      expect(
        insights.any((item) => item.id.startsWith('evening-overload')),
        isTrue,
      );
    });

    test('generates missed-pattern and routine timing suggestions', () {
      final routine = _routine(
        id: 'dsa',
        title: 'DSA Practice',
        startMinute: 22 * 60,
        duration: 80,
      );
      final context = _context(
        now: now,
        routines: [routine],
        occurrences: List.generate(4, (index) {
          final day = now.subtract(Duration(days: index + 1));
          return _occurrence(
            id: 'missed-$index',
            routineId: routine.id,
            day: day,
            status: RoutineOccurrenceStatus.missed,
            missedAt: day.add(const Duration(hours: 23)),
          );
        }),
      );

      final insights = service.generateInsights(context);

      final missed = insights.where(
        (item) => item.type == InsightType.missedRoutine,
      );
      final timing = insights.where(
        (item) => item.type == InsightType.routineTiming,
      );
      expect(missed, isNotEmpty);
      expect(timing, isNotEmpty);
      expect(timing.first.actions.first.suggestedStartMinuteOfDay, 20 * 60);
      expect(
        missed.first.actions.any(
          (action) => action.type == InsightActionType.reduceRoutineDuration,
        ),
        isTrue,
      );
    });

    test('generates goal-risk insight for approaching unsupported goal', () {
      final goal = LearningGoal(
        id: 'exam',
        title: 'Exam Prep',
        priority: 1,
        targetDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 20)),
      );
      final context = _context(
        now: now,
        goals: [goal],
        tasks: [
          Task(
            id: 'task',
            title: 'Revise graphs',
            type: TaskType.study,
            estimatedDurationMinutes: 90,
            priority: 1,
            goalId: goal.id,
            createdAt: now,
          ),
        ],
      );

      final insights = service.generateInsights(context);

      expect(insights.any((item) => item.type == InsightType.goalRisk), isTrue);
      expect(
        insights
            .firstWhere((item) => item.type == InsightType.goalRisk)
            .relatedGoalId,
        goal.id,
      );
    });

    test('detects positive routine patterns without making them noisy', () {
      final routine = _routine(id: 'reading', title: 'Research Reading');
      final context = _context(
        now: now,
        routines: [routine],
        occurrences: List.generate(5, (index) {
          final day = now.subtract(Duration(days: index + 1));
          return _occurrence(
            id: 'done-$index',
            routineId: routine.id,
            day: day,
            status: RoutineOccurrenceStatus.completed,
            completedAt: day.add(const Duration(hours: 8)),
          );
        }),
      );

      final insights = service.generateInsights(context);
      final positive = insights.where(
        (item) => item.type == InsightType.positivePattern,
      );

      expect(positive, isNotEmpty);
      expect(positive.first.severity, InsightSeverity.info);
      expect(positive.first.actions, isEmpty);
    });

    test('dedupes insights by id and keeps the highest severity', () {
      final low = _insight(id: 'same', severity: InsightSeverity.info);
      final warning = _insight(id: 'same', severity: InsightSeverity.warning);

      final deduped = service.dedupeInsights([low, warning]);

      expect(deduped, hasLength(1));
      expect(deduped.single.severity, InsightSeverity.warning);
    });

    test('builds weekly routine intelligence summary correctly', () {
      final weekStart = DateTime(2026, 5, 11);
      final consistent = _routine(id: 'study', title: 'Study Block');
      final fragile = _routine(id: 'fitness', title: 'Fitness');
      final summary = service.buildWeeklyRoutineSummary(
        weekStart: weekStart,
        routines: [consistent, fragile],
        occurrences: [
          _occurrence(
            id: 'c1',
            routineId: consistent.id,
            day: weekStart,
            status: RoutineOccurrenceStatus.completed,
            completedAt: weekStart.add(const Duration(hours: 8)),
          ),
          _occurrence(
            id: 'c2',
            routineId: consistent.id,
            day: weekStart.add(const Duration(days: 1)),
            status: RoutineOccurrenceStatus.completed,
            completedAt: weekStart.add(const Duration(days: 1, hours: 8)),
          ),
          _occurrence(
            id: 'm1',
            routineId: fragile.id,
            day: weekStart,
            status: RoutineOccurrenceStatus.missed,
            missedAt: weekStart.add(const Duration(hours: 23)),
          ),
          _occurrence(
            id: 'r1',
            routineId: fragile.id,
            day: weekStart.add(const Duration(days: 2)),
            isRecoveryInstance: true,
          ),
        ],
        insights: [_insight(id: 'overload', type: InsightType.overload)],
        now: now,
      );

      expect(summary.completedRoutineCount, 2);
      expect(summary.missedRoutineCount, 1);
      expect(summary.recoveryLoad, 1);
      expect(summary.overloadedDayCount, 1);
      expect(summary.mostConsistentRoutineTitle, 'Study Block');
      expect(summary.mostFragileRoutineTitle, 'Fitness');
    });
  });

  group('InsightFatigueService', () {
    test(
      'filters dismissed, snoozed, cooldown, and disabled type insights',
      () {
        const fatigue = InsightFatigueService(
          defaultCooldown: Duration(days: 7),
        );
        final insight = _insight(
          id: 'missed',
          type: InsightType.missedRoutine,
          routineId: 'routine-1',
        );
        final dismissed = fatigue.dismiss(
          const InsightSuppressionState(),
          insight,
          now,
        );

        expect(
          fatigue.filterInsights(
            insights: [insight],
            suppression: dismissed,
            now: now.add(const Duration(days: 1)),
          ),
          isEmpty,
        );

        final snoozed = fatigue.snooze(
          const InsightSuppressionState(),
          insight,
          now.add(const Duration(days: 3)),
        );
        expect(
          fatigue.filterInsights(
            insights: [insight],
            suppression: snoozed,
            now: now.add(const Duration(days: 1)),
          ),
          isEmpty,
        );

        final disabled = fatigue.disableTypeForEntity(
          const InsightSuppressionState(),
          insight,
        );
        expect(
          fatigue.filterInsights(
            insights: [insight],
            suppression: disabled,
            now: now,
          ),
          isEmpty,
        );
      },
    );
  });

  group('PlanningInsightActionRouter', () {
    test('routes risky suggestions to confirmation-required destinations', () {
      const router = PlanningInsightActionRouter();
      const action = InsightAction(
        id: 'shift',
        type: InsightActionType.shiftRoutineTime,
        label: 'Shift Time',
        routineId: 'routine-1',
        suggestedStartMinuteOfDay: 20 * 60,
      );

      final route = router.routeFor(action);

      expect(route.destination, InsightActionDestination.routineEditor);
      expect(route.requiresConfirmation, isTrue);
      expect(route.suggestedStartMinuteOfDay, 20 * 60);
    });

    test('routes passive navigation without confirmation', () {
      const router = PlanningInsightActionRouter();
      const action = InsightAction(
        id: 'planner',
        type: InsightActionType.openPlanner,
        label: 'Open Planner',
        requiresConfirmation: false,
      );

      final route = router.routeFor(action);

      expect(route.destination, InsightActionDestination.planner);
      expect(route.requiresConfirmation, isFalse);
    });
  });
}

PlanningInsightContext _context({
  required DateTime now,
  List<Routine> routines = const [],
  List<RoutineOccurrence> occurrences = const [],
  List<Task> tasks = const [],
  List<PlannedSession> sessions = const [],
  List<LearningGoal> goals = const [],
  List<TimetableSlot> timetableSlots = const [],
}) {
  return PlanningInsightContext(
    routines: routines,
    occurrences: occurrences,
    tasks: tasks,
    sessions: sessions,
    goals: goals,
    timetableSlots: timetableSlots,
    now: now,
  );
}

Routine _routine({
  required String id,
  required String title,
  int startMinute = 8 * 60,
  int duration = 45,
  String? goalId,
}) {
  final createdAt = DateTime(2026, 4, 1);
  return Routine(
    id: id,
    title: title,
    createdAt: createdAt,
    anchorDate: createdAt,
    repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
    preferredStartMinuteOfDay: startMinute,
    preferredDurationMinutes: duration,
    linkedGoalId: goalId,
  );
}

RoutineOccurrence _occurrence({
  required String id,
  required String routineId,
  required DateTime day,
  RoutineOccurrenceStatus status = RoutineOccurrenceStatus.pending,
  DateTime? completedAt,
  DateTime? missedAt,
  bool isRecoveryInstance = false,
}) {
  return RoutineOccurrence(
    id: id,
    routineId: routineId,
    occurrenceDate: day,
    scheduledStart: DateTime(day.year, day.month, day.day, 8),
    scheduledEnd: DateTime(day.year, day.month, day.day, 9),
    status: status,
    createdAt: day,
    updatedAt: day,
    completedAt: completedAt,
    missedAt: missedAt,
    isRecoveryInstance: isRecoveryInstance,
  );
}

PlanningInsight _insight({
  required String id,
  InsightType type = InsightType.overload,
  InsightSeverity severity = InsightSeverity.suggestion,
  String? routineId,
}) {
  return PlanningInsight(
    id: id,
    type: type,
    severity: severity,
    title: 'Insight',
    message: 'Message',
    actions: const [],
    createdAt: DateTime(2026, 5, 12),
    reason: 'Reason',
    relatedRoutineId: routineId,
  );
}
