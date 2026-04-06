import 'package:isar/isar.dart';

import '../../schedule/domain/session_progress_service.dart';
import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/task.dart';

class TaskRepository implements SessionProgressTaskStore {
  TaskRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder =
        const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<Task>> getAllTasks({bool includeArchived = true}) async {
    final tasks = await _isar.tasks.where().findAll();
    final visibleTasks = includeArchived
        ? tasks
        : tasks.where((task) => !task.isArchived).toList();
    visibleTasks.sort(_compareTasks);
    return visibleTasks;
  }

  Stream<List<Task>> watchAllTasks({bool includeArchived = true}) {
    return _isar.tasks.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllTasks(includeArchived: includeArchived);
    });
  }

  Future<List<Task>> getActiveTasks() {
    return getAllTasks(includeArchived: false);
  }

  Stream<List<Task>> watchActiveTasks() {
    return watchAllTasks(includeArchived: false);
  }

  Future<List<Task>> getArchivedTasks() async {
    final tasks = await _isar.tasks.where().findAll();
    final archivedTasks = tasks.where((task) => task.isArchived).toList();
    archivedTasks.sort(_compareTasks);
    return archivedTasks;
  }

  Stream<List<Task>> watchArchivedTasks() {
    return _isar.tasks.watchLazy(fireImmediately: true).asyncMap((_) {
      return getArchivedTasks();
    });
  }

  Future<void> addTask(Task task) async {
    final taskToStore = task.copyWith(
      updatedAt: task.updatedAt ?? task.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.tasks.put(taskToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.task,
      entityId: taskToStore.id,
      entity: taskToStore,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> addTasks(List<Task> tasks) async {
    if (tasks.isEmpty) {
      return;
    }

    final tasksToStore = tasks
        .map(
          (task) => task.copyWith(updatedAt: task.updatedAt ?? task.createdAt),
        )
        .toList();

    await _isar.writeTxn(() async {
      await _isar.tasks.putAll(tasksToStore);
    });
    for (final task in tasksToStore) {
      await _syncMutationRecorder.recordUpsert(
        entityType: SyncEntityType.task,
        entityId: task.id,
        entity: task,
        operationType: SyncOperationType.create,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    final taskToStore = task.copyWith(
      updatedAt: task.updatedAt ?? task.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.tasks.put(taskToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.task,
      entityId: taskToStore.id,
      entity: taskToStore,
      operationType: SyncOperationType.update,
    );
  }

  @override
  Future<Task?> getTaskById(String id) {
    return _isar.tasks.filter().idEqualTo(id).findFirst();
  }

  Future<void> archiveTask(String id, DateTime archivedAt) async {
    final task = await getTaskById(id);
    if (task == null) {
      return;
    }

    await updateTask(
      task.copyWith(
        isArchived: true,
        archivedAt: archivedAt,
        updatedAt: archivedAt,
      ),
    );
  }

  Future<void> restoreTask(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      return;
    }

    final now = DateTime.now();
    await updateTask(
      task.copyWith(isArchived: false, clearArchivedAt: true, updatedAt: now),
    );
  }

  Future<void> deleteTask(String id) async {
    final task = await _isar.tasks.filter().idEqualTo(id).findFirst();
    if (task == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.tasks.delete(task.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.task,
      entityId: id,
    );
  }

  @override
  Future<void> markTaskCompleted(String id, DateTime completedAt) async {
    final task = await _isar.tasks.filter().idEqualTo(id).findFirst();
    if (task == null) {
      return;
    }

    task.isCompleted = true;
    task.completedAt = completedAt;
    task.updatedAt = completedAt;

    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.task,
      entityId: task.id,
      entity: task,
      operationType: SyncOperationType.update,
    );
  }

  int _compareTasks(Task left, Task right) {
    if (left.isArchived != right.isArchived) {
      return left.isArchived ? 1 : -1;
    }
    if (left.isCompleted != right.isCompleted) {
      return left.isCompleted ? 1 : -1;
    }
    final priorityCompare = left.priority.compareTo(right.priority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }
    final leftDueDate = left.dueDate;
    final rightDueDate = right.dueDate;
    if (leftDueDate == null && rightDueDate != null) {
      return 1;
    }
    if (leftDueDate != null && rightDueDate == null) {
      return -1;
    }
    if (leftDueDate != null && rightDueDate != null) {
      final dueDateCompare = leftDueDate.compareTo(rightDueDate);
      if (dueDateCompare != 0) {
        return dueDateCompare;
      }
    }
    return (right.updatedAt ?? right.createdAt).compareTo(
      left.updatedAt ?? left.createdAt,
    );
  }
}

