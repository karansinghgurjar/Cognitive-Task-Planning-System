import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../tasks/models/task.dart';

enum PlanningIntensity { conservative, balanced, aggressive }

enum AiWarningSeverity { info, caution, high }

class NaturalLanguagePlanRequest {
  const NaturalLanguagePlanRequest({
    required this.prompt,
    this.targetDate,
    this.priority = 3,
    this.intensity = PlanningIntensity.balanced,
    this.existingGoalId,
  });

  final String prompt;
  final DateTime? targetDate;
  final int priority;
  final PlanningIntensity intensity;
  final String? existingGoalId;
}

class ParsedGoalPrompt {
  const ParsedGoalPrompt({
    required this.originalPrompt,
    required this.normalizedPrompt,
    required this.titleCandidate,
    required this.inferredGoalType,
    required this.keywords,
    required this.topicTokens,
    required this.isRevision,
    required this.isFromScratch,
    required this.isAdvanced,
    required this.isExam,
    required this.isInterview,
    required this.isProject,
    required this.isUrgent,
    this.deadlineHint,
    this.timeframeDaysHint,
    this.summary,
  });

  final String originalPrompt;
  final String normalizedPrompt;
  final String titleCandidate;
  final GoalType inferredGoalType;
  final List<String> keywords;
  final List<String> topicTokens;
  final bool isRevision;
  final bool isFromScratch;
  final bool isAdvanced;
  final bool isExam;
  final bool isInterview;
  final bool isProject;
  final bool isUrgent;
  final DateTime? deadlineHint;
  final int? timeframeDaysHint;
  final String? summary;
}

class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.goalType,
    required this.priority,
    this.description,
    this.targetDate,
    this.estimatedTotalMinutes,
    this.reasoning,
  });

  final String title;
  final String? description;
  final GoalType goalType;
  final DateTime? targetDate;
  final int priority;
  final int? estimatedTotalMinutes;
  final String? reasoning;

  GoalDraft copyWith({
    String? title,
    String? description,
    GoalType? goalType,
    DateTime? targetDate,
    bool clearTargetDate = false,
    int? priority,
    int? estimatedTotalMinutes,
    bool clearEstimatedTotalMinutes = false,
    String? reasoning,
  }) {
    return GoalDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      targetDate: clearTargetDate ? null : targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      estimatedTotalMinutes: clearEstimatedTotalMinutes
          ? null
          : estimatedTotalMinutes ?? this.estimatedTotalMinutes,
      reasoning: reasoning ?? this.reasoning,
    );
  }
}

class MilestoneDraft {
  const MilestoneDraft({
    required this.id,
    required this.title,
    required this.sequenceOrder,
    required this.estimatedMinutes,
    this.description,
    this.reasoning,
  });

  final String id;
  final String title;
  final String? description;
  final int sequenceOrder;
  final int estimatedMinutes;
  final String? reasoning;

  MilestoneDraft copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    int? sequenceOrder,
    int? estimatedMinutes,
    String? reasoning,
  }) {
    return MilestoneDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      reasoning: reasoning ?? this.reasoning,
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.id,
    required this.title,
    required this.type,
    required this.estimatedMinutes,
    this.description,
    this.milestoneDraftId,
    this.dueDate,
    this.reasoning,
    this.heuristicCategory,
  });

  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final int estimatedMinutes;
  final String? milestoneDraftId;
  final DateTime? dueDate;
  final String? reasoning;
  final String? heuristicCategory;

  TaskDraft copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    TaskType? type,
    int? estimatedMinutes,
    String? milestoneDraftId,
    bool clearMilestoneDraftId = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? reasoning,
    String? heuristicCategory,
  }) {
    return TaskDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      type: type ?? this.type,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      milestoneDraftId: clearMilestoneDraftId
          ? null
          : milestoneDraftId ?? this.milestoneDraftId,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      reasoning: reasoning ?? this.reasoning,
      heuristicCategory: heuristicCategory ?? this.heuristicCategory,
    );
  }
}

class DependencyDraft {
  const DependencyDraft({
    required this.taskDraftId,
    required this.dependsOnTaskDraftId,
    required this.reason,
  });

  final String taskDraftId;
  final String dependsOnTaskDraftId;
  final String reason;
}

class DurationEstimate {
  const DurationEstimate({
    required this.taskDraftId,
    required this.taskTitle,
    required this.estimatedMinutes,
    required this.confidence,
    required this.reasoning,
  });

  final String taskDraftId;
  final String taskTitle;
  final int estimatedMinutes;
  final double confidence;
  final String reasoning;
}

class PlanningSuggestion {
  const PlanningSuggestion({
    required this.title,
    required this.description,
    required this.suggestedActionText,
    this.reasoning,
    this.riskLevel,
  });

  final String title;
  final String description;
  final String suggestedActionText;
  final String? reasoning;
  final DeadlineRiskLevel? riskLevel;
}

class AiPlanningWarning {
  const AiPlanningWarning({
    required this.message,
    required this.severity,
    this.reasoning,
  });

  final String message;
  final AiWarningSeverity severity;
  final String? reasoning;
}

class AiPlanResult {
  const AiPlanResult({
    required this.request,
    required this.parsedPrompt,
    required this.goal,
    required this.milestones,
    required this.tasks,
    required this.dependencies,
    required this.durationEstimates,
    required this.suggestions,
    required this.warnings,
    required this.explanationSummary,
    required this.suggestedWeeklyMinutes,
    required this.suggestedCadence,
  });

  final NaturalLanguagePlanRequest request;
  final ParsedGoalPrompt parsedPrompt;
  final GoalDraft goal;
  final List<MilestoneDraft> milestones;
  final List<TaskDraft> tasks;
  final List<DependencyDraft> dependencies;
  final List<DurationEstimate> durationEstimates;
  final List<PlanningSuggestion> suggestions;
  final List<AiPlanningWarning> warnings;
  final String explanationSummary;
  final int suggestedWeeklyMinutes;
  final String suggestedCadence;

  int get totalEstimatedMinutes =>
      tasks.fold<int>(0, (sum, task) => sum + task.estimatedMinutes);

  AiPlanResult copyWith({
    GoalDraft? goal,
    List<MilestoneDraft>? milestones,
    List<TaskDraft>? tasks,
    List<DependencyDraft>? dependencies,
    List<DurationEstimate>? durationEstimates,
    List<PlanningSuggestion>? suggestions,
    List<AiPlanningWarning>? warnings,
    String? explanationSummary,
    int? suggestedWeeklyMinutes,
    String? suggestedCadence,
  }) {
    return AiPlanResult(
      request: request,
      parsedPrompt: parsedPrompt,
      goal: goal ?? this.goal,
      milestones: milestones ?? this.milestones,
      tasks: tasks ?? this.tasks,
      dependencies: dependencies ?? this.dependencies,
      durationEstimates: durationEstimates ?? this.durationEstimates,
      suggestions: suggestions ?? this.suggestions,
      warnings: warnings ?? this.warnings,
      explanationSummary: explanationSummary ?? this.explanationSummary,
      suggestedWeeklyMinutes:
          suggestedWeeklyMinutes ?? this.suggestedWeeklyMinutes,
      suggestedCadence: suggestedCadence ?? this.suggestedCadence,
    );
  }
}

class AiPlanPreview {
  const AiPlanPreview({
    required this.result,
    required this.totalEstimatedMinutes,
    required this.recommendedWeeklyMinutes,
    required this.availableWeeklyMinutes,
    required this.riskLevel,
    required this.summary,
  });

  final AiPlanResult result;
  final int totalEstimatedMinutes;
  final int recommendedWeeklyMinutes;
  final int availableWeeklyMinutes;
  final DeadlineRiskLevel riskLevel;
  final String summary;
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.averageCompletedMinutesPerWeek,
    required this.averageCompletedMinutesPerSession,
    required this.longSessionMissRate,
    required this.taskTypeSpeedFactors,
    required this.recentMissedSessions,
  });

  final double averageCompletedMinutesPerWeek;
  final double averageCompletedMinutesPerSession;
  final double longSessionMissRate;
  final Map<TaskType, double> taskTypeSpeedFactors;
  final int recentMissedSessions;
}

class ImportOptions {
  const ImportOptions({
    this.existingGoalId,
    this.skipExistingMilestones = true,
    this.skipExistingTasks = true,
    this.createDependencies = true,
  });

  final String? existingGoalId;
  final bool skipExistingMilestones;
  final bool skipExistingTasks;
  final bool createDependencies;
}
