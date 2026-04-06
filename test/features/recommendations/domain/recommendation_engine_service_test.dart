import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_engine_service.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('RecommendationEngineService', () {
    final service = RecommendationEngineService();
    final now = DateTime(2026, 3, 16, 8, 0);
    final weeklyAvailability = _weeklyAvailability({
      1: [
        const AvailabilityWindow(
          weekday: 1,
          startHour: 9,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
        ),
      ],
    });

    test('overdue tasks are ranked first', () {
      final recommendation = service.recommendNextTask(
        tasks: [
          _task(
            'overdue',
            priority: 3,
            minutes: 60,
            dueDate: DateTime(2026, 3, 15),
          ),
          _task(
            'soon',
            priority: 1,
            minutes: 60,
            dueDate: DateTime(2026, 3, 18),
          ),
        ],
        goals: const [],
        milestones: const [],
        dependencies: const [],
        plannedSessions: const [],
        weeklyAvailability: weeklyAvailability,
        now: now,
      );

      expect(recommendation, isNotNull);
      expect(recommendation!.taskId, 'overdue');
      expect(recommendation.riskLevel, DeadlineRiskLevel.critical);
    });

    test('blocked tasks are excluded from recommendation', () {
      final recommendation = service.recommendNextTask(
        tasks: [
          _task('prereq', priority: 2, minutes: 60),
          _task(
            'blocked',
            priority: 1,
            minutes: 60,
            dueDate: DateTime(2026, 3, 17),
          ),
        ],
        goals: const [],
        milestones: const [],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: 'blocked',
            dependsOnTaskId: 'prereq',
            createdAt: DateTime(2026, 3, 16),
          ),
        ],
        plannedSessions: const [],
        weeklyAvailability: weeklyAvailability,
        now: now,
      );

      expect(recommendation, isNotNull);
      expect(recommendation!.taskId, 'prereq');
    });

    test(
      'dependency cycles are handled gracefully by recommending an unblocked task',
      () {
        final recommendation = service.recommendNextTask(
          tasks: [
            _task('task-a', priority: 1, minutes: 60),
            _task('task-b', priority: 1, minutes: 60),
            _task('task-c', priority: 3, minutes: 60),
          ],
          goals: const [],
          milestones: const [],
          dependencies: [
            TaskDependency(
              id: 'dep-1',
              taskId: 'task-a',
              dependsOnTaskId: 'task-b',
              createdAt: DateTime(2026, 3, 16),
            ),
            TaskDependency(
              id: 'dep-2',
              taskId: 'task-b',
              dependsOnTaskId: 'task-a',
              createdAt: DateTime(2026, 3, 16),
            ),
          ],
          plannedSessions: const [],
          weeklyAvailability: weeklyAvailability,
          now: now,
        );

        expect(recommendation, isNotNull);
        expect(recommendation!.taskId, 'task-c');
      },
    );

    test('recommends the next available study block', () {
      final block = service.recommendNextAvailableBlock(
        weeklyAvailability: weeklyAvailability,
        plannedSessions: [
          PlannedSession(
            id: 'session-1',
            taskId: 'task-1',
            start: DateTime(2026, 3, 16, 9, 0),
            end: DateTime(2026, 3, 16, 10, 0),
          ),
        ],
        now: now,
        preferredDurationMinutes: 60,
      );

      expect(block, isNotNull);
      expect(block!.start, DateTime(2026, 3, 16, 10, 0));
      expect(block.end, DateTime(2026, 3, 16, 11, 0));
    });


    test('archived tasks are excluded from recommendation candidates', () {
      final recommendation = service.recommendNextTask(
        tasks: [
          _task('archived', priority: 1, minutes: 60).copyWith(
            isArchived: true,
          ),
          _task('active', priority: 2, minutes: 60),
        ],
        goals: const [],
        milestones: const [],
        dependencies: const [],
        plannedSessions: const [],
        weeklyAvailability: weeklyAvailability,
        now: now,
      );

      expect(recommendation, isNotNull);
      expect(recommendation!.taskId, 'active');
    });

    test('prefers an active planned session when one is happening now', () {
      final recommendation = service.recommendNextTask(
        tasks: [
          _task('planned', priority: 3, minutes: 60),
          _task(
            'other',
            priority: 1,
            minutes: 60,
            dueDate: DateTime(2026, 3, 17),
          ),
        ],
        goals: const [],
        milestones: const [],
        dependencies: const [],
        plannedSessions: [
          PlannedSession(
            id: 'session-1',
            taskId: 'planned',
            start: DateTime(2026, 3, 16, 7, 30),
            end: DateTime(2026, 3, 16, 8, 30),
            status: PlannedSessionStatus.inProgress,
          ),
        ],
        weeklyAvailability: weeklyAvailability,
        now: now,
      );

      expect(recommendation, isNotNull);
      expect(recommendation!.taskId, 'planned');
      expect(recommendation.relatedPlannedSessionId, 'session-1');
    });
  });
}

Task _task(
  String id, {
  required int priority,
  required int minutes,
  DateTime? dueDate,
}) {
  return Task(
    id: id,
    title: id,
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    dueDate: dueDate,
    priority: priority,
    createdAt: DateTime(2026, 3, 1),
  );
}

Map<int, List<AvailabilityWindow>> _weeklyAvailability(
  Map<int, List<AvailabilityWindow>> data,
) {
  return {
    for (var weekday = 1; weekday <= 7; weekday++)
      weekday: data[weekday] ?? const [],
  };
}


