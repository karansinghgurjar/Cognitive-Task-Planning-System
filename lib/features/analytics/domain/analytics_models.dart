import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../tasks/models/task.dart';

class AnalyticsDateRange {
  const AnalyticsDateRange({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;

  int get dayCount => end.difference(start).inDays;
}

enum AnalyticsRangePreset { last7Days, last30Days, thisWeek, thisMonth }

extension AnalyticsRangePresetX on AnalyticsRangePreset {
  String get label {
    switch (this) {
      case AnalyticsRangePreset.last7Days:
        return 'Last 7 Days';
      case AnalyticsRangePreset.last30Days:
        return 'Last 30 Days';
      case AnalyticsRangePreset.thisWeek:
        return 'This Week';
      case AnalyticsRangePreset.thisMonth:
        return 'This Month';
    }
  }
}

class DailyProductivityStats {
  const DailyProductivityStats({
    required this.date,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completionRate,
    required this.completedSessions,
    required this.missedSessions,
    required this.cancelledSessions,
    this.topTaskTitle,
    this.topGoalTitle,
  });

  final DateTime date;
  final int plannedMinutes;
  final int completedMinutes;
  final double completionRate;
  final int completedSessions;
  final int missedSessions;
  final int cancelledSessions;
  final String? topTaskTitle;
  final String? topGoalTitle;
}

class RangeProductivityStats {
  const RangeProductivityStats({
    required this.range,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completionRate,
    required this.completedSessions,
    required this.missedSessions,
    required this.cancelledSessions,
  });

  final AnalyticsDateRange range;
  final int plannedMinutes;
  final int completedMinutes;
  final double completionRate;
  final int completedSessions;
  final int missedSessions;
  final int cancelledSessions;
}

class WeeklyProductivityStats {
  const WeeklyProductivityStats({
    required this.weekStart,
    required this.weekEnd,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completionRate,
    required this.completedSessions,
    required this.missedSessions,
    required this.cancelledSessions,
    required this.averageCompletedMinutesPerDay,
    required this.busiestDay,
    required this.mostProductiveDay,
    required this.leastProductiveDay,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int plannedMinutes;
  final int completedMinutes;
  final double completionRate;
  final int completedSessions;
  final int missedSessions;
  final int cancelledSessions;
  final double averageCompletedMinutesPerDay;
  final DateTime? busiestDay;
  final DateTime? mostProductiveDay;
  final DateTime? leastProductiveDay;
}

class GoalAnalytics {
  const GoalAnalytics({
    required this.goalId,
    required this.goalTitle,
    required this.goalType,
    required this.totalLinkedTasks,
    required this.completedLinkedTasks,
    required this.totalPlannedMinutes,
    required this.totalCompletedMinutes,
    required this.percentComplete,
    required this.targetRisk,
    required this.averageMinutesPerWeekSpent,
  });

  final String goalId;
  final String goalTitle;
  final GoalType goalType;
  final int totalLinkedTasks;
  final int completedLinkedTasks;
  final int totalPlannedMinutes;
  final int totalCompletedMinutes;
  final double percentComplete;
  final DeadlineRiskLevel targetRisk;
  final double averageMinutesPerWeekSpent;
}

class TaskAnalytics {
  const TaskAnalytics({
    required this.taskId,
    required this.taskTitle,
    required this.taskType,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completedSessions,
    required this.percentComplete,
    this.goalId,
  });

  final String taskId;
  final String taskTitle;
  final TaskType taskType;
  final String? goalId;
  final int plannedMinutes;
  final int completedMinutes;
  final int completedSessions;
  final double percentComplete;
}

class FocusTrendPoint {
  const FocusTrendPoint({
    required this.date,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completedSessions,
    required this.missedSessions,
  });

  final DateTime date;
  final int plannedMinutes;
  final int completedMinutes;
  final int completedSessions;
  final int missedSessions;
}

class StreakInfo {
  const StreakInfo({
    required this.length,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  final int length;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
}

class StreakSummary {
  const StreakSummary({
    required this.currentFocusStreak,
    required this.longestFocusStreak,
    required this.currentDailyCompletionStreak,
  });

  final StreakInfo currentFocusStreak;
  final StreakInfo longestFocusStreak;
  final StreakInfo currentDailyCompletionStreak;
}

class BurnoutRiskReport {
  const BurnoutRiskReport({
    required this.severity,
    required this.reasons,
    required this.suggestedAction,
    required this.recentMissedSessions,
    required this.recentCancelledSessions,
    required this.hasRestDay,
    required this.weekOverWeekPlannedIncreaseMinutes,
  });

  final DeadlineRiskLevel severity;
  final List<String> reasons;
  final String suggestedAction;
  final int recentMissedSessions;
  final int recentCancelledSessions;
  final bool hasRestDay;
  final int weekOverWeekPlannedIncreaseMinutes;
}

class TimeAllocationItem {
  const TimeAllocationItem({
    required this.id,
    required this.label,
    required this.minutes,
    required this.percentage,
  });

  final String id;
  final String label;
  final int minutes;
  final double percentage;
}

class TimeAllocationBreakdown {
  const TimeAllocationBreakdown({
    required this.title,
    required this.totalMinutes,
    required this.items,
  });

  final String title;
  final int totalMinutes;
  final List<TimeAllocationItem> items;
}

class ProductivityInsight {
  const ProductivityInsight({
    required this.title,
    required this.description,
    required this.riskLevel,
    required this.suggestedAction,
  });

  final String title;
  final String description;
  final DeadlineRiskLevel riskLevel;
  final String suggestedAction;
}

class DayReviewSummary {
  const DayReviewSummary({
    required this.date,
    required this.completedSessions,
    required this.missedSessions,
    required this.totalFocusedMinutes,
    required this.recommendedNextAction,
    this.mostImportantCompletedTaskTitle,
  });

  final DateTime date;
  final int completedSessions;
  final int missedSessions;
  final int totalFocusedMinutes;
  final String? mostImportantCompletedTaskTitle;
  final String recommendedNextAction;
}
