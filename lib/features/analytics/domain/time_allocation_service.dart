import 'analytics_models.dart';
import '../../goals/models/learning_goal.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';

class TimeAllocationService {
  const TimeAllocationService();

  TimeAllocationBreakdown byTaskType({
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final groups = <TaskType, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      final task = taskById[session.taskId];
      if (task == null) {
        continue;
      }
      groups.update(
        task.type,
        (value) => value + _minutes(session),
        ifAbsent: () => _minutes(session),
      );
    }

    return _buildBreakdown<TaskType>(
      title: 'Completed Time by Task Type',
      groups: groups,
      idBuilder: (item) => item.name,
      labelBuilder: (item) => item.label,
    );
  }

  TimeAllocationBreakdown byGoalType({
    required List<LearningGoal> goals,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    final goalById = {for (final goal in goals) goal.id: goal};
    final taskById = {for (final task in tasks) task.id: task};
    final groups = <GoalType, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      final task = taskById[session.taskId];
      final goal = task?.goalId == null ? null : goalById[task!.goalId!];
      if (goal == null) {
        continue;
      }
      groups.update(
        goal.goalType,
        (value) => value + _minutes(session),
        ifAbsent: () => _minutes(session),
      );
    }

    return _buildBreakdown<GoalType>(
      title: 'Completed Time by Goal Type',
      groups: groups,
      idBuilder: (item) => item.name,
      labelBuilder: (item) => item.label,
    );
  }

  TimeAllocationBreakdown byGoal({
    required List<LearningGoal> goals,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    final goalById = {for (final goal in goals) goal.id: goal};
    final taskById = {for (final task in tasks) task.id: task};
    final groups = <String, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      final task = taskById[session.taskId];
      final goalId = task?.goalId;
      if (goalId == null || !goalById.containsKey(goalId)) {
        continue;
      }
      groups.update(
        goalId,
        (value) => value + _minutes(session),
        ifAbsent: () => _minutes(session),
      );
    }

    return _buildBreakdown<String>(
      title: 'Completed Time by Goal',
      groups: groups,
      idBuilder: (item) => item,
      labelBuilder: (item) => goalById[item]?.title ?? item,
    );
  }

  TimeAllocationBreakdown byTask({
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final groups = <String, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      if (!taskById.containsKey(session.taskId)) {
        continue;
      }
      groups.update(
        session.taskId,
        (value) => value + _minutes(session),
        ifAbsent: () => _minutes(session),
      );
    }

    return _buildBreakdown<String>(
      title: 'Completed Time by Task',
      groups: groups,
      idBuilder: (item) => item,
      labelBuilder: (item) => taskById[item]?.title ?? item,
    );
  }

  TimeAllocationBreakdown byWeekday({required List<PlannedSession> sessions}) {
    final groups = <int, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      groups.update(
        session.start.weekday,
        (value) => value + _minutes(session),
        ifAbsent: () => _minutes(session),
      );
    }

    return _buildBreakdown<int>(
      title: 'Completed Time by Weekday',
      groups: groups,
      idBuilder: (item) => item.toString(),
      labelBuilder: _weekdayLabel,
    );
  }

  TimeAllocationBreakdown _buildBreakdown<T>({
    required String title,
    required Map<T, int> groups,
    required String Function(T item) idBuilder,
    required String Function(T item) labelBuilder,
  }) {
    final totalMinutes = groups.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final items = groups.entries.map((entry) {
      return TimeAllocationItem(
        id: idBuilder(entry.key),
        label: labelBuilder(entry.key),
        minutes: entry.value,
        percentage: totalMinutes == 0 ? 0 : entry.value / totalMinutes,
      );
    }).toList()..sort((left, right) => right.minutes.compareTo(left.minutes));

    return TimeAllocationBreakdown(
      title: title,
      totalMinutes: totalMinutes,
      items: items,
    );
  }

  int _minutes(PlannedSession session) {
    return session.actualMinutesFocused > 0
        ? session.actualMinutesFocused
        : session.plannedDurationMinutes;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Day';
    }
  }
}
