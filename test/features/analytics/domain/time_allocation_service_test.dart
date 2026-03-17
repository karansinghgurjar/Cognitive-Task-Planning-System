import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/time_allocation_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('TimeAllocationService', () {
    const service = TimeAllocationService();

    test('aggregates completed time by task type', () {
      final tasks = [
        Task(
          id: 'study-task',
          title: 'Read notes',
          type: TaskType.study,
          estimatedDurationMinutes: 60,
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
        Task(
          id: 'coding-task',
          title: 'Build UI',
          type: TaskType.coding,
          estimatedDurationMinutes: 90,
          priority: 2,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final sessions = [
        _completed('s1', 'study-task', 40),
        _completed('s2', 'coding-task', 80),
        _completed('s3', 'coding-task', 20),
      ];

      final breakdown = service.byTaskType(tasks: tasks, sessions: sessions);

      expect(breakdown.totalMinutes, 140);
      expect(breakdown.items.first.label, 'Coding');
      expect(breakdown.items.first.minutes, 100);
      expect(breakdown.items.first.percentage, closeTo(100 / 140, 0.0001));
      expect(breakdown.items.last.label, 'Study');
      expect(breakdown.items.last.minutes, 40);
    });

    test('aggregates completed time by goal type', () {
      final goals = [
        LearningGoal(
          id: 'goal-1',
          title: 'Flutter',
          goalType: GoalType.learning,
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
        LearningGoal(
          id: 'goal-2',
          title: 'Project',
          goalType: GoalType.project,
          priority: 2,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Widget basics',
          type: TaskType.study,
          estimatedDurationMinutes: 60,
          priority: 1,
          goalId: 'goal-1',
          createdAt: DateTime(2026, 3, 1),
        ),
        Task(
          id: 'task-2',
          title: 'Prototype screen',
          type: TaskType.project,
          estimatedDurationMinutes: 60,
          priority: 2,
          goalId: 'goal-2',
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final sessions = [
        _completed('a', 'task-1', 30),
        _completed('b', 'task-2', 60),
      ];

      final breakdown = service.byGoalType(
        goals: goals,
        tasks: tasks,
        sessions: sessions,
      );

      expect(breakdown.totalMinutes, 90);
      expect(breakdown.items.first.label, 'Project');
      expect(breakdown.items.last.label, 'Learning');
    });
  });
}

PlannedSession _completed(String id, String taskId, int actualMinutes) {
  return PlannedSession(
    id: id,
    taskId: taskId,
    start: DateTime(2026, 3, 16, 9),
    end: DateTime(2026, 3, 16, 9).add(Duration(minutes: actualMinutes)),
    status: PlannedSessionStatus.completed,
    completed: true,
    actualMinutesFocused: actualMinutes,
  );
}
