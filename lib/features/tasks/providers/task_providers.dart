import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../goals/providers/goal_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../data/task_repository.dart';
import '../models/task.dart';

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(syncMutationRecorderProvider.future);
  return TaskRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final watchTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchAllTasks();
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
      final repository = await ref.read(taskRepositoryProvider.future);
      if (task.isCompleted) {
        await repository.updateTask(
          task.copyWith(isCompleted: false, clearCompletedAt: true),
        );
      } else {
        await repository.markTaskCompleted(task.id, DateTime.now());
      }
    });
  }

  Future<void> deleteTask(String id) async {
    _ensureIdle();
    await _run(() async {
      final repository = await ref.read(taskRepositoryProvider.future);
      final sessionRepository = await ref.read(
        plannedSessionRepositoryProvider.future,
      );
      final goalRepository = await ref.read(goalRepositoryProvider.future);
      await sessionRepository.deleteSessionsByTaskId(id);
      await goalRepository.deleteDependenciesForTask(id);
      await repository.deleteTask(id);
    });
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another task action is already in progress.');
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
