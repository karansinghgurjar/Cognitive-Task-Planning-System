import 'analytics_models.dart';
import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';

class AnalyticsService {
  const AnalyticsService();

  DailyProductivityStats computeDailyStats({
    required DateTime day,
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<PlannedSession> sessions,
  }) {
    final dayStart = _startOfDay(day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final daySessions = _sessionsInRange(
      sessions,
      start: dayStart,
      end: dayEnd,
    );
    final rangeStats = computeRangeStats(
      range: AnalyticsDateRange(start: dayStart, end: dayEnd, label: 'Day'),
      sessions: sessions,
    );
    final taskById = {for (final task in tasks) task.id: task};
    final goalById = {for (final goal in goals) goal.id: goal};

    final taskMinutes = <String, int>{};
    for (final session in daySessions) {
      final minutes = session.isCompleted
          ? _completedMinutes(session)
          : session.plannedDurationMinutes;
      taskMinutes.update(
        session.taskId,
        (value) => value + minutes,
        ifAbsent: () => minutes,
      );
    }

    String? topTaskTitle;
    String? topGoalTitle;
    if (taskMinutes.isNotEmpty) {
      final topTaskId = taskMinutes.entries
          .reduce((left, right) => left.value >= right.value ? left : right)
          .key;
      final task = taskById[topTaskId];
      topTaskTitle = task?.title;
      if (task?.goalId case final goalId?) {
        topGoalTitle = goalById[goalId]?.title;
      }
    }

    return DailyProductivityStats(
      date: dayStart,
      plannedMinutes: rangeStats.plannedMinutes,
      completedMinutes: rangeStats.completedMinutes,
      completionRate: rangeStats.completionRate,
      completedSessions: rangeStats.completedSessions,
      missedSessions: rangeStats.missedSessions,
      cancelledSessions: rangeStats.cancelledSessions,
      topTaskTitle: topTaskTitle,
      topGoalTitle: topGoalTitle,
    );
  }

  WeeklyProductivityStats computeWeeklyStats({
    required List<PlannedSession> sessions,
    required DateTime now,
  }) {
    final weekStart = startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final range = AnalyticsDateRange(
      start: weekStart,
      end: weekEnd,
      label: 'This Week',
    );
    final rangeStats = computeRangeStats(range: range, sessions: sessions);
    final dailyStats = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final dayRange = AnalyticsDateRange(
        start: day,
        end: day.add(const Duration(days: 1)),
        label: 'Day',
      );
      final stats = computeRangeStats(range: dayRange, sessions: sessions);
      return (
        date: day,
        planned: stats.plannedMinutes,
        completed: stats.completedMinutes,
      );
    });

    DateTime? busiestDay;
    DateTime? mostProductiveDay;
    DateTime? leastProductiveDay;
    if (dailyStats.any((item) => item.planned > 0 || item.completed > 0)) {
      busiestDay = dailyStats.reduce((left, right) {
        return left.planned >= right.planned ? left : right;
      }).date;
      mostProductiveDay = dailyStats.reduce((left, right) {
        return left.completed >= right.completed ? left : right;
      }).date;
      leastProductiveDay = dailyStats.reduce((left, right) {
        return left.completed <= right.completed ? left : right;
      }).date;
    }

    return WeeklyProductivityStats(
      weekStart: weekStart,
      weekEnd: weekEnd,
      plannedMinutes: rangeStats.plannedMinutes,
      completedMinutes: rangeStats.completedMinutes,
      completionRate: rangeStats.completionRate,
      completedSessions: rangeStats.completedSessions,
      missedSessions: rangeStats.missedSessions,
      cancelledSessions: rangeStats.cancelledSessions,
      averageCompletedMinutesPerDay: rangeStats.completedMinutes / 7,
      busiestDay: busiestDay,
      mostProductiveDay: mostProductiveDay,
      leastProductiveDay: leastProductiveDay,
    );
  }

  RangeProductivityStats computeRangeStats({
    required AnalyticsDateRange range,
    required List<PlannedSession> sessions,
  }) {
    final inRange = _sessionsInRange(
      sessions,
      start: range.start,
      end: range.end,
    );
    final plannedMinutes = inRange.fold<int>(
      0,
      (sum, session) => sum + session.plannedDurationMinutes,
    );
    final completedMinutes = inRange
        .where((session) => session.isCompleted)
        .fold<int>(0, (sum, session) => sum + _completedMinutes(session));
    final completedSessions = inRange
        .where((session) => session.isCompleted)
        .length;
    final missedSessions = inRange.where((session) => session.isMissed).length;
    final cancelledSessions = inRange
        .where((session) => session.isCancelled)
        .length;
    final completionRate = plannedMinutes == 0
        ? 0.0
        : (completedMinutes / plannedMinutes).clamp(0, 1).toDouble();

    return RangeProductivityStats(
      range: range,
      plannedMinutes: plannedMinutes,
      completedMinutes: completedMinutes,
      completionRate: completionRate,
      completedSessions: completedSessions,
      missedSessions: missedSessions,
      cancelledSessions: cancelledSessions,
    );
  }

  List<FocusTrendPoint> buildFocusTrend({
    required List<PlannedSession> sessions,
    required AnalyticsRangePreset preset,
    required DateTime now,
  }) {
    final range = resolveRange(preset, now);
    final points = <FocusTrendPoint>[];
    var cursor = range.start;

    while (cursor.isBefore(range.end)) {
      final dayRange = AnalyticsDateRange(
        start: cursor,
        end: cursor.add(const Duration(days: 1)),
        label: 'Day',
      );
      final stats = computeRangeStats(range: dayRange, sessions: sessions);
      points.add(
        FocusTrendPoint(
          date: cursor,
          plannedMinutes: stats.plannedMinutes,
          completedMinutes: stats.completedMinutes,
          completedSessions: stats.completedSessions,
          missedSessions: stats.missedSessions,
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }

    return points;
  }

  TimeAllocationBreakdown computeTimeAllocation({
    required List<Task> tasks,
    required List<PlannedSession> sessions,
  }) {
    final taskById = {for (final task in tasks) task.id: task};
    final grouped = <TaskType, int>{};

    for (final session in sessions.where((item) => item.isCompleted)) {
      final task = taskById[session.taskId];
      if (task == null) {
        continue;
      }
      grouped.update(
        task.type,
        (value) => value + _completedMinutes(session),
        ifAbsent: () => _completedMinutes(session),
      );
    }

    return _buildBreakdown<TaskType>(
      title: 'Completed Time by Task Type',
      groups: grouped,
      labelBuilder: (type) => type.label,
      idBuilder: (type) => type.name,
    );
  }

  List<ProductivityInsight> generateInsights({
    required DailyProductivityStats todayStats,
    required WeeklyProductivityStats weeklyStats,
    required List<GoalAnalytics> goalAnalytics,
    required BurnoutRiskReport burnoutReport,
    required DayReviewSummary dayReview,
    required StreakSummary streakSummary,
  }) {
    final insights = <ProductivityInsight>[];

    if (todayStats.plannedMinutes > 0 && todayStats.completedMinutes == 0) {
      insights.add(
        const ProductivityInsight(
          title: 'Today has not started yet',
          description:
              'You still have planned work today but no completed focus minutes yet.',
          riskLevel: DeadlineRiskLevel.medium,
          suggestedAction:
              'Start with a single 25-minute session to get momentum.',
        ),
      );
    }

    if (weeklyStats.completionRate < 0.6 && weeklyStats.plannedMinutes >= 180) {
      insights.add(
        ProductivityInsight(
          title: 'Weekly plan is slipping',
          description:
              'You have completed ${(weeklyStats.completionRate * 100).round()}% of this week\'s planned minutes.',
          riskLevel: DeadlineRiskLevel.high,
          suggestedAction:
              'Trim low-priority work or recover missed sessions before adding more.',
        ),
      );
    }

    if (streakSummary.currentFocusStreak.length >= 3) {
      insights.add(
        ProductivityInsight(
          title: 'Consistency is building',
          description:
              'You have hit the focus threshold for ${streakSummary.currentFocusStreak.length} straight days.',
          riskLevel: DeadlineRiskLevel.low,
          suggestedAction:
              'Protect the next session and extend the streak tomorrow.',
        ),
      );
    }

    final atRiskGoal = goalAnalytics
        .where(
          (goal) =>
              goal.targetRisk == DeadlineRiskLevel.high ||
              goal.targetRisk == DeadlineRiskLevel.critical,
        )
        .cast<GoalAnalytics?>()
        .firstWhere((goal) => goal != null, orElse: () => null);
    if (atRiskGoal != null) {
      insights.add(
        ProductivityInsight(
          title: '${atRiskGoal.goalTitle} needs attention',
          description:
              'This goal is at ${atRiskGoal.targetRisk.label.toLowerCase()} risk with ${(atRiskGoal.percentComplete * 100).round()}% completion.',
          riskLevel: atRiskGoal.targetRisk,
          suggestedAction:
              'Shift time toward this goal before taking on lower-priority work.',
        ),
      );
    }

    if (burnoutReport.severity == DeadlineRiskLevel.high ||
        burnoutReport.severity == DeadlineRiskLevel.critical) {
      insights.add(
        ProductivityInsight(
          title: 'Sustained overload detected',
          description: burnoutReport.reasons.join(' '),
          riskLevel: burnoutReport.severity,
          suggestedAction: burnoutReport.suggestedAction,
        ),
      );
    }

    if (dayReview.missedSessions > 0) {
      insights.add(
        ProductivityInsight(
          title: 'Day review: missed work needs recovery',
          description:
              'You missed ${dayReview.missedSessions} sessions today while completing ${dayReview.completedSessions}.',
          riskLevel: DeadlineRiskLevel.medium,
          suggestedAction: dayReview.recommendedNextAction,
        ),
      );
    }

    return insights;
  }

  AnalyticsDateRange resolveRange(AnalyticsRangePreset preset, DateTime now) {
    final today = _startOfDay(now);
    final tomorrow = today.add(const Duration(days: 1));
    switch (preset) {
      case AnalyticsRangePreset.last7Days:
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 6)),
          end: tomorrow,
          label: preset.label,
        );
      case AnalyticsRangePreset.last30Days:
        return AnalyticsDateRange(
          start: today.subtract(const Duration(days: 29)),
          end: tomorrow,
          label: preset.label,
        );
      case AnalyticsRangePreset.thisWeek:
        return AnalyticsDateRange(
          start: startOfWeek(now),
          end: tomorrow,
          label: preset.label,
        );
      case AnalyticsRangePreset.thisMonth:
        final monthStart = DateTime(now.year, now.month);
        return AnalyticsDateRange(
          start: monthStart,
          end: tomorrow,
          label: preset.label,
        );
    }
  }

  DateTime startOfWeek(DateTime value) {
    final day = _startOfDay(value);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  List<PlannedSession> filterSessionsForRange({
    required List<PlannedSession> sessions,
    required AnalyticsRangePreset preset,
    required DateTime now,
  }) {
    final range = resolveRange(preset, now);
    return _sessionsInRange(sessions, start: range.start, end: range.end);
  }

  int completedMinutesForSession(PlannedSession session) =>
      _completedMinutes(session);

  TimeAllocationBreakdown _buildBreakdown<T>({
    required String title,
    required Map<T, int> groups,
    required String Function(T item) labelBuilder,
    required String Function(T item) idBuilder,
  }) {
    final total = groups.values.fold<int>(0, (sum, value) => sum + value);
    final items = groups.entries.map((entry) {
      return TimeAllocationItem(
        id: idBuilder(entry.key),
        label: labelBuilder(entry.key),
        minutes: entry.value,
        percentage: total == 0 ? 0 : entry.value / total,
      );
    }).toList()..sort((left, right) => right.minutes.compareTo(left.minutes));

    return TimeAllocationBreakdown(
      title: title,
      totalMinutes: total,
      items: items,
    );
  }

  List<PlannedSession> _sessionsInRange(
    List<PlannedSession> sessions, {
    required DateTime start,
    required DateTime end,
  }) {
    return sessions.where((session) {
      return !session.start.isBefore(start) && session.start.isBefore(end);
    }).toList();
  }

  int _completedMinutes(PlannedSession session) {
    return session.actualMinutesFocused > 0
        ? session.actualMinutesFocused
        : session.plannedDurationMinutes;
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
