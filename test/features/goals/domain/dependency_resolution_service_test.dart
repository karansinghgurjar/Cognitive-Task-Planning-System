import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/domain/dependency_resolution_service.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('DependencyResolutionService', () {
    test('blocks tasks whose prerequisite is not yet satisfied', () {
      const service = DependencyResolutionService();
      final taskA = _task('task-a', 60);
      final taskB = _task('task-b', 60);

      final result = service.resolveSchedulableTasks(
        tasks: [taskA, taskB],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: taskB.id,
            dependsOnTaskId: taskA.id,
            createdAt: DateTime(2026, 3, 16),
          ),
        ],
        sessions: const [],
      );

      expect(result.schedulableTasks.map((task) => task.id), [taskA.id]);
      expect(result.blockedTaskIds, contains(taskB.id));
      expect(result.blockedByTaskIds[taskB.id], [taskA.id]);
    });

    test('allows task once prerequisite is completed', () {
      const service = DependencyResolutionService();
      final taskA = _task('task-a', 60, isCompleted: true);
      final taskB = _task('task-b', 60);

      final result = service.resolveSchedulableTasks(
        tasks: [taskA, taskB],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: taskB.id,
            dependsOnTaskId: taskA.id,
            createdAt: DateTime(2026, 3, 16),
          ),
        ],
        sessions: const [],
      );

      expect(result.blockedTaskIds, isEmpty);
      expect(result.schedulableTasks.map((task) => task.id), [
        taskA.id,
        taskB.id,
      ]);
    });

    test('marks cycle participants as blocked', () {
      const service = DependencyResolutionService();
      final taskA = _task('task-a', 60);
      final taskB = _task('task-b', 60);
      final taskC = _task('task-c', 60);

      final result = service.resolveSchedulableTasks(
        tasks: [taskA, taskB, taskC],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: taskA.id,
            dependsOnTaskId: taskB.id,
            createdAt: DateTime(2026, 3, 16),
          ),
          TaskDependency(
            id: 'dep-2',
            taskId: taskB.id,
            dependsOnTaskId: taskA.id,
            createdAt: DateTime(2026, 3, 16),
          ),
        ],
        sessions: const [],
      );

      expect(result.cycleTaskIds, {taskA.id, taskB.id});
      expect(result.blockedTaskIds, containsAll([taskA.id, taskB.id]));
      expect(result.schedulableTasks.map((task) => task.id), [taskC.id]);
    });
  });
}

Task _task(String id, int minutes, {bool isCompleted = false}) {
  return Task(
    id: id,
    title: id,
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    priority: 1,
    isCompleted: isCompleted,
    createdAt: DateTime(2026, 3, 1),
  );
}
