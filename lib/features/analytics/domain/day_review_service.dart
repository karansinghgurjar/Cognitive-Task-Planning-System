import 'analytics_models.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';

class DayReviewService {
  const DayReviewService();

  DayReviewSummary summarizeDay({
    required DateTime day,
    required DateTime now,
    required List<PlannedSession> sessions,
    required List<Task> tasks,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final effectiveEnd =
        dayStart == DateTime(now.year, now.month, now.day) &&
            now.isBefore(dayEnd)
        ? now
        : dayEnd;

    final daySessions = sessions.where((session) {
      return !session.start.isBefore(dayStart) &&
          session.start.isBefore(effectiveEnd);
    }).toList();
    final completedSessions = daySessions
        .where((session) => session.isCompleted)
        .toList();
    final missedSessions = daySessions
        .where((session) => session.isMissed)
        .length;
    final totalFocusedMinutes = completedSessions.fold<int>(0, (sum, session) {
      return sum +
          (session.actualMinutesFocused > 0
              ? session.actualMinutesFocused
              : session.plannedDurationMinutes);
    });

    final taskById = {for (final task in tasks) task.id: task};
    Task? topTask;
    for (final session in completedSessions) {
      final task = taskById[session.taskId];
      if (task == null) {
        continue;
      }
      if (topTask == null || task.priority < topTask.priority) {
        topTask = task;
      }
    }

    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList()
      ..sort((left, right) {
        final priorityCompare = left.priority.compareTo(right.priority);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        if (left.dueDate == null && right.dueDate != null) {
          return 1;
        }
        if (left.dueDate != null && right.dueDate == null) {
          return -1;
        }
        if (left.dueDate != null && right.dueDate != null) {
          final dueCompare = left.dueDate!.compareTo(right.dueDate!);
          if (dueCompare != 0) {
            return dueCompare;
          }
        }
        return left.createdAt.compareTo(right.createdAt);
      });

    final recommendedNextAction = missedSessions > 0
        ? 'Recover missed sessions first tomorrow so the plan does not drift further.'
        : incompleteTasks.isEmpty
        ? 'Review goals and generate the next set of tasks for tomorrow.'
        : 'Start tomorrow with ${incompleteTasks.first.title}.';

    return DayReviewSummary(
      date: dayStart,
      completedSessions: completedSessions.length,
      missedSessions: missedSessions,
      totalFocusedMinutes: totalFocusedMinutes,
      mostImportantCompletedTaskTitle: topTask?.title,
      recommendedNextAction: recommendedNextAction,
    );
  }
}
