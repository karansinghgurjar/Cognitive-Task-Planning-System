import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../schedule/domain/task_progress_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';
import 'recommendation_models.dart';

class FeasibilityService {
  const FeasibilityService({
    this.taskProgressService = const TaskProgressService(),
    this.minimumMeaningfulBlockMinutes = 25,
  });

  final TaskProgressService taskProgressService;
  final int minimumMeaningfulBlockMinutes;

  GoalFeasibilityReport evaluateGoalFeasibility({
    required LearningGoal goal,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final linkedTasks = tasks.where((task) => task.goalId == goal.id).toList();
    final remainingRequiredMinutes = _getRemainingGoalMinutes(
      goal: goal,
      milestones: milestones,
      linkedTasks: linkedTasks,
      sessions: sessions,
    );

    if (goal.targetDate == null) {
      return GoalFeasibilityReport(
        goalId: goal.id,
        goalTitle: goal.title,
        targetDate: null,
        remainingRequiredMinutes: remainingRequiredMinutes,
        availableMinutesUntilTarget: 0,
        shortfallMinutes: 0,
        riskLevel: remainingRequiredMinutes == 0
            ? DeadlineRiskLevel.low
            : DeadlineRiskLevel.medium,
        isFeasible: true,
        isTimeBound: false,
        summary: remainingRequiredMinutes == 0
            ? 'This goal is already satisfied.'
            : 'This goal has no target date, so it is not time-bound yet.',
        suggestedActionText: remainingRequiredMinutes == 0
            ? 'Keep the goal complete or archive it.'
            : 'Add a target date to evaluate whether this goal is feasible.',
      );
    }

    final deadline = _deadlineEnd(goal.targetDate!);
    final availableMinutes = estimateAvailableMinutesUntil(
      deadline,
      weeklyAvailability: weeklyAvailability,
      sessions: sessions,
      now: now,
    );
    final shortfallMinutes = (remainingRequiredMinutes - availableMinutes) < 0
        ? 0
        : remainingRequiredMinutes - availableMinutes;
    final isOverdue = deadline.isBefore(now);
    final isFeasible = !isOverdue && shortfallMinutes == 0;
    final riskLevel = _riskForDelta(
      remainingRequiredMinutes: remainingRequiredMinutes,
      availableMinutes: availableMinutes,
      isOverdue: isOverdue,
    );

    return GoalFeasibilityReport(
      goalId: goal.id,
      goalTitle: goal.title,
      targetDate: goal.targetDate,
      remainingRequiredMinutes: remainingRequiredMinutes,
      availableMinutesUntilTarget: availableMinutes,
      shortfallMinutes: shortfallMinutes,
      riskLevel: riskLevel,
      isFeasible: isFeasible,
      isTimeBound: true,
      summary: _buildGoalSummary(
        goal: goal,
        remainingRequiredMinutes: remainingRequiredMinutes,
        availableMinutes: availableMinutes,
        shortfallMinutes: shortfallMinutes,
        isOverdue: isOverdue,
        riskLevel: riskLevel,
      ),
      suggestedActionText: _buildGoalAction(
        goal: goal,
        shortfallMinutes: shortfallMinutes,
        riskLevel: riskLevel,
        remainingRequiredMinutes: remainingRequiredMinutes,
      ),
    );
  }

  bool isTaskFeasibleByDeadline(
    Task task, {
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final deadline = task.dueDate;
    if (deadline == null) {
      return true;
    }

    final remainingMinutes = taskProgressService.getRemainingMinutesForTask(
      task,
      sessions,
    );
    final availableMinutes = estimateAvailableMinutesUntil(
      _deadlineEnd(deadline),
      weeklyAvailability: weeklyAvailability,
      sessions: sessions,
      now: now,
    );
    return remainingMinutes <= availableMinutes &&
        !_deadlineEnd(deadline).isBefore(now);
  }

  int estimateAvailableMinutesUntil(
    DateTime deadline, {
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<PlannedSession> sessions,
    required DateTime now,
  }) {
    final normalizedNow = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final end = deadline.isBefore(normalizedNow) ? normalizedNow : deadline;
    if (!end.isAfter(normalizedNow)) {
      return 0;
    }

    final windows = _buildConcreteAvailabilityWindows(
      weeklyAvailability: weeklyAvailability,
      start: normalizedNow,
      end: end,
    );
    final blockedSessions =
        sessions
            .where(
              (session) =>
                  !session.isCancelled &&
                  !session.isMissed &&
                  session.end.isAfter(normalizedNow) &&
                  session.start.isBefore(end),
            )
            .toList()
          ..sort((left, right) => left.start.compareTo(right.start));

    final availableRanges = _subtractBlockedSessions(windows, blockedSessions);
    return availableRanges.fold<int>(0, (sum, range) {
      final minutes = range.durationMinutes;
      if (minutes < minimumMeaningfulBlockMinutes) {
        return sum;
      }
      return sum + minutes;
    });
  }

  int getRemainingGoalMinutes({
    required LearningGoal goal,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    return _getRemainingGoalMinutes(
      goal: goal,
      milestones: milestones,
      linkedTasks: tasks.where((task) => task.goalId == goal.id).toList(),
      sessions: sessions,
    );
  }

  DeadlineRiskLevel riskLevelForTask({
    required Task task,
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final deadline = task.dueDate;
    if (deadline == null) {
      return DeadlineRiskLevel.low;
    }

    final remainingMinutes = taskProgressService.getRemainingMinutesForTask(
      task,
      sessions,
    );
    final availableMinutes = estimateAvailableMinutesUntil(
      _deadlineEnd(deadline),
      weeklyAvailability: weeklyAvailability,
      sessions: sessions,
      now: now,
    );
    return _riskForDelta(
      remainingRequiredMinutes: remainingMinutes,
      availableMinutes: availableMinutes,
      isOverdue: _deadlineEnd(deadline).isBefore(now),
    );
  }

  List<AvailabilityDateTimeRange> buildConcreteAvailabilityWindows({
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime start,
    required DateTime end,
  }) {
    return _buildConcreteAvailabilityWindows(
      weeklyAvailability: weeklyAvailability,
      start: start,
      end: end,
    );
  }

  List<AvailabilityDateTimeRange> subtractBlockedSessions(
    List<AvailabilityDateTimeRange> windows,
    List<PlannedSession> sessions,
  ) {
    return _subtractBlockedSessions(windows, sessions);
  }

  int _getRemainingGoalMinutes({
    required LearningGoal goal,
    required List<GoalMilestone> milestones,
    required List<Task> linkedTasks,
    required List<PlannedSession> sessions,
  }) {
    if (goal.status == GoalStatus.completed) {
      return 0;
    }

    if (linkedTasks.isNotEmpty) {
      return linkedTasks.fold<int>(0, (sum, task) {
        return sum +
            taskProgressService.getRemainingMinutesForTask(task, sessions);
      });
    }

    if (milestones.isNotEmpty) {
      return milestones
          .where((milestone) => !milestone.isCompleted)
          .fold<int>(0, (sum, milestone) => sum + milestone.estimatedMinutes);
    }

    return goal.estimatedTotalMinutes ?? 0;
  }

  String _buildGoalSummary({
    required LearningGoal goal,
    required int remainingRequiredMinutes,
    required int availableMinutes,
    required int shortfallMinutes,
    required bool isOverdue,
    required DeadlineRiskLevel riskLevel,
  }) {
    if (remainingRequiredMinutes == 0) {
      return 'This goal has no remaining work.';
    }
    if (isOverdue) {
      return '${goal.title} is overdue and still needs ${_formatHours(remainingRequiredMinutes)}.';
    }
    if (shortfallMinutes > 0) {
      return '${goal.title} is ${riskLevel.label.toLowerCase()} risk: it needs ${_formatHours(remainingRequiredMinutes)}, but only ${_formatHours(availableMinutes)} appear free before the target date.';
    }
    return '${goal.title} appears feasible with ${_formatHours(availableMinutes - remainingRequiredMinutes)} of slack before the target date.';
  }

  String _buildGoalAction({
    required LearningGoal goal,
    required int shortfallMinutes,
    required DeadlineRiskLevel riskLevel,
    required int remainingRequiredMinutes,
  }) {
    if (remainingRequiredMinutes == 0) {
      return 'Keep focus on other active goals.';
    }
    if (shortfallMinutes > 0) {
      return 'Add about ${_formatHours(shortfallMinutes)} of capacity or reduce scope for ${goal.title}.';
    }
    if (riskLevel == DeadlineRiskLevel.medium ||
        riskLevel == DeadlineRiskLevel.high) {
      return 'Protect sessions for ${goal.title} soon to avoid slipping into risk.';
    }
    return 'Keep the current schedule for ${goal.title} and review again after your next sessions.';
  }

  DeadlineRiskLevel _riskForDelta({
    required int remainingRequiredMinutes,
    required int availableMinutes,
    required bool isOverdue,
  }) {
    if (remainingRequiredMinutes == 0) {
      return DeadlineRiskLevel.low;
    }
    if (isOverdue) {
      return DeadlineRiskLevel.critical;
    }
    if (availableMinutes <= 0) {
      return DeadlineRiskLevel.critical;
    }

    final shortfall = remainingRequiredMinutes - availableMinutes;
    if (shortfall > 0) {
      if (shortfall >= remainingRequiredMinutes * 0.5) {
        return DeadlineRiskLevel.critical;
      }
      return DeadlineRiskLevel.high;
    }

    final slack = availableMinutes - remainingRequiredMinutes;
    if (slack <= 60) {
      return DeadlineRiskLevel.high;
    }
    if (slack <= 180) {
      return DeadlineRiskLevel.medium;
    }
    return DeadlineRiskLevel.low;
  }

  List<AvailabilityDateTimeRange> _buildConcreteAvailabilityWindows({
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime start,
    required DateTime end,
  }) {
    final windows = <AvailabilityDateTimeRange>[];
    var cursorDate = DateTime(start.year, start.month, start.day);
    final finalDate = DateTime(end.year, end.month, end.day);

    while (!cursorDate.isAfter(finalDate)) {
      final dayWindows = weeklyAvailability[cursorDate.weekday] ?? const [];
      for (final window in dayWindows) {
        final rawStart = DateTime(
          cursorDate.year,
          cursorDate.month,
          cursorDate.day,
          window.startHour,
          window.startMinute,
        );
        final rawEnd = DateTime(
          cursorDate.year,
          cursorDate.month,
          cursorDate.day,
          window.endHour,
          window.endMinute,
        );

        var adjustedStart = rawStart;
        var adjustedEnd = rawEnd;
        if (adjustedStart.isBefore(start)) {
          adjustedStart = start;
        }
        if (adjustedEnd.isAfter(end)) {
          adjustedEnd = end;
        }
        if (adjustedStart.isBefore(adjustedEnd)) {
          windows.add(AvailabilityDateTimeRange(adjustedStart, adjustedEnd));
        }
      }
      cursorDate = cursorDate.add(const Duration(days: 1));
    }

    windows.sort((left, right) => left.start.compareTo(right.start));
    return windows;
  }

  List<AvailabilityDateTimeRange> _subtractBlockedSessions(
    List<AvailabilityDateTimeRange> windows,
    List<PlannedSession> blockedSessions,
  ) {
    final availableRanges = <AvailabilityDateTimeRange>[];

    for (final window in windows) {
      var segments = <AvailabilityDateTimeRange>[window];
      for (final blocked in blockedSessions) {
        if (!blocked.start.isBefore(window.end) ||
            !blocked.end.isAfter(window.start)) {
          continue;
        }

        final nextSegments = <AvailabilityDateTimeRange>[];
        for (final segment in segments) {
          nextSegments.addAll(
            _subtractRange(
              segment,
              AvailabilityDateTimeRange(blocked.start, blocked.end),
            ),
          );
        }
        segments = nextSegments;
        if (segments.isEmpty) {
          break;
        }
      }
      availableRanges.addAll(segments);
    }

    availableRanges.sort((left, right) => left.start.compareTo(right.start));
    return availableRanges;
  }

  List<AvailabilityDateTimeRange> _subtractRange(
    AvailabilityDateTimeRange source,
    AvailabilityDateTimeRange blocker,
  ) {
    final overlapStart = blocker.start.isAfter(source.start)
        ? blocker.start
        : source.start;
    final overlapEnd = blocker.end.isBefore(source.end)
        ? blocker.end
        : source.end;

    if (!overlapStart.isBefore(overlapEnd)) {
      return [source];
    }

    final segments = <AvailabilityDateTimeRange>[];
    if (source.start.isBefore(overlapStart)) {
      segments.add(AvailabilityDateTimeRange(source.start, overlapStart));
    }
    if (overlapEnd.isBefore(source.end)) {
      segments.add(AvailabilityDateTimeRange(overlapEnd, source.end));
    }
    return segments;
  }

  DateTime _deadlineEnd(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59);
  }

  String _formatHours(int minutes) {
    return '${(minutes / 60).toStringAsFixed(1)}h';
  }
}

class AvailabilityDateTimeRange {
  const AvailabilityDateTimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get durationMinutes => end.difference(start).inMinutes;
}
