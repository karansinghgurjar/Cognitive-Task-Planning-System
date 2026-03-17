import '../../schedule/domain/task_progress_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../models/task_dependency.dart';

class DependencyResolutionResult {
  const DependencyResolutionResult({
    required this.schedulableTasks,
    required this.blockedTaskIds,
    required this.cycleTaskIds,
    required this.missingDependencyTaskIds,
    required this.blockedByTaskIds,
  });

  final List<Task> schedulableTasks;
  final Set<String> blockedTaskIds;
  final Set<String> cycleTaskIds;
  final Set<String> missingDependencyTaskIds;
  final Map<String, List<String>> blockedByTaskIds;
}

class DependencyResolutionService {
  const DependencyResolutionService({
    this.taskProgressService = const TaskProgressService(),
  });

  final TaskProgressService taskProgressService;

  bool isTaskBlocked(
    Task task, {
    required List<TaskDependency> dependencies,
    required List<Task> allTasks,
    required List<PlannedSession> sessions,
  }) {
    final result = resolveSchedulableTasks(
      tasks: allTasks,
      dependencies: dependencies,
      sessions: sessions,
    );
    return result.blockedTaskIds.contains(task.id);
  }

  DependencyResolutionResult resolveSchedulableTasks({
    required List<Task> tasks,
    required List<TaskDependency> dependencies,
    required List<PlannedSession> sessions,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final relevantDependencies = dependencies
        .where((dependency) => taskById.containsKey(dependency.taskId))
        .toList();

    final cycleTaskIds = _findCycleTaskIds(
      taskIds: taskById.keys.toSet(),
      dependencies: relevantDependencies,
    );
    final missingDependencyTaskIds = <String>{};
    final blockedTaskIds = <String>{...cycleTaskIds};
    final blockedByTaskIds = <String, List<String>>{};

    for (final task in tasks) {
      final blockers = <String>[];

      if (cycleTaskIds.contains(task.id)) {
        blockers.add(task.id);
      }

      for (final dependency in relevantDependencies.where(
        (item) => item.taskId == task.id,
      )) {
        final prerequisite = taskById[dependency.dependsOnTaskId];
        if (prerequisite == null) {
          missingDependencyTaskIds.add(task.id);
          blockers.add(dependency.dependsOnTaskId);
          continue;
        }

        if (cycleTaskIds.contains(prerequisite.id)) {
          blockers.add(prerequisite.id);
          continue;
        }

        final satisfied =
            prerequisite.isCompleted ||
            taskProgressService.isTaskSatisfied(prerequisite, sessions);
        if (!satisfied) {
          blockers.add(prerequisite.id);
        }
      }

      if (blockers.isNotEmpty) {
        blockedTaskIds.add(task.id);
        blockedByTaskIds[task.id] = blockers.toSet().toList()..sort();
      }
    }

    final schedulableTasks = tasks
        .where((task) => !blockedTaskIds.contains(task.id))
        .toList();

    return DependencyResolutionResult(
      schedulableTasks: schedulableTasks,
      blockedTaskIds: blockedTaskIds,
      cycleTaskIds: cycleTaskIds,
      missingDependencyTaskIds: missingDependencyTaskIds,
      blockedByTaskIds: blockedByTaskIds,
    );
  }

  Set<String> _findCycleTaskIds({
    required Set<String> taskIds,
    required List<TaskDependency> dependencies,
  }) {
    final adjacency = <String, List<String>>{
      for (final taskId in taskIds) taskId: <String>[],
    };

    for (final dependency in dependencies) {
      if (taskIds.contains(dependency.taskId) &&
          taskIds.contains(dependency.dependsOnTaskId)) {
        adjacency[dependency.taskId]!.add(dependency.dependsOnTaskId);
      } else if (dependency.taskId == dependency.dependsOnTaskId &&
          taskIds.contains(dependency.taskId)) {
        adjacency[dependency.taskId]!.add(dependency.dependsOnTaskId);
      }
    }

    final state = <String, int>{};
    final stack = <String>[];
    final cycleTaskIds = <String>{};

    void visit(String taskId) {
      final nodeState = state[taskId] ?? 0;
      if (nodeState == 1) {
        final startIndex = stack.indexOf(taskId);
        if (startIndex >= 0) {
          cycleTaskIds.addAll(stack.sublist(startIndex));
        }
        cycleTaskIds.add(taskId);
        return;
      }
      if (nodeState == 2) {
        return;
      }

      state[taskId] = 1;
      stack.add(taskId);

      for (final dependencyId in adjacency[taskId] ?? const <String>[]) {
        visit(dependencyId);
      }

      stack.removeLast();
      state[taskId] = 2;
    }

    for (final taskId in taskIds) {
      visit(taskId);
    }

    return cycleTaskIds;
  }
}
