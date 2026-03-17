import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/goal_analytics_service.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('GoalAnalyticsService', () {
    const service = GoalAnalyticsService();

    test('aggregates linked task progress and completed minutes', () {
      final goal = LearningGoal(
        id: 'goal-1',
        title: 'Learn Flutter',
        goalType: GoalType.learning,
        targetDate: DateTime(2026, 4, 15),
        priority: 1,
        createdAt: DateTime(2026, 3, 1),
      );
      final milestones = [
        GoalMilestone(
          id: 'm1',
          goalId: 'goal-1',
          title: 'Basics',
          sequenceOrder: 1,
          estimatedMinutes: 120,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Widgets',
          type: TaskType.study,
          estimatedDurationMinutes: 120,
          priority: 1,
          goalId: 'goal-1',
          createdAt: DateTime(2026, 3, 1),
        ),
        Task(
          id: 'task-2',
          title: 'Layouts',
          type: TaskType.coding,
          estimatedDurationMinutes: 60,
          priority: 2,
          goalId: 'goal-1',
          createdAt: DateTime(2026, 3, 2),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 's1',
          taskId: 'task-1',
          start: DateTime(2026, 3, 14, 9),
          end: DateTime(2026, 3, 14, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 60,
        ),
        PlannedSession(
          id: 's2',
          taskId: 'task-2',
          start: DateTime(2026, 3, 15, 9),
          end: DateTime(2026, 3, 15, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 60,
        ),
      ];
      final availability = {
        for (var weekday = 1; weekday <= 7; weekday++)
          weekday: [
            AvailabilityWindow(
              weekday: weekday,
              startHour: 18,
              startMinute: 0,
              endHour: 21,
              endMinute: 0,
            ),
          ],
      };

      final analytics = service.computeGoalAnalytics(
        goals: [goal],
        milestones: milestones,
        tasks: tasks,
        sessions: sessions,
        weeklyAvailability: availability,
        now: DateTime(2026, 3, 16, 12),
      );

      expect(analytics, hasLength(1));
      expect(analytics.single.totalLinkedTasks, 2);
      expect(analytics.single.completedLinkedTasks, 1);
      expect(analytics.single.totalPlannedMinutes, 180);
      expect(analytics.single.totalCompletedMinutes, 120);
      expect(analytics.single.percentComplete, closeTo(120 / 180, 0.0001));
      expect(analytics.single.averageMinutesPerWeekSpent, closeTo(30, 0.0001));
    });
  });
}
