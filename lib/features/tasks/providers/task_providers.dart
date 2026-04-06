import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../focus_session/providers/focus_session_providers.dart';
import '../../goals/providers/goal_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../data/task_repository.dart';
import '../domain/task_lifecycle_service.dart';
import '../models/task.dart';

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(
    syncMutationRecorderProvider.future,
  );
  return TaskRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final taskLifecycleServiceProvider = FutureProvider<TaskLifecycleService>((
  ref,
) async {
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  final plannedSessionRepository = await ref.watch(
    plannedSessionRepositoryProvider.future,
  );
  final goalRepository = await ref.watch(goalRepositoryProvider.future);
  return TaskLifecycleService(
    taskRepository: taskRepository,
    plannedSessionRepository: plannedSessionRepository,
    goalRepository: goalRepository,
  );
});

final watchTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchAllTasks();
});

final watchActiveTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchActiveTasks();
});

final watchArchivedTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchArchivedTasks();
});

final taskActionControllerProvider =
    AsyncNotifierProvider<TaskActionController, void>(TaskActionController.new);

class TaskActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addTask(Task task) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(taskRepositoryProvider.future);
      await repository.addTask(task);
    });
  }

  Future<void> toggleCompleted(Task task) async {
    _ensureIdle();
    await _run(() async {
      if (task.isArchived) {
        throw StateError(
          'Restore the task before changing its completion state.',
        );
      }
      final repository = await ref.read(taskRepositoryProvider.future);
      if (task.isCompleted) {
        await repository.updateTask(
          task.copyWith(
            isCompleted: false,
            clearCompletedAt: true,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await repository.markTaskCompleted(task.id, DateTime.now());
      }
    });
  }

  Future<void> archiveTask(Task task) async {
    _ensureIdle();
    await _run(() async {
      _ensureNoActiveFocus(task.id, 'archive this task');
      final lifecycleService = await ref.read(
        taskLifecycleServiceProvider.future,
      );
      await lifecycleService.archiveTask(task.id);
    });
  }

  Future<void> restoreTask(Task task) async {
    _ensureIdle();
    await _run(() async {
      final lifecycleService = await ref.read(
        taskLifecycleServiceProvider.future,
      );
      await lifecycleService.unarchiveTask(task.id);
    });
  }

  Future<void> resetTask(
    Task task, {
    TaskResetMode mode = TaskResetMode.soft,
  }) async {
    _ensureIdle();
    await _run(() async {
      _ensureNoActiveFocus(task.id, 'reset this task');
      final lifecycleService = await ref.read(
        taskLifecycleServiceProvider.future,
      );
      await lifecycleService.resetTaskProgress(task.id, mode: mode);
    });
  }

  Future<void> resetGeneratedSessions(Task task) async {
    _ensureIdle();
    await _run(() async {
      _ensureNoActiveFocus(task.id, 'clear generated sessions for this task');
      final lifecycleService = await ref.read(
        taskLifecycleServiceProvider.future,
      );
      await lifecycleService.clearFutureSessionsForTask(task.id);
    });
  }

  Future<void> deleteTask(String id) async {
    _ensureIdle();
    await _run(() async {
      _ensureNoActiveFocus(id, 'delete this task');
      final lifecycleService = await ref.read(
        taskLifecycleServiceProvider.future,
      );
      await lifecycleService.deleteTaskPermanently(id);
    });
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another task action is already in progress.');
    }
  }

  void _ensureNoActiveFocus(String taskId, String action) {
    final activeFocus = ref.read(focusSessionControllerProvider);
    if (activeFocus?.taskId == taskId) {
      throw StateError('Stop the active focus session before you $action.');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

