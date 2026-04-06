import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/data/goal_repository.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/schedule/data/planned_session_repository.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/data/task_repository.dart';
import 'package:study_flow/features/tasks/domain/task_lifecycle_service.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  test(
    'soft reset keeps completed sessions and clears future pending sessions',
    () async {
      final taskRepository = _FakeTaskRepository();
      final sessionRepository = _FakePlannedSessionRepository();
      final goalRepository = _FakeGoalRepository();
      final task = Task(
        id: 'task-1',
        title: 'Task',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 1,
        isCompleted: true,
        createdAt: DateTime(2026, 1, 1),
        completedAt: DateTime(2026, 1, 2),
      );
      taskRepository.taskById[task.id] = task;

      final service = TaskLifecycleService(
        taskRepository: taskRepository,
        plannedSessionRepository: sessionRepository,
        goalRepository: goalRepository,
        clock: () => DateTime(2026, 1, 2, 12),
      );

      await service.resetTaskProgress(task.id, mode: TaskResetMode.soft);

      expect(sessionRepository.futureDeleteRequests, [
        ('task-1', DateTime(2026, 1, 2, 12)),
      ]);
      expect(taskRepository.updatedTasks.single.isCompleted, isFalse);
      expect(taskRepository.updatedTasks.single.completedAt, isNull);
      expect(
        taskRepository.updatedTasks.single.progressResetAt,
        DateTime(2026, 1, 2, 12),
      );
    },
  );

  test('hard reset deletes all sessions for the task', () async {
    final taskRepository = _FakeTaskRepository();
    final sessionRepository = _FakePlannedSessionRepository();
    final goalRepository = _FakeGoalRepository();
    final task = Task(
      id: 'task-1',
      title: 'Task',
      type: TaskType.study,
      estimatedDurationMinutes: 60,
      priority: 1,
      createdAt: DateTime(2026, 1, 1),
    );
    taskRepository.taskById[task.id] = task;

    final service = TaskLifecycleService(
      taskRepository: taskRepository,
      plannedSessionRepository: sessionRepository,
      goalRepository: goalRepository,
      clock: () => DateTime(2026, 1, 2, 12),
    );

    await service.resetTaskProgress(task.id, mode: TaskResetMode.hard);

    expect(sessionRepository.deletedTaskIds, ['task-1']);
    expect(
      taskRepository.updatedTasks.single.progressResetAt,
      DateTime(2026, 1, 2, 12),
    );
  });

  test('unarchive delegates restore to the repository', () async {
    final taskRepository = _FakeTaskRepository();
    final sessionRepository = _FakePlannedSessionRepository();
    final goalRepository = _FakeGoalRepository();

    final service = TaskLifecycleService(
      taskRepository: taskRepository,
      plannedSessionRepository: sessionRepository,
      goalRepository: goalRepository,
    );

    await service.unarchiveTask('task-1');

    expect(taskRepository.restoredIds, ['task-1']);
  });

  test('archive clears only future non-completed sessions before archiving', () async {
    final taskRepository = _FakeTaskRepository();
    final sessionRepository = _FakePlannedSessionRepository();
    final goalRepository = _FakeGoalRepository();
    final task = Task(
      id: 'task-1',
      title: 'Task',
      type: TaskType.study,
      estimatedDurationMinutes: 60,
      priority: 1,
      createdAt: DateTime(2026, 1, 1),
    );
    taskRepository.taskById[task.id] = task;

    final archivedAt = DateTime(2026, 1, 2, 12);
    final service = TaskLifecycleService(
      taskRepository: taskRepository,
      plannedSessionRepository: sessionRepository,
      goalRepository: goalRepository,
      clock: () => archivedAt,
    );

    await service.archiveTask(task.id);

    expect(sessionRepository.futureDeleteRequests, [
      ('task-1', archivedAt),
    ]);
    expect(taskRepository.archivedCalls, [
      ('task-1', archivedAt),
    ]);
  });
}

class _FakeTaskRepository implements TaskRepository {
  final Map<String, Task> taskById = {};
  final List<Task> updatedTasks = [];
  final List<(String, DateTime)> archivedCalls = [];
  final List<String> restoredIds = [];

  @override
  Future<void> addTask(Task task) async {}

  @override
  Future<void> addTasks(List<Task> tasks) async {}

  @override
  Future<void> archiveTask(String id, DateTime archivedAt) async {
    archivedCalls.add((id, archivedAt));
  }

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<Task>> getAllTasks({bool includeArchived = true}) async =>
      taskById.values.toList();

  @override
  Future<List<Task>> getActiveTasks() async =>
      taskById.values.where((task) => !task.isArchived).toList();

  @override
  Future<List<Task>> getArchivedTasks() async =>
      taskById.values.where((task) => task.isArchived).toList();

  @override
  Future<Task?> getTaskById(String id) async => taskById[id];

  @override
  Future<void> markTaskCompleted(String id, DateTime completedAt) async {}

  @override
  Future<void> restoreTask(String id) async {
    restoredIds.add(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    updatedTasks.add(task);
    taskById[task.id] = task;
  }

  @override
  Stream<List<Task>> watchAllTasks({bool includeArchived = true}) async* {
    yield taskById.values.toList();
  }

  @override
  Stream<List<Task>> watchActiveTasks() async* {
    yield taskById.values.where((task) => !task.isArchived).toList();
  }

  @override
  Stream<List<Task>> watchArchivedTasks() async* {
    yield taskById.values.where((task) => task.isArchived).toList();
  }
}

class _FakePlannedSessionRepository implements PlannedSessionRepository {
  List<PlannedSession> sessions = [];
  final List<String> deletedSessionIds = [];
  final List<String> deletedTaskIds = [];
  final List<(String, DateTime)> futureDeleteRequests = [];

  @override
  Future<void> addSession(PlannedSession session) async {}

  @override
  Future<void> addSessions(List<PlannedSession> sessions) async {}

  @override
  Future<void> deleteSession(String id) async {
    deletedSessionIds.add(id);
  }

  @override
  Future<void> deleteSessionsByTaskId(String taskId) async {
    deletedTaskIds.add(taskId);
  }

  @override
  Future<void> deleteNonCompletedSessionsByTaskId(String taskId) async {}

  @override
  Future<void> deleteFutureNonCompletedSessionsByTaskId(
    String taskId,
    DateTime now,
  ) async {
    futureDeleteRequests.add((taskId, now));
  }

  @override
  Future<void> deleteSessionsInRange(DateTime start, DateTime end) async {}

  @override
  Future<List<PlannedSession>> getAllSessions() async => sessions;

  @override
  Future<PlannedSession?> getSessionById(String id) async => null;

  @override
  Future<List<PlannedSession>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async => const [];

  @override
  Future<void> replaceFutureSessionsInRange({
    required DateTime start,
    required DateTime end,
    required List<PlannedSession> newSessions,
    bool keepCompleted = true,
    String? activeSessionId,
  }) async {}

  @override
  Future<void> updateSession(PlannedSession session) async {}

  @override
  Future<void> updateSessions(List<PlannedSession> sessions) async {}

  @override
  Stream<List<PlannedSession>> watchAllSessions() async* {
    yield sessions;
  }
}

class _FakeGoalRepository implements GoalRepository {
  @override
  Future<void> addDependency(TaskDependency dependency) async {}

  @override
  Future<void> addGoal(LearningGoal goal) async {}

  @override
  Future<void> addMilestone(GoalMilestone milestone) async {}

  @override
  Future<void> deleteDependenciesForTask(String taskId) async {}

  @override
  Future<void> deleteDependency(String id) async {}

  @override
  Future<void> deleteGoal(String id) async {}

  @override
  Future<void> deleteMilestone(String id) async {}

  @override
  Future<List<TaskDependency>> getAllDependencies() async => const [];

  @override
  Future<List<LearningGoal>> getAllGoals() async => const [];

  @override
  Future<List<GoalMilestone>> getAllMilestones() async => const [];

  @override
  Future<LearningGoal?> getGoalById(String id) async => null;

  @override
  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId) async =>
      const [];

  @override
  Future<void> updateGoal(LearningGoal goal) async {}

  @override
  Future<void> updateMilestone(GoalMilestone milestone) async {}

  @override
  Stream<List<TaskDependency>> watchAllDependencies() async* {
    yield const [];
  }

  @override
  Stream<List<LearningGoal>> watchAllGoals() async* {
    yield const [];
  }

  @override
  Stream<List<GoalMilestone>> watchAllMilestones() async* {
    yield const [];
  }

  @override
  Stream<List<GoalMilestone>> watchMilestonesForGoal(String goalId) async* {
    yield const [];
  }
}
