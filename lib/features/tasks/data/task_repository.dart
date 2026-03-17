import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../../schedule/domain/session_progress_service.dart';
import '../models/task.dart';

class TaskRepository implements SessionProgressTaskStore {
  TaskRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder = const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<Task>> getAllTasks() async {
    final tasks = await _isar.tasks.where().findAll();
    tasks.sort(_compareTasks);
    return tasks;
  }

  Stream<List<Task>> watchAllTasks() {
    return _isar.tasks.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllTasks();
    });
  }

  Future<void> addTask(Task task) async {
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.task,
      entityId: task.id,
      entity: task,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> addTasks(List<Task> tasks) async {
    if (tasks.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.tasks.putAll(tasks);
    });
    for (final task in tasks) {
      await _syncMutationRecorder.recordUpsert(
        entityType: SyncEntityType.task,
        entityId: task.id,
        entity: task,
        operationType: SyncOperationType.create,
      );
    }
  }

  Future<void> updateTask(Task task) async {
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

  @override
  Future<Task?> getTaskById(String id) {
    return _isar.tasks.filter().idEqualTo(id).findFirst();
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

    return right.createdAt.compareTo(left.createdAt);
  }
}
