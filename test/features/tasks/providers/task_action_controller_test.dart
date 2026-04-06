import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/focus_session/domain/focus_session_state.dart';
import 'package:study_flow/features/focus_session/providers/focus_session_providers.dart';
import 'package:study_flow/features/goals/data/goal_repository.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/goals/providers/goal_providers.dart';
import 'package:study_flow/features/schedule/data/planned_session_repository.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/schedule/providers/schedule_providers.dart';
import 'package:study_flow/features/tasks/data/task_repository.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/tasks/providers/task_providers.dart';

void main() {
  test(
    'task action controller deletes sessions and dependencies before task',
    () async {
      final taskRepository = _FakeTaskRepository();
      final sessionRepository = _FakePlannedSessionRepository();
      final goalRepository = _FakeGoalRepository();
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) async => taskRepository),
          plannedSessionRepositoryProvider.overrideWith(
            (ref) async => sessionRepository,
          ),
          goalRepositoryProvider.overrideWith((ref) async => goalRepository),
        ],
      );
      addTearDown(() async {
        await taskRepository.dispose();
        container.dispose();
      });

      await container
          .read(taskActionControllerProvider.notifier)
          .deleteTask('task-1');

      expect(sessionRepository.deletedTaskIds, ['task-1']);
      expect(goalRepository.deletedDependencyTaskIds, ['task-1']);
      expect(taskRepository.deletedTaskIds, ['task-1']);
      expect(
        [
          ...sessionRepository.callLog,
          ...goalRepository.callLog,
          ...taskRepository.callLog,
        ],
        [
          'deleteSessionsByTaskId(task-1)',
          'deleteDependenciesForTask(task-1)',
          'deleteTask(task-1)',
        ],
      );
    },
  );

  test(
    'task action controller archives task after clearing non-completed sessions',
    () async {
      final taskRepository = _FakeTaskRepository();
      final sessionRepository = _FakePlannedSessionRepository();
      final goalRepository = _FakeGoalRepository();
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) async => taskRepository),
          plannedSessionRepositoryProvider.overrideWith(
            (ref) async => sessionRepository,
          ),
          goalRepositoryProvider.overrideWith((ref) async => goalRepository),
        ],
      );
      addTearDown(() async {
        await taskRepository.dispose();
        container.dispose();
      });

      final task = Task(
        id: 'task-1',
        title: 'Archive me',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 1,
        createdAt: DateTime(2026),
      );

      taskRepository.taskById['task-1'] = task;
      sessionRepository.sessions = [
        PlannedSession(
          id: 'future-1',
          taskId: 'task-1',
          start: DateTime(2099, 1, 2),
          end: DateTime(2099, 1, 2, 1),
        ),
      ];

      await container
          .read(taskActionControllerProvider.notifier)
          .archiveTask(task);

      expect(sessionRepository.deletedNonCompletedTaskIds, ['task-1']);
      expect(taskRepository.archivedTaskIds, ['task-1']);
    },
  );

  test(
    'task action controller blocks delete when focus session is active for task',
    () async {
      final taskRepository = _FakeTaskRepository();
      final sessionRepository = _FakePlannedSessionRepository();
      final goalRepository = _FakeGoalRepository();
      final activeFocus = FocusSessionState(
        plannedSessionId: 'session-1',
        taskId: 'task-1',
        taskTitle: 'Active task',
        plannedStart: DateTime(2026),
        plannedEnd: DateTime(2026).add(const Duration(hours: 1)),
        plannedDurationMinutes: 60,
        remainingSeconds: 3000,
        elapsedSeconds: 600,
        isRunning: true,
        isPaused: false,
        startedAt: DateTime(2026),
        lastResumedAt: DateTime(2026),
      );
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWith((ref) async => taskRepository),
          plannedSessionRepositoryProvider.overrideWith(
            (ref) async => sessionRepository,
          ),
          goalRepositoryProvider.overrideWith((ref) async => goalRepository),
          focusSessionControllerProvider.overrideWith(
            () => _StubFocusController(activeFocus),
          ),
        ],
      );
      addTearDown(() async {
        await taskRepository.dispose();
        container.dispose();
      });

      await expectLater(
        () => container
            .read(taskActionControllerProvider.notifier)
            .deleteTask('task-1'),
        throwsA(isA<StateError>()),
      );

      expect(taskRepository.deletedTaskIds, isEmpty);
      expect(sessionRepository.deletedTaskIds, isEmpty);
    },
  );
}

class _FakeTaskRepository implements TaskRepository {
  final List<String> deletedTaskIds = [];
  final List<String> archivedTaskIds = [];
  final List<String> restoredTaskIds = [];
  final List<Task> updatedTasks = [];
  final Map<String, Task> taskById = {};
  final List<String> callLog = [];
  final _controller = StreamController<List<Task>>.broadcast();

  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> addTask(Task task) async {}

  @override
  Future<void> addTasks(List<Task> tasks) async {}

  @override
  Future<void> archiveTask(String id, DateTime archivedAt) async {
    callLog.add('archiveTask($id)');
    archivedTaskIds.add(id);
  }

  @override
  Future<void> deleteTask(String id) async {
    callLog.add('deleteTask($id)');
    deletedTaskIds.add(id);
  }

  @override
  Future<List<Task>> getAllTasks({bool includeArchived = true}) async =>
      const [];

  @override
  Future<List<Task>> getActiveTasks() async => const [];

  @override
  Future<List<Task>> getArchivedTasks() async => const [];

  @override
  Future<Task?> getTaskById(String id) async => taskById[id];

  @override
  Future<void> markTaskCompleted(String id, DateTime completedAt) async {}

  @override
  Future<void> restoreTask(String id) async {
    callLog.add('restoreTask($id)');
    restoredTaskIds.add(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    updatedTasks.add(task);
    taskById[task.id] = task;
  }

  @override
  Stream<List<Task>> watchAllTasks({bool includeArchived = true}) async* {
    yield const [];
    yield* _controller.stream;
  }

  @override
  Stream<List<Task>> watchActiveTasks() async* {
    yield const [];
  }

  @override
  Stream<List<Task>> watchArchivedTasks() async* {
    yield const [];
  }
}

class _FakePlannedSessionRepository implements PlannedSessionRepository {
  List<PlannedSession> sessions = [];
  final List<String> deletedTaskIds = [];
  final List<String> deletedSessionIds = [];
  final List<String> deletedNonCompletedTaskIds = [];
  final List<String> callLog = [];

  @override
  Future<void> addSession(PlannedSession session) async {}

  @override
  Future<void> addSessions(List<PlannedSession> sessions) async {}

  @override
  Future<void> deleteSession(String id) async {
    callLog.add('deleteSession($id)');
    deletedSessionIds.add(id);
  }

  @override
  Future<void> deleteSessionsByTaskId(String taskId) async {
    callLog.add('deleteSessionsByTaskId($taskId)');
    deletedTaskIds.add(taskId);
  }

  @override
  Future<void> deleteNonCompletedSessionsByTaskId(String taskId) async {
    callLog.add('deleteNonCompletedSessionsByTaskId($taskId)');
    deletedNonCompletedTaskIds.add(taskId);
  }

  @override
  Future<void> deleteFutureNonCompletedSessionsByTaskId(
    String taskId,
    DateTime now,
  ) async {
    callLog.add('deleteFutureNonCompletedSessionsByTaskId($taskId)');
    deletedNonCompletedTaskIds.add(taskId);
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
    yield const [];
  }
}

class _FakeGoalRepository implements GoalRepository {
  final List<String> deletedDependencyTaskIds = [];
  final List<String> callLog = [];

  @override
  Future<void> addDependency(TaskDependency dependency) async {}

  @override
  Future<void> addGoal(LearningGoal goal) async {}

  @override
  Future<void> addMilestone(GoalMilestone milestone) async {}

  @override
  Future<void> deleteDependenciesForTask(String taskId) async {
    callLog.add('deleteDependenciesForTask($taskId)');
    deletedDependencyTaskIds.add(taskId);
  }

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

class _StubFocusController extends FocusSessionController {
  _StubFocusController(this._state);

  final FocusSessionState? _state;

  @override
  FocusSessionState? build() => _state;
}
