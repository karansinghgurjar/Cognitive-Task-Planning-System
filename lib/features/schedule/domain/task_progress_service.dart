import '../../tasks/models/task.dart';
import '../models/planned_session.dart';

class TaskProgressService {
  const TaskProgressService();

  int getCompletedMinutesForTask(String taskId, List<PlannedSession> sessions) {
    return sessions
        .where((session) => session.taskId == taskId && session.isCompleted)
        .fold<int>(0, (sum, session) {
          final minutes = session.actualMinutesFocused > 0
              ? session.actualMinutesFocused
              : session.plannedDurationMinutes;
          return sum + minutes;
        });
  }

  int getRemainingMinutesForTask(Task task, List<PlannedSession> sessions) {
    final remaining =
        task.estimatedDurationMinutes -
        getCompletedMinutesForTask(task.id, sessions);
    return remaining < 0 ? 0 : remaining;
  }

  bool isTaskSatisfied(Task task, List<PlannedSession> sessions) {
    return getRemainingMinutesForTask(task, sessions) == 0;
  }
}
