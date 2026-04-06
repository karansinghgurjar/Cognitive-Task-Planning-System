import '../../tasks/models/task.dart';
import '../models/planned_session.dart';

class TaskProgressService {
  const TaskProgressService();

  int getCompletedMinutesForTask(Task task, List<PlannedSession> sessions) {
    return _effectiveCompletedSessions(task, sessions).fold<int>(0, (
      sum,
      session,
    ) {
      final minutes = session.actualMinutesFocused > 0
          ? session.actualMinutesFocused
          : session.plannedDurationMinutes;
      return sum + minutes;
    });
  }

  int getRemainingMinutesForTask(Task task, List<PlannedSession> sessions) {
    final remaining =
        task.estimatedDurationMinutes - getCompletedMinutesForTask(task, sessions);
    return remaining < 0 ? 0 : remaining;
  }

  bool isTaskSatisfied(Task task, List<PlannedSession> sessions) {
    return getRemainingMinutesForTask(task, sessions) == 0;
  }

  Iterable<PlannedSession> _effectiveCompletedSessions(
    Task task,
    List<PlannedSession> sessions,
  ) {
    return sessions.where((session) {
      if (session.taskId != task.id || !session.isCompleted) {
        return false;
      }
      final resetAt = task.progressResetAt;
      if (resetAt == null) {
        return true;
      }
      return !session.end.isBefore(resetAt);
    });
  }
}
