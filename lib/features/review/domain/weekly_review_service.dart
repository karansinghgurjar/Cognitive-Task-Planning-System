import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import 'weekly_review_models.dart';
import 'weekly_review_recommendation_service.dart';

class WeeklyReviewService {
  const WeeklyReviewService({
    WeeklyReviewRecommendationService recommendationService =
        const WeeklyReviewRecommendationService(),
  }) : _recommendationService = recommendationService;

  final WeeklyReviewRecommendationService _recommendationService;

  DateTime weekStartFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  DateTime weekEndFor(DateTime weekStart) {
    final normalized = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return normalized.add(const Duration(days: 6));
  }

  List<PlannedSession> sessionsForWeek(
    List<PlannedSession> sessions,
    DateTime weekStart,
  ) {
    final normalizedWeekStart = weekStartFor(weekStart);
    final weekEndExclusive = normalizedWeekStart.add(const Duration(days: 7));
    return sessions.where((session) {
      return !session.start.isBefore(normalizedWeekStart) &&
          session.start.isBefore(weekEndExclusive);
    }).toList()
      ..sort((left, right) => left.start.compareTo(right.start));
  }

  WeeklyReviewSnapshot buildWeeklySnapshot({
    required DateTime weekStart,
    required List<PlannedSession> sessions,
    required List<Task> tasks,
    required List<LearningGoal> goals,
    WeeklyTrendComparison? trendComparison,
  }) {
    final normalizedWeekStart = weekStartFor(weekStart);
    final weekEnd = weekEndFor(normalizedWeekStart);
    final weeklySessions = sessionsForWeek(sessions, normalizedWeekStart);
    final goalReviews = buildGoalReview(
      weekStart: normalizedWeekStart,
      sessions: weeklySessions,
      tasks: tasks,
      goals: goals,
    );
    final taskReviews = buildTaskReview(
      weekStart: normalizedWeekStart,
      sessions: weeklySessions,
      tasks: tasks,
    );

    final totalPlannedMinutes = weeklySessions.fold<int>(
      0,
      (sum, session) => sum + session.plannedDurationMinutes,
    );
    final completedSessions = weeklySessions.where((session) => session.isCompleted);
    final totalCompletedMinutes = completedSessions.fold<int>(
      0,
      (sum, session) => sum + _effectiveCompletedMinutes(session),
    );
    final missedSessionsCount = weeklySessions.where((session) => session.isMissed).length;
    final cancelledSessionsCount = weeklySessions
        .where((session) => session.isCancelled)
        .length;

    final breakdown = WeeklyCompletionBreakdown(
      totalPlannedMinutes: totalPlannedMinutes,
      totalCompletedMinutes: totalCompletedMinutes,
      completionRate: totalPlannedMinutes == 0
          ? 0
          : totalCompletedMinutes / totalPlannedMinutes,
      completedSessionsCount: completedSessions.length,
      missedSessionsCount: missedSessionsCount,
      cancelledSessionsCount: cancelledSessionsCount,
    );

    final topGoal = goalReviews.isEmpty
        ? null
        : goalReviews.reduce(
            (left, right) => left.minutesSpent >= right.minutesSpent ? left : right,
          );
    final topTask = taskReviews.isEmpty
        ? null
        : taskReviews.reduce(
            (left, right) =>
                left.completedMinutes >= right.completedMinutes ? left : right,
          );
    final overdueTaskTitles = taskReviews
        .where((task) => task.isOverdue)
        .map((task) => task.taskTitle)
        .toList();
    final repeatedSlipTaskTitles = taskReviews
        .where((task) => task.slipCount >= 2)
        .map((task) => task.taskTitle)
        .toList();

    var summaryText =
        'You completed ${breakdown.completedSessionsCount} of ${weeklySessions.length} sessions and focused ${breakdown.totalCompletedMinutes} minutes this week.';
    if (topGoal != null) {
      summaryText += ' ${topGoal.goalTitle} received the most attention.';
    }

    final provisionalSnapshot = WeeklyReviewSnapshot(
      weekStart: normalizedWeekStart,
      weekEnd: weekEnd,
      breakdown: breakdown,
      goalReviews: goalReviews,
      taskReviews: taskReviews,
      recommendations: const [],
      overdueTaskTitles: overdueTaskTitles,
      repeatedSlipTaskTitles: repeatedSlipTaskTitles,
      summaryText: summaryText,
      topGoalTitle: topGoal?.goalTitle,
      topGoalMinutes: topGoal?.minutesSpent ?? 0,
      topTaskTitle: topTask?.taskTitle,
      topTaskMinutes: topTask?.completedMinutes ?? 0,
      trendComparison: trendComparison,
    );

    final recommendations = _recommendationService.generateNextWeekRecommendations(
      snapshot: provisionalSnapshot,
      weeklySessions: weeklySessions,
    );

    return WeeklyReviewSnapshot(
      weekStart: provisionalSnapshot.weekStart,
      weekEnd: provisionalSnapshot.weekEnd,
      breakdown: provisionalSnapshot.breakdown,
      goalReviews: provisionalSnapshot.goalReviews,
      taskReviews: provisionalSnapshot.taskReviews,
      recommendations: recommendations,
      overdueTaskTitles: provisionalSnapshot.overdueTaskTitles,
      repeatedSlipTaskTitles: provisionalSnapshot.repeatedSlipTaskTitles,
      summaryText: provisionalSnapshot.summaryText,
      topGoalTitle: provisionalSnapshot.topGoalTitle,
      topGoalMinutes: provisionalSnapshot.topGoalMinutes,
      topTaskTitle: provisionalSnapshot.topTaskTitle,
      topTaskMinutes: provisionalSnapshot.topTaskMinutes,
      trendComparison: provisionalSnapshot.trendComparison,
    );
  }

  List<WeeklyGoalReview> buildGoalReview({
    required DateTime weekStart,
    required List<PlannedSession> sessions,
    required List<Task> tasks,
    required List<LearningGoal> goals,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final groupedMinutes = <String, int>{};
    final completedTaskCounts = <String, int>{};
    final totalLinkedTasks = <String, int>{};

    for (final task in tasks) {
      if (task.goalId != null) {
        totalLinkedTasks.update(task.goalId!, (value) => value + 1, ifAbsent: () => 1);
      }
      if (task.goalId != null &&
          _isWithinWeek(task.completedAt, weekStart) &&
          task.isCompleted) {
        completedTaskCounts.update(task.goalId!, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    for (final session in sessions.where((session) => session.isCompleted)) {
      final task = taskById[session.taskId];
      final goalId = task?.goalId;
      if (goalId == null) {
        continue;
      }
      groupedMinutes.update(
        goalId,
        (value) => value + _effectiveCompletedMinutes(session),
        ifAbsent: () => _effectiveCompletedMinutes(session),
      );
    }

    final reviewGoalIds = <String>{
      ...groupedMinutes.keys,
      ...completedTaskCounts.keys,
      ...totalLinkedTasks.keys,
    };

    final goalsById = {for (final goal in goals) goal.id: goal};
    final reviews = <WeeklyGoalReview>[];
    for (final goalId in reviewGoalIds) {
      final goal = goalsById[goalId];
      final minutesSpent = groupedMinutes[goalId] ?? 0;
      final completedCount = completedTaskCounts[goalId] ?? 0;
      final linkedCount = totalLinkedTasks[goalId] ?? 0;
      final goalTitle = _safeGoalTitle(goal);
      final risk = _goalRisk(goal, minutesSpent, linkedCount, completedCount, weekStart);
      final summary = linkedCount == 0
          ? '$goalTitle has no linked tasks yet.'
          : '$completedCount of $linkedCount linked tasks were completed this week.';
      reviews.add(
        WeeklyGoalReview(
          goalId: goalId,
          goalTitle: goalTitle,
          goalType: goal?.goalType ?? GoalType.learning,
          minutesSpent: minutesSpent,
          completedLinkedTasksThisWeek: completedCount,
          totalLinkedTasks: linkedCount,
          targetRisk: risk,
          statusSummary: summary,
        ),
      );
    }

    reviews.sort((left, right) {
      final byMinutes = right.minutesSpent.compareTo(left.minutesSpent);
      if (byMinutes != 0) {
        return byMinutes;
      }
      return left.goalTitle.compareTo(right.goalTitle);
    });
    return reviews;
  }

  List<WeeklyTaskReview> buildTaskReview({
    required DateTime weekStart,
    required List<PlannedSession> sessions,
    required List<Task> tasks,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final taskIdsToReview = <String>{...sessions.map((session) => session.taskId)};
    for (final task in tasks) {
      if (_isWithinWeek(task.completedAt, weekStart) ||
          _isOverdueDuringWeek(task, weekStart)) {
        taskIdsToReview.add(task.id);
      }
    }

    final reviews = <WeeklyTaskReview>[];
    for (final taskId in taskIdsToReview) {
      final task = taskById[taskId];
      final taskSessions = sessions.where((session) => session.taskId == taskId).toList();
      final plannedMinutes = taskSessions.fold<int>(
        0,
        (sum, session) => sum + session.plannedDurationMinutes,
      );
      final completedMinutes = taskSessions
          .where((session) => session.isCompleted)
          .fold<int>(0, (sum, session) => sum + _effectiveCompletedMinutes(session));
      final completedSessionsCount = taskSessions.where((session) => session.isCompleted).length;
      final missedSessionsCount = taskSessions.where((session) => session.isMissed).length;
      final cancelledSessionsCount = taskSessions
          .where((session) => session.isCancelled)
          .length;
      final slipCount = missedSessionsCount + cancelledSessionsCount;
      final wasCompletedThisWeek =
          task?.isCompleted == true && _isWithinWeek(task?.completedAt, weekStart);
      final isOverdue = _isOverdueDuringWeek(task, weekStart);
      final isArchived = task?.isArchived ?? false;
      final title = _safeTaskTitle(task);
      final statusSummary = _buildTaskStatusSummary(
        title: title,
        slipCount: slipCount,
        wasCompletedThisWeek: wasCompletedThisWeek,
        isOverdue: isOverdue,
        isArchived: isArchived,
      );

      reviews.add(
        WeeklyTaskReview(
          taskId: taskId,
          taskTitle: title,
          taskType: task?.type ?? TaskType.misc,
          plannedMinutes: plannedMinutes,
          completedMinutes: completedMinutes,
          completedSessionsCount: completedSessionsCount,
          missedSessionsCount: missedSessionsCount,
          cancelledSessionsCount: cancelledSessionsCount,
          slipCount: slipCount,
          wasCompletedThisWeek: wasCompletedThisWeek,
          isOverdue: isOverdue,
          isArchived: isArchived,
          statusSummary: statusSummary,
        ),
      );
    }

    reviews.sort((left, right) {
      if (left.isOverdue != right.isOverdue) {
        return left.isOverdue ? -1 : 1;
      }
      final bySlip = right.slipCount.compareTo(left.slipCount);
      if (bySlip != 0) {
        return bySlip;
      }
      final byCompleted = right.completedMinutes.compareTo(left.completedMinutes);
      if (byCompleted != 0) {
        return byCompleted;
      }
      return left.taskTitle.compareTo(right.taskTitle);
    });
    return reviews;
  }

  WeeklyTrendComparison buildTrendComparison({
    required WeeklyReviewSnapshot current,
    required WeeklyReviewSnapshot previous,
  }) {
    final completedMinutesDelta =
        current.breakdown.totalCompletedMinutes -
        previous.breakdown.totalCompletedMinutes;
    final completionRateDelta =
        current.breakdown.completionRate - previous.breakdown.completionRate;
    final missedSessionsDelta =
        current.breakdown.missedSessionsCount -
        previous.breakdown.missedSessionsCount;

    final summary = completedMinutesDelta == 0 && missedSessionsDelta == 0
        ? 'This week was broadly similar to the previous one.'
        : 'Completed minutes ${_signedMinutes(completedMinutesDelta)}, completion rate ${_signedPercent(completionRateDelta)}, missed sessions ${_signedCount(missedSessionsDelta)} versus the previous week.';

    return WeeklyTrendComparison(
      completedMinutesDelta: completedMinutesDelta,
      completionRateDelta: completionRateDelta,
      missedSessionsDelta: missedSessionsDelta,
      summary: summary,
    );
  }

  int _effectiveCompletedMinutes(PlannedSession session) {
    if (!session.isCompleted) {
      return 0;
    }
    return session.actualMinutesFocused > 0
        ? session.actualMinutesFocused
        : session.plannedDurationMinutes;
  }

  bool _isWithinWeek(DateTime? value, DateTime weekStart) {
    if (value == null) {
      return false;
    }
    final weekEndExclusive = weekStartFor(weekStart).add(const Duration(days: 7));
    return !value.isBefore(weekStart) && value.isBefore(weekEndExclusive);
  }

  bool _isOverdueDuringWeek(Task? task, DateTime weekStart) {
    if (task == null || task.isCompleted || task.isArchived || task.dueDate == null) {
      return false;
    }
    final weekEndExclusive = weekStartFor(weekStart).add(const Duration(days: 7));
    return task.dueDate!.isBefore(weekEndExclusive);
  }

  String _safeGoalTitle(LearningGoal? goal) {
    final title = goal?.title.trim();
    if (title == null || title.isEmpty) {
      return 'Deleted Goal';
    }
    return title;
  }

  String _safeTaskTitle(Task? task) {
    if (task == null) {
      return 'Deleted Task';
    }
    final title = task.title.trim();
    if (title.isEmpty) {
      return 'Untitled Task';
    }
    if (task.isArchived) {
      return 'Archived Task: $title';
    }
    return title;
  }

  DeadlineRiskLevel _goalRisk(
    LearningGoal? goal,
    int minutesSpent,
    int totalLinkedTasks,
    int completedLinkedTasks,
    DateTime weekStart,
  ) {
    if (goal == null || goal.targetDate == null || goal.status == GoalStatus.completed) {
      return DeadlineRiskLevel.low;
    }
    final weekEndExclusive = weekStartFor(weekStart).add(const Duration(days: 7));
    final daysUntilTarget = goal.targetDate!.difference(weekEndExclusive).inDays;
    final remainingTasks = totalLinkedTasks - completedLinkedTasks;
    if (daysUntilTarget < 0 && remainingTasks > 0) {
      return DeadlineRiskLevel.critical;
    }
    if (daysUntilTarget <= 7 && (minutesSpent == 0 || remainingTasks > 0)) {
      return DeadlineRiskLevel.high;
    }
    if (daysUntilTarget <= 14 && minutesSpent < 60) {
      return DeadlineRiskLevel.medium;
    }
    return DeadlineRiskLevel.low;
  }

  String _buildTaskStatusSummary({
    required String title,
    required int slipCount,
    required bool wasCompletedThisWeek,
    required bool isOverdue,
    required bool isArchived,
  }) {
    if (wasCompletedThisWeek) {
      return '$title was completed this week.';
    }
    if (isArchived) {
      return '$title is archived and no longer part of active planning.';
    }
    if (isOverdue) {
      return '$title is overdue and still pending.';
    }
    if (slipCount >= 2) {
      return '$title slipped multiple times this week.';
    }
    if (slipCount == 1) {
      return '$title slipped once this week.';
    }
    return '$title had no major delivery issues this week.';
  }

  String _signedMinutes(int delta) {
    if (delta == 0) {
      return 'held steady';
    }
    return delta > 0 ? 'rose by $delta min' : 'fell by ${delta.abs()} min';
  }

  String _signedPercent(double delta) {
    final percent = (delta * 100).round();
    if (percent == 0) {
      return 'held steady';
    }
    return percent > 0 ? 'rose by $percent%' : 'fell by ${percent.abs()}%';
  }

  String _signedCount(int delta) {
    if (delta == 0) {
      return 'held steady';
    }
    return delta > 0 ? 'rose by $delta' : 'fell by ${delta.abs()}';
  }
}
