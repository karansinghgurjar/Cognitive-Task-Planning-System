import '../../goals/models/learning_goal.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../models/calendar_export_options.dart';

typedef SessionsInRangeLoader =
    Future<List<PlannedSession>> Function(DateTime start, DateTime end);
typedef TasksLoader = Future<List<Task>> Function();
typedef GoalsLoader = Future<List<LearningGoal>> Function();

class CalendarExportRepository {
  CalendarExportRepository({
    required SessionsInRangeLoader loadSessionsInRange,
    required TasksLoader loadTasks,
    required GoalsLoader loadGoals,
  }) : _loadSessionsInRange = loadSessionsInRange,
       _loadTasks = loadTasks,
       _loadGoals = loadGoals;

  final SessionsInRangeLoader _loadSessionsInRange;
  final TasksLoader _loadTasks;
  final GoalsLoader _loadGoals;

  Future<PreparedCalendarExportData> prepareExport(
    CalendarExportOptions options,
  ) async {
    if (!options.hasAnyIncludedStatus) {
      return const PreparedCalendarExportData(
        sessions: [],
        taskMap: {},
        goalMap: {},
        warnings: ['Select at least one session status to export.'],
      );
    }

    final sessions = await _loadSessionsInRange(
      options.normalizedStart,
      options.normalizedEndExclusive,
    );
    final filteredSessions = <PlannedSession>[];
    var skippedMalformed = 0;

    for (final session in sessions) {
      if (!options.containsSessionStatus(session)) {
        continue;
      }
      if (!session.end.isAfter(session.start)) {
        skippedMalformed++;
        continue;
      }
      filteredSessions.add(session);
    }

    filteredSessions.sort((left, right) {
      final startCompare = left.start.compareTo(right.start);
      if (startCompare != 0) {
        return startCompare;
      }
      return left.id.compareTo(right.id);
    });

    final tasks = await _loadTasks();
    final taskIds = filteredSessions.map((session) => session.taskId).toSet();
    final taskMap = {
      for (final task in tasks)
        if (taskIds.contains(task.id)) task.id: task,
    };

    final goalIds = taskMap.values
        .map((task) => task.goalId)
        .whereType<String>()
        .toSet();
    final goals = goalIds.isEmpty ? const <LearningGoal>[] : await _loadGoals();
    final goalMap = {
      for (final goal in goals)
        if (goalIds.contains(goal.id)) goal.id: goal,
    };

    final warnings = <String>[];
    if (skippedMalformed > 0) {
      warnings.add(
        skippedMalformed == 1
            ? '1 malformed session was skipped during calendar export.'
            : '$skippedMalformed malformed sessions were skipped during calendar export.',
      );
    }

    final missingTaskCount = filteredSessions
        .where((session) => !taskMap.containsKey(session.taskId))
        .length;
    if (missingTaskCount > 0) {
      warnings.add(
        missingTaskCount == 1
            ? '1 session was exported with a fallback title because its task was missing.'
            : '$missingTaskCount sessions were exported with fallback titles because their tasks were missing.',
      );
    }

    return PreparedCalendarExportData(
      sessions: filteredSessions,
      taskMap: taskMap,
      goalMap: goalMap,
      warnings: warnings,
    );
  }
}

class PreparedCalendarExportData {
  const PreparedCalendarExportData({
    required this.sessions,
    required this.taskMap,
    required this.goalMap,
    this.warnings = const [],
  });

  final List<PlannedSession> sessions;
  final Map<String, Task> taskMap;
  final Map<String, LearningGoal> goalMap;
  final List<String> warnings;
}
