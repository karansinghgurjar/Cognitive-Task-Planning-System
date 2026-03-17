import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/domain/goal_task_generation_service.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('GoalTaskGenerationService', () {
    test('generates one task per incomplete milestone in milestone order', () {
      final service = GoalTaskGenerationService(
        idGenerator: _sequentialIdGenerator(),
        nowProvider: () => DateTime(2026, 3, 16, 9),
      );
      final goal = LearningGoal(
        id: 'goal-1',
        title: 'Learn Flutter',
        goalType: GoalType.learning,
        targetDate: DateTime(2026, 3, 30),
        priority: 2,
        estimatedTotalMinutes: 300,
        createdAt: DateTime(2026, 3, 1),
      );
      final milestones = [
        GoalMilestone(
          id: 'm2',
          goalId: goal.id,
          title: 'State management',
          sequenceOrder: 2,
          estimatedMinutes: 90,
          createdAt: DateTime(2026, 3, 2),
        ),
        GoalMilestone(
          id: 'm1',
          goalId: goal.id,
          title: 'Widgets basics',
          sequenceOrder: 1,
          estimatedMinutes: 60,
          createdAt: DateTime(2026, 3, 1),
        ),
        GoalMilestone(
          id: 'm3',
          goalId: goal.id,
          title: 'Animations',
          sequenceOrder: 3,
          estimatedMinutes: 45,
          isCompleted: true,
          createdAt: DateTime(2026, 3, 3),
        ),
      ];

      final tasks = service.generateTasksForGoal(goal, milestones);

      expect(tasks.map((task) => task.title), [
        'Learn Flutter: Widgets basics',
        'Learn Flutter: State management',
      ]);
      expect(tasks.map((task) => task.milestoneId), ['m1', 'm2']);
      expect(tasks.map((task) => task.goalId), [goal.id, goal.id]);
      expect(tasks.map((task) => task.type), [TaskType.study, TaskType.study]);
      expect(tasks.map((task) => task.dueDate), [
        goal.targetDate,
        goal.targetDate,
      ]);
    });

    test('generates one coarse task when a goal has no milestones', () {
      final service = GoalTaskGenerationService(
        idGenerator: () => 'task-1',
        nowProvider: () => DateTime(2026, 3, 16, 9),
      );
      final goal = LearningGoal(
        id: 'goal-1',
        title: 'Build portfolio app',
        goalType: GoalType.project,
        priority: 1,
        estimatedTotalMinutes: 180,
        createdAt: DateTime(2026, 3, 1),
      );

      final tasks = service.generateTasksForGoal(goal, const []);

      expect(tasks, hasLength(1));
      expect(tasks.single.title, 'Build portfolio app');
      expect(tasks.single.goalId, goal.id);
      expect(tasks.single.milestoneId, isNull);
      expect(tasks.single.estimatedDurationMinutes, 180);
      expect(tasks.single.type, TaskType.project);
    });
  });
}

String Function() _sequentialIdGenerator() {
  var counter = 0;
  return () {
    counter += 1;
    return 'task-$counter';
  };
}
