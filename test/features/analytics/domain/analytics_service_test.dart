import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/analytics_models.dart';
import 'package:study_flow/features/analytics/domain/analytics_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('AnalyticsService', () {
    const service = AnalyticsService();

    test('computeDailyStats aggregates planned and completed minutes', () {
      final goals = [
        LearningGoal(
          id: 'goal-1',
          title: 'Learn Flutter',
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Widgets',
          type: TaskType.study,
          estimatedDurationMinutes: 60,
          priority: 1,
          goalId: 'goal-1',
          createdAt: DateTime(2026, 3, 1),
        ),
        Task(
          id: 'task-2',
          title: 'Layouts',
          type: TaskType.coding,
          estimatedDurationMinutes: 70,
          priority: 2,
          goalId: 'goal-1',
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 's1',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 50,
        ),
        PlannedSession(
          id: 's2',
          taskId: 'task-2',
          start: DateTime(2026, 3, 16, 11),
          end: DateTime(2026, 3, 16, 11, 40),
          status: PlannedSessionStatus.pending,
        ),
        PlannedSession(
          id: 's3',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 13),
          end: DateTime(2026, 3, 16, 13, 30),
          status: PlannedSessionStatus.missed,
        ),
      ];

      final stats = service.computeDailyStats(
        day: DateTime(2026, 3, 16, 20),
        tasks: tasks,
        goals: goals,
        sessions: sessions,
      );

      expect(stats.plannedMinutes, 130);
      expect(stats.completedMinutes, 50);
      expect(stats.completedSessions, 1);
      expect(stats.missedSessions, 1);
      expect(stats.cancelledSessions, 0);
      expect(stats.completionRate, closeTo(50 / 130, 0.0001));
      expect(stats.topTaskTitle, 'Widgets');
      expect(stats.topGoalTitle, 'Learn Flutter');
    });

    test('computeWeeklyStats summarizes the local week', () {
      final sessions = [
        PlannedSession(
          id: 'monday',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 60,
        ),
        PlannedSession(
          id: 'tuesday',
          taskId: 'task-2',
          start: DateTime(2026, 3, 17, 9),
          end: DateTime(2026, 3, 17, 9, 30),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 30,
        ),
        PlannedSession(
          id: 'thursday',
          taskId: 'task-3',
          start: DateTime(2026, 3, 19, 14),
          end: DateTime(2026, 3, 19, 15, 30),
          status: PlannedSessionStatus.pending,
        ),
        PlannedSession(
          id: 'friday',
          taskId: 'task-4',
          start: DateTime(2026, 3, 20, 10),
          end: DateTime(2026, 3, 20, 10, 30),
          status: PlannedSessionStatus.missed,
        ),
      ];

      final stats = service.computeWeeklyStats(
        sessions: sessions,
        now: DateTime(2026, 3, 18, 12),
      );

      expect(stats.weekStart, DateTime(2026, 3, 16));
      expect(stats.plannedMinutes, 210);
      expect(stats.completedMinutes, 90);
      expect(stats.completedSessions, 2);
      expect(stats.missedSessions, 1);
      expect(stats.cancelledSessions, 0);
      expect(stats.completionRate, closeTo(90 / 210, 0.0001));
      expect(stats.averageCompletedMinutesPerDay, closeTo(90 / 7, 0.0001));
      expect(stats.busiestDay, DateTime(2026, 3, 19));
      expect(stats.mostProductiveDay, DateTime(2026, 3, 16));
      expect(stats.leastProductiveDay, DateTime(2026, 3, 18));
    });

    test('filterSessionsForRange respects last 7 days boundaries', () {
      final sessions = [
        PlannedSession(
          id: 'old',
          taskId: 'task-1',
          start: DateTime(2026, 3, 9, 9),
          end: DateTime(2026, 3, 9, 10),
        ),
        PlannedSession(
          id: 'included-start',
          taskId: 'task-1',
          start: DateTime(2026, 3, 10, 9),
          end: DateTime(2026, 3, 10, 10),
        ),
        PlannedSession(
          id: 'included-end',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
        ),
        PlannedSession(
          id: 'future',
          taskId: 'task-1',
          start: DateTime(2026, 3, 17, 9),
          end: DateTime(2026, 3, 17, 10),
        ),
      ];

      final filtered = service.filterSessionsForRange(
        sessions: sessions,
        preset: AnalyticsRangePreset.last7Days,
        now: DateTime(2026, 3, 16, 18),
      );

      expect(filtered.map((session) => session.id), [
        'included-start',
        'included-end',
      ]);
    });
  });
}
