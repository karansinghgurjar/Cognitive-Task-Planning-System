import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/domain/goal_progress_service.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('GoalProgressService', () {
    test(
      'computes progress from linked tasks and completed session minutes',
      () {
        const service = GoalProgressService();
        final goal = LearningGoal(
          id: 'goal-1',
          title: 'Prepare DSA',
          goalType: GoalType.examPrep,
          priority: 1,
          estimatedTotalMinutes: 240,
          createdAt: DateTime(2026, 3, 1),
        );
        final milestones = [
          GoalMilestone(
            id: 'm1',
            goalId: goal.id,
            title: 'Arrays',
            sequenceOrder: 1,
            estimatedMinutes: 120,
            isCompleted: true,
            createdAt: DateTime(2026, 3, 1),
            completedAt: DateTime(2026, 3, 5),
          ),
          GoalMilestone(
            id: 'm2',
            goalId: goal.id,
            title: 'Graphs',
            sequenceOrder: 2,
            estimatedMinutes: 120,
            createdAt: DateTime(2026, 3, 2),
          ),
        ];
        final tasks = [
          _task('task-1', goal.id, 'm1', 120),
          _task('task-2', goal.id, 'm2', 120),
        ];
        final sessions = [
          _completedSession('session-1', 'task-1', 60),
          _completedSession('session-2', 'task-1', 60),
          _completedSession('session-3', 'task-2', 30),
        ];

        final progress = service.computeGoalProgress(
          goal: goal,
          milestones: milestones,
          tasks: tasks,
          sessions: sessions,
        );

        expect(progress.totalMilestones, 2);
        expect(progress.completedMilestones, 1);
        expect(progress.totalLinkedTasks, 2);
        expect(progress.completedLinkedTasks, 1);
        expect(progress.totalPlannedMinutes, 240);
        expect(progress.totalCompletedMinutes, 150);
        expect(progress.percentComplete, closeTo(0.625, 0.0001));
      },
    );

    test(
      'falls back to milestone completion when there are no linked tasks',
      () {
        const service = GoalProgressService();
        final goal = LearningGoal(
          id: 'goal-1',
          title: 'Learn SQL',
          goalType: GoalType.learning,
          priority: 2,
          createdAt: DateTime(2026, 3, 1),
        );
        final milestones = [
          GoalMilestone(
            id: 'm1',
            goalId: goal.id,
            title: 'Joins',
            sequenceOrder: 1,
            estimatedMinutes: 60,
            isCompleted: true,
            createdAt: DateTime(2026, 3, 1),
            completedAt: DateTime(2026, 3, 2),
          ),
          GoalMilestone(
            id: 'm2',
            goalId: goal.id,
            title: 'Indexes',
            sequenceOrder: 2,
            estimatedMinutes: 60,
            createdAt: DateTime(2026, 3, 2),
          ),
        ];

        final progress = service.computeGoalProgress(
          goal: goal,
          milestones: milestones,
          tasks: const [],
          sessions: const [],
        );

        expect(progress.totalLinkedTasks, 0);
        expect(progress.percentComplete, closeTo(0.5, 0.0001));
        expect(progress.totalPlannedMinutes, 120);
      },
    );
  });
}

Task _task(String id, String goalId, String milestoneId, int minutes) {
  return Task(
    id: id,
    title: id,
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    priority: 1,
    goalId: goalId,
    milestoneId: milestoneId,
    createdAt: DateTime(2026, 3, 1),
  );
}

PlannedSession _completedSession(String id, String taskId, int minutes) {
  final start = DateTime(2026, 3, 16, 9);
  return PlannedSession(
    id: id,
    taskId: taskId,
    start: start,
    end: start.add(Duration(minutes: minutes)),
    status: PlannedSessionStatus.completed,
    completed: true,
    actualMinutesFocused: minutes,
  );
}
