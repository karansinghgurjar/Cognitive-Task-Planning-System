import '../../goals/models/learning_goal.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../domain/backup_models.dart';

class CsvExportService {
  const CsvExportService();

  String exportTasksCsv(List<Task> tasks) {
    final rows = <List<String>>[
      [
        'id',
        'title',
        'description',
        'type',
        'estimatedDurationMinutes',
        'dueDate',
        'priority',
        'resourceUrl',
        'resourceTag',
        'goalId',
        'milestoneId',
        'isCompleted',
        'isArchived',
        'createdAt',
        'updatedAt',
        'completedAt',
        'archivedAt',
      ],
      for (final task in tasks)
        [
          task.id,
          task.title,
          task.description ?? '',
          task.type.name,
          task.estimatedDurationMinutes.toString(),
          task.dueDate?.toIso8601String() ?? '',
          task.priority.toString(),
          task.resourceUrl ?? '',
          task.resourceTag ?? '',
          task.goalId ?? '',
          task.milestoneId ?? '',
          task.isCompleted.toString(),
          task.isArchived.toString(),
          task.createdAt.toIso8601String(),
          task.updatedAt?.toIso8601String() ?? '',
          task.completedAt?.toIso8601String() ?? '',
          task.archivedAt?.toIso8601String() ?? '',
        ],
    ];
    return _encode(rows);
  }

  String exportSessionsCsv(List<PlannedSession> sessions, List<Task> tasks) {
    final taskById = {for (final task in tasks) task.id: task};
    final rows = <List<String>>[
      [
        'id',
        'taskId',
        'taskTitle',
        'start',
        'end',
        'status',
        'completed',
        'plannedDurationMinutes',
        'actualMinutesFocused',
      ],
      for (final session in sessions)
        [
          session.id,
          session.taskId,
          taskById[session.taskId]?.title ?? '',
          session.start.toIso8601String(),
          session.end.toIso8601String(),
          session.status.name,
          session.isCompleted.toString(),
          session.plannedDurationMinutes.toString(),
          session.actualMinutesFocused.toString(),
        ],
    ];
    return _encode(rows);
  }

  String exportGoalsCsv(List<LearningGoal> goals) {
    final rows = <List<String>>[
      [
        'id',
        'title',
        'description',
        'goalType',
        'targetDate',
        'priority',
        'status',
        'estimatedTotalMinutes',
        'createdAt',
        'completedAt',
      ],
      for (final goal in goals)
        [
          goal.id,
          goal.title,
          goal.description ?? '',
          goal.goalType.name,
          goal.targetDate?.toIso8601String() ?? '',
          goal.priority.toString(),
          goal.status.name,
          goal.estimatedTotalMinutes?.toString() ?? '',
          goal.createdAt.toIso8601String(),
          goal.completedAt?.toIso8601String() ?? '',
        ],
    ];
    return _encode(rows);
  }

  String exportAnalyticsSummaryCsv(CsvAnalyticsSnapshot snapshot) {
    final rows = <List<String>>[
      ['section', 'label', 'value'],
      ['summary', 'range', snapshot.rangeLabel],
      ['summary', 'plannedMinutes', snapshot.plannedMinutes.toString()],
      ['summary', 'completedMinutes', snapshot.completedMinutes.toString()],
      ['summary', 'completionRate', snapshot.completionRate.toStringAsFixed(4)],
      ['summary', 'currentFocusStreak', snapshot.currentFocusStreak.toString()],
      ['summary', 'longestFocusStreak', snapshot.longestFocusStreak.toString()],
      ['summary', 'burnoutRisk', snapshot.burnoutRisk.name],
      for (final goal in snapshot.goalAnalytics)
        [
          'goal',
          goal.goalTitle,
          '${goal.totalCompletedMinutes}/${goal.totalPlannedMinutes} min (${(goal.percentComplete * 100).round()}%)',
        ],
      for (final insight in snapshot.insights)
        ['insight', insight.title, insight.description],
    ];
    return _encode(rows);
  }

  String exportIntegrityReportCsv(DataIntegrityReport report) {
    final rows = <List<String>>[
      ['scannedAt', report.scannedAt.toIso8601String()],
      ['code', 'severity', 'message', 'relatedEntityId', 'suggestedRepair'],
      for (final issue in report.issues)
        [
          issue.code,
          issue.severity.name,
          issue.message,
          issue.relatedEntityId ?? '',
          issue.suggestedRepair ?? '',
        ],
    ];
    return _encode(rows);
  }

  String _encode(List<List<String>> rows) {
    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  String _escape(String value) {
    final needsQuoting =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuoting) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
