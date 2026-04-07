import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../tasks/models/task.dart';

class WeeklyCompletionBreakdown {
  const WeeklyCompletionBreakdown({
    required this.totalPlannedMinutes,
    required this.totalCompletedMinutes,
    required this.completionRate,
    required this.completedSessionsCount,
    required this.missedSessionsCount,
    required this.cancelledSessionsCount,
  });

  final int totalPlannedMinutes;
  final int totalCompletedMinutes;
  final double completionRate;
  final int completedSessionsCount;
  final int missedSessionsCount;
  final int cancelledSessionsCount;
}

class WeeklyGoalReview {
  const WeeklyGoalReview({
    required this.goalId,
    required this.goalTitle,
    required this.goalType,
    required this.minutesSpent,
    required this.completedLinkedTasksThisWeek,
    required this.totalLinkedTasks,
    required this.targetRisk,
    required this.statusSummary,
  });

  final String goalId;
  final String goalTitle;
  final GoalType goalType;
  final int minutesSpent;
  final int completedLinkedTasksThisWeek;
  final int totalLinkedTasks;
  final DeadlineRiskLevel targetRisk;
  final String statusSummary;
}

class WeeklyTaskReview {
  const WeeklyTaskReview({
    required this.taskId,
    required this.taskTitle,
    required this.taskType,
    required this.plannedMinutes,
    required this.completedMinutes,
    required this.completedSessionsCount,
    required this.missedSessionsCount,
    required this.cancelledSessionsCount,
    required this.slipCount,
    required this.wasCompletedThisWeek,
    required this.isOverdue,
    required this.isArchived,
    required this.statusSummary,
  });

  final String taskId;
  final String taskTitle;
  final TaskType taskType;
  final int plannedMinutes;
  final int completedMinutes;
  final int completedSessionsCount;
  final int missedSessionsCount;
  final int cancelledSessionsCount;
  final int slipCount;
  final bool wasCompletedThisWeek;
  final bool isOverdue;
  final bool isArchived;
  final String statusSummary;
}

class WeeklyRecommendation {
  const WeeklyRecommendation({
    required this.title,
    required this.description,
    required this.suggestedAction,
    required this.riskLevel,
  });

  final String title;
  final String description;
  final String suggestedAction;
  final DeadlineRiskLevel riskLevel;
}

class WeeklyTrendComparison {
  const WeeklyTrendComparison({
    required this.completedMinutesDelta,
    required this.completionRateDelta,
    required this.missedSessionsDelta,
    required this.summary,
  });

  final int completedMinutesDelta;
  final double completionRateDelta;
  final int missedSessionsDelta;
  final String summary;
}

class WeeklyReviewSnapshot {
  const WeeklyReviewSnapshot({
    required this.weekStart,
    required this.weekEnd,
    required this.breakdown,
    required this.goalReviews,
    required this.taskReviews,
    required this.recommendations,
    required this.overdueTaskTitles,
    required this.repeatedSlipTaskTitles,
    required this.summaryText,
    this.topGoalTitle,
    this.topGoalMinutes = 0,
    this.topTaskTitle,
    this.topTaskMinutes = 0,
    this.trendComparison,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final WeeklyCompletionBreakdown breakdown;
  final List<WeeklyGoalReview> goalReviews;
  final List<WeeklyTaskReview> taskReviews;
  final List<WeeklyRecommendation> recommendations;
  final List<String> overdueTaskTitles;
  final List<String> repeatedSlipTaskTitles;
  final String summaryText;
  final String? topGoalTitle;
  final int topGoalMinutes;
  final String? topTaskTitle;
  final int topTaskMinutes;
  final WeeklyTrendComparison? trendComparison;

  bool get hasMeaningfulData {
    return breakdown.totalPlannedMinutes > 0 ||
        breakdown.totalCompletedMinutes > 0 ||
        breakdown.completedSessionsCount > 0 ||
        breakdown.missedSessionsCount > 0 ||
        breakdown.cancelledSessionsCount > 0;
  }
}
