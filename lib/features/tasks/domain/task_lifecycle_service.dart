import '../../goals/data/goal_repository.dart';
import '../../schedule/data/planned_session_repository.dart';
import '../data/task_repository.dart';

enum TaskResetMode { soft, hard }

typedef TaskLifecycleClock = DateTime Function();

class TaskLifecycleService {
  TaskLifecycleService({
    required TaskRepository taskRepository,
    required PlannedSessionRepository plannedSessionRepository,
    required GoalRepository goalRepository,
    TaskLifecycleClock clock = DateTime.now,
  }) : _taskRepository = taskRepository,
       _plannedSessionRepository = plannedSessionRepository,
       _goalRepository = goalRepository,
       _clock = clock;

  final TaskRepository _taskRepository;
  final PlannedSessionRepository _plannedSessionRepository;
  final GoalRepository _goalRepository;
  final TaskLifecycleClock _clock;

  Future<void> archiveTask(String taskId) async {
    await clearFutureSessionsForTask(taskId);
    await _taskRepository.archiveTask(taskId, _clock());
  }

  Future<void> unarchiveTask(String taskId) {
    return _taskRepository.restoreTask(taskId);
  }

  Future<void> resetTaskProgress(
    String taskId, {
    TaskResetMode mode = TaskResetMode.soft,
    bool clearFutureSessions = true,
  }) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      return;
    }

    switch (mode) {
      case TaskResetMode.soft:
        if (clearFutureSessions) {
          await clearFutureSessionsForTask(taskId);
        }
        break;
      case TaskResetMode.hard:
        await clearAllSessionsForTask(taskId);
        break;
    }

    await _taskRepository.updateTask(
      task.copyWith(
        isCompleted: false,
        clearCompletedAt: true,
        updatedAt: _clock(),
      ),
    );
  }

  Future<void> deleteTaskPermanently(String taskId) async {
    await clearAllSessionsForTask(taskId);
    await _goalRepository.deleteDependenciesForTask(taskId);
    await _taskRepository.deleteTask(taskId);
  }

  Future<void> clearFutureSessionsForTask(String taskId) async {
    final now = _clock();
    final sessions = await _plannedSessionRepository.getAllSessions();
    final sessionsToDelete = sessions.where((session) {
      if (session.taskId != taskId) return false;
      if (session.isCompleted) return false;
      return !session.start.isBefore(now);
    }).toList();

    for (final session in sessionsToDelete) {
      await _plannedSessionRepository.deleteSession(session.id);
    }
  }

  Future<void> clearAllSessionsForTask(String taskId) {
    return _plannedSessionRepository.deleteSessionsByTaskId(taskId);
  }
}
