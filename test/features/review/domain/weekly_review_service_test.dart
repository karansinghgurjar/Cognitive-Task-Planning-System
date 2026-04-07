import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/review/domain/weekly_review_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('WeeklyReviewService', () {
    const service = WeeklyReviewService();

    test('buildWeeklySnapshot computes completion metrics and top items', () {
      final weekStart = DateTime(2026, 4, 6);
      final goal = LearningGoal(
        id: 'goal-1',
        title: 'DSA Mastery',
        priority: 1,
        targetDate: DateTime(2026, 4, 15),
        createdAt: DateTime(2026, 4, 1),
      );
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Arrays practice',
          type: TaskType.study,
          estimatedDurationMinutes: 90,
          priority: 1,
          goalId: goal.id,
          createdAt: DateTime(2026, 4, 1),
        ),
        Task(
          id: 'task-2',
          title: 'Graphs revision',
          type: TaskType.study,
          estimatedDurationMinutes: 60,
          priority: 2,
          createdAt: DateTime(2026, 4, 1),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-1',
          start: DateTime(2026, 4, 7, 10),
          end: DateTime(2026, 4, 7, 11),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 55,
        ),
        PlannedSession(
          id: 'session-2',
          taskId: 'task-2',
          start: DateTime(2026, 4, 8, 10),
          end: DateTime(2026, 4, 8, 11),
          status: PlannedSessionStatus.missed,
        ),
        PlannedSession(
          id: 'session-3',
          taskId: 'task-2',
          start: DateTime(2026, 4, 9, 10),
          end: DateTime(2026, 4, 9, 11),
          status: PlannedSessionStatus.cancelled,
        ),
      ];

      final snapshot = service.buildWeeklySnapshot(
        weekStart: weekStart,
        sessions: sessions,
        tasks: tasks,
        goals: [goal],
      );

      expect(snapshot.breakdown.totalPlannedMinutes, 180);
      expect(snapshot.breakdown.totalCompletedMinutes, 55);
      expect(snapshot.breakdown.completedSessionsCount, 1);
      expect(snapshot.breakdown.missedSessionsCount, 1);
      expect(snapshot.breakdown.cancelledSessionsCount, 1);
      expect(snapshot.topGoalTitle, 'DSA Mastery');
      expect(snapshot.topTaskTitle, 'Arrays practice');
    });

    test('buildGoalReview aggregates minutes and completed linked tasks', () {
      final weekStart = DateTime(2026, 4, 6);
      final goal = LearningGoal(
        id: 'goal-1',
        title: 'Flutter App',
        goalType: GoalType.project,
        priority: 1,
        createdAt: DateTime(2026, 4, 1),
      );
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Set up state',
          type: TaskType.coding,
          estimatedDurationMinutes: 120,
          priority: 1,
          goalId: goal.id,
          createdAt: DateTime(2026, 4, 1),
          isCompleted: true,
          completedAt: DateTime(2026, 4, 8, 12),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-1',
          start: DateTime(2026, 4, 8, 9),
          end: DateTime(2026, 4, 8, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 60,
        ),
      ];

      final reviews = service.buildGoalReview(
        weekStart: weekStart,
        sessions: sessions,
        tasks: tasks,
        goals: [goal],
      );

      expect(reviews, hasLength(1));
      expect(reviews.single.minutesSpent, 60);
      expect(reviews.single.completedLinkedTasksThisWeek, 1);
      expect(reviews.single.totalLinkedTasks, 1);
    });

    test('buildTaskReview detects repeated slips and overdue tasks safely', () {
      final weekStart = DateTime(2026, 4, 6);
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Old task',
          type: TaskType.reading,
          estimatedDurationMinutes: 45,
          priority: 2,
          dueDate: DateTime(2026, 4, 5),
          createdAt: DateTime(2026, 4, 1),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-1',
          start: DateTime(2026, 4, 7, 9),
          end: DateTime(2026, 4, 7, 10),
          status: PlannedSessionStatus.missed,
        ),
        PlannedSession(
          id: 'session-2',
          taskId: 'task-1',
          start: DateTime(2026, 4, 8, 9),
          end: DateTime(2026, 4, 8, 10),
          status: PlannedSessionStatus.cancelled,
        ),
        PlannedSession(
          id: 'session-3',
          taskId: 'missing-task',
          start: DateTime(2026, 4, 9, 9),
          end: DateTime(2026, 4, 9, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 50,
        ),
      ];

      final reviews = service.buildTaskReview(
        weekStart: weekStart,
        sessions: sessions,
        tasks: tasks,
      );

      final oldTask = reviews.firstWhere((review) => review.taskId == 'task-1');
      final deletedTask = reviews.firstWhere(
        (review) => review.taskId == 'missing-task',
      );

      expect(oldTask.slipCount, 2);
      expect(oldTask.isOverdue, isTrue);
      expect(deletedTask.taskTitle, 'Deleted Task');
      expect(deletedTask.completedMinutes, 50);
    });

    test('buildTrendComparison compares against previous week', () {
      final current = service.buildWeeklySnapshot(
        weekStart: DateTime(2026, 4, 6),
        sessions: [
          PlannedSession(
            id: 'session-1',
            taskId: 'task-1',
            start: DateTime(2026, 4, 7, 9),
            end: DateTime(2026, 4, 7, 10),
            status: PlannedSessionStatus.completed,
            completed: true,
            actualMinutesFocused: 60,
          ),
        ],
        tasks: [
          Task(
            id: 'task-1',
            title: 'Task',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        goals: const [],
      );
      final previous = service.buildWeeklySnapshot(
        weekStart: DateTime(2026, 3, 30),
        sessions: [
          PlannedSession(
            id: 'session-2',
            taskId: 'task-1',
            start: DateTime(2026, 3, 31, 9),
            end: DateTime(2026, 3, 31, 10),
            status: PlannedSessionStatus.missed,
          ),
        ],
        tasks: [
          Task(
            id: 'task-1',
            title: 'Task',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        goals: const [],
      );

      final comparison = service.buildTrendComparison(
        current: current,
        previous: previous,
      );

      expect(comparison.completedMinutesDelta, 60);
      expect(comparison.missedSessionsDelta, -1);
    });
  });
}
