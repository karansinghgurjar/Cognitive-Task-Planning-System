class TaskRecommendation {
  const TaskRecommendation({
    required this.taskId,
    required this.title,
    required this.description,
    required this.reasoning,
    required this.riskLevel,
    required this.suggestedDurationMinutes,
    required this.suggestedActionText,
    this.relatedGoalId,
    this.relatedPlannedSessionId,
    this.confidence = 0,
    this.estimatedRequiredMinutes,
    this.estimatedAvailableMinutes,
  });

  final String taskId;
  final String title;
  final String description;
  final String reasoning;
  final DeadlineRiskLevel riskLevel;
  final int suggestedDurationMinutes;
  final String suggestedActionText;
  final String? relatedGoalId;
  final String? relatedPlannedSessionId;
  final double confidence;
  final int? estimatedRequiredMinutes;
  final int? estimatedAvailableMinutes;
}

class RecommendedStudyBlock {
  const RecommendedStudyBlock({
    required this.start,
    required this.end,
    required this.title,
    required this.description,
    this.relatedTaskId,
  });

  final DateTime start;
  final DateTime end;
  final String title;
  final String description;
  final String? relatedTaskId;

  int get durationMinutes => end.difference(start).inMinutes;
}

class GoalFeasibilityReport {
  const GoalFeasibilityReport({
    required this.goalId,
    required this.goalTitle,
    required this.targetDate,
    required this.remainingRequiredMinutes,
    required this.availableMinutesUntilTarget,
    required this.shortfallMinutes,
    required this.riskLevel,
    required this.isFeasible,
    required this.isTimeBound,
    required this.summary,
    required this.suggestedActionText,
  });

  final String goalId;
  final String goalTitle;
  final DateTime? targetDate;
  final int remainingRequiredMinutes;
  final int availableMinutesUntilTarget;
  final int shortfallMinutes;
  final DeadlineRiskLevel riskLevel;
  final bool isFeasible;
  final bool isTimeBound;
  final String summary;
  final String suggestedActionText;
}

class WorkloadWarning {
  const WorkloadWarning({
    required this.title,
    required this.description,
    required this.riskLevel,
    required this.suggestedActionText,
    this.relatedTaskId,
    this.relatedGoalId,
    this.estimatedRequiredMinutes,
    this.estimatedAvailableMinutes,
  });

  final String title;
  final String description;
  final DeadlineRiskLevel riskLevel;
  final String suggestedActionText;
  final String? relatedTaskId;
  final String? relatedGoalId;
  final int? estimatedRequiredMinutes;
  final int? estimatedAvailableMinutes;
}

class RecommendationSummary {
  const RecommendationSummary({
    required this.bestNextTask,
    required this.nextStudyBlock,
    required this.workloadWarnings,
    required this.goalFeasibilityReports,
    required this.suggestedActions,
  });

  final TaskRecommendation? bestNextTask;
  final RecommendedStudyBlock? nextStudyBlock;
  final List<WorkloadWarning> workloadWarnings;
  final List<GoalFeasibilityReport> goalFeasibilityReports;
  final List<String> suggestedActions;

  bool get hasCriticalRisk {
    return workloadWarnings.any((warning) => warning.riskLevel.isCritical) ||
        goalFeasibilityReports.any((report) => report.riskLevel.isCritical) ||
        (bestNextTask?.riskLevel.isCritical ?? false);
  }
}

enum DeadlineRiskLevel { low, medium, high, critical }

extension DeadlineRiskLevelX on DeadlineRiskLevel {
  bool get isCritical => this == DeadlineRiskLevel.critical;

  String get label {
    switch (this) {
      case DeadlineRiskLevel.low:
        return 'Low';
      case DeadlineRiskLevel.medium:
        return 'Medium';
      case DeadlineRiskLevel.high:
        return 'High';
      case DeadlineRiskLevel.critical:
        return 'Critical';
    }
  }
}
