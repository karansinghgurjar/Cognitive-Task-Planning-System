import '../../tasks/models/task.dart';
import '../models/planned_session.dart';
import 'task_progress_service.dart';

abstract class SessionProgressSessionStore {
  Future<List<PlannedSession>> getAllSessions();

  Future<void> updateSession(PlannedSession session);
}

abstract class SessionProgressTaskStore {
  Future<Task?> getTaskById(String id);

  Future<void> markTaskCompleted(String id, DateTime completedAt);
}

class SessionProgressService {
  SessionProgressService({
    required SessionProgressSessionStore sessionStore,
    required SessionProgressTaskStore taskStore,
    TaskProgressService taskProgressService = const TaskProgressService(),
  }) : _sessionStore = sessionStore,
       _taskStore = taskStore,
       _taskProgressService = taskProgressService;

  final SessionProgressSessionStore _sessionStore;
  final SessionProgressTaskStore _taskStore;
  final TaskProgressService _taskProgressService;

  bool shouldMarkTaskCompleted(Task task, List<PlannedSession> sessions) {
    return _taskProgressService.isTaskSatisfied(task, sessions);
  }

  int computeActualFocusedMinutes({
    required PlannedSession session,
    required int elapsedSeconds,
    bool timerCompletedNormally = false,
  }) {
    if (elapsedSeconds <= 0) {
      return timerCompletedNormally ? session.plannedDurationMinutes : 0;
    }

    final roundedMinutes = (elapsedSeconds / 60).round();
    return roundedMinutes == 0 ? 1 : roundedMinutes;
  }

  Future<PlannedSession> completeSession({
    required PlannedSession session,
    required int elapsedSeconds,
    bool timerCompletedNormally = false,
  }) async {
    final actualMinutes = computeActualFocusedMinutes(
      session: session,
      elapsedSeconds: elapsedSeconds,
      timerCompletedNormally: timerCompletedNormally,
    );

    final updatedSession = session.copyWith(
      status: PlannedSessionStatus.completed,
      completed: true,
      actualMinutesFocused: actualMinutes,
    );

    await _sessionStore.updateSession(updatedSession);

    final task = await _taskStore.getTaskById(session.taskId);
    if (task != null && !task.isCompleted) {
      final allSessions = await _sessionStore.getAllSessions();
      if (shouldMarkTaskCompleted(task, allSessions)) {
        await _taskStore.markTaskCompleted(task.id, DateTime.now());
      }
    }

    return updatedSession;
  }
}
