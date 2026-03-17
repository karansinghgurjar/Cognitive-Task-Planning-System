import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../goals/data/goal_repository.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/task_dependency.dart';
import '../../goals/providers/goal_providers.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../recommendations/providers/recommendation_providers.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/models/task.dart';
import '../data/rule_based_planner_adapter.dart';
import '../domain/adaptive_plan_refinement_service.dart';
import '../domain/ai_plan_import_service.dart';
import '../domain/ai_planning_models.dart';
import '../domain/dependency_suggestion_service.dart';
import '../domain/duration_estimation_service.dart';
import '../domain/goal_prompt_parser_service.dart';
import '../domain/planning_context.dart';
import '../domain/rule_based_goal_breakdown_service.dart';

final goalPromptParserServiceProvider = Provider<GoalPromptParserService>((
  ref,
) {
  return const GoalPromptParserService();
});

final durationEstimationServiceProvider = Provider<DurationEstimationService>((
  ref,
) {
  return const DurationEstimationService();
});

final dependencySuggestionServiceProvider =
    Provider<DependencySuggestionService>((ref) {
      return const DependencySuggestionService();
    });

final adaptivePlanRefinementServiceProvider =
    Provider<AdaptivePlanRefinementService>((ref) {
      return const AdaptivePlanRefinementService();
    });

final ruleBasedGoalBreakdownServiceProvider =
    Provider<RuleBasedGoalBreakdownService>((ref) {
      return RuleBasedGoalBreakdownService(
        parser: ref.read(goalPromptParserServiceProvider),
        durationEstimationService: ref.read(durationEstimationServiceProvider),
        dependencySuggestionService: ref.read(
          dependencySuggestionServiceProvider,
        ),
      );
    });

final aiPlannerServiceProvider = Provider<RuleBasedPlannerAdapter>((ref) {
  return RuleBasedPlannerAdapter(
    breakdownService: ref.read(ruleBasedGoalBreakdownServiceProvider),
    refinementService: ref.read(adaptivePlanRefinementServiceProvider),
  );
});

final aiPlanImportServiceProvider = FutureProvider<AiPlanImportService>((
  ref,
) async {
  final goalRepository = await ref.watch(goalRepositoryProvider.future);
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  return AiPlanImportService(
    goalRepository: _GoalImportStore(goalRepository),
    taskRepository: _TaskImportStore(taskRepository),
  );
});

final aiPlanningOpportunityProvider = Provider<AsyncValue<String?>>((ref) {
  final goalsAsync = ref.watch(watchGoalsProvider);
  final milestonesAsync = ref.watch(watchAllMilestonesProvider);
  final tasksAsync = ref.watch(watchTasksProvider);

  return switch ((goalsAsync, milestonesAsync, tasksAsync)) {
    (
      AsyncData(value: final goals),
      AsyncData(value: final milestones),
      AsyncData(value: final tasks),
    ) =>
      AsyncData(_buildPlanningOpportunity(goals, milestones, tasks)),
    (AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, AsyncError(:final error, :final stackTrace), _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

String? _buildPlanningOpportunity(
  List<LearningGoal> goals,
  List<dynamic> milestones,
  List<dynamic> tasks,
) {
  for (final goal in goals.where((item) => item.status == GoalStatus.active)) {
    final milestoneCount = milestones
        .where((item) => item.goalId == goal.id)
        .length;
    final taskCount = tasks.where((item) => item.goalId == goal.id).length;
    if (milestoneCount == 0 && taskCount == 0) {
      return '"${goal.title}" has no roadmap yet. Generate an AI plan to break it into milestones and tasks.';
    }
  }
  return null;
}

final aiPlanningControllerProvider =
    AsyncNotifierProvider<AiPlanningController, void>(AiPlanningController.new);

class AiPlanningController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<AiPlanPreview> generatePreview(
    NaturalLanguagePlanRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      final parser = ref.read(goalPromptParserServiceProvider);
      final parsed = parser.parse(request.prompt);
      final context = await _buildPlanningContext(parsed, request.intensity);
      final snapshot = await _buildAnalyticsSnapshot();
      final planner = ref.read(aiPlannerServiceProvider);
      final result = await planner.generatePlan(
        request,
        context,
        analyticsSnapshot: snapshot,
      );
      final preview = _buildPreview(result, context);
      state = const AsyncData(null);
      return preview;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> importPlan(AiPlanResult result, {String? existingGoalId}) async {
    state = const AsyncLoading();
    try {
      final importer = await ref.read(aiPlanImportServiceProvider.future);
      await importer.importApprovedPlan(
        result,
        ImportOptions(existingGoalId: existingGoalId),
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<PlanningContext> _buildPlanningContext(
    ParsedGoalPrompt parsed,
    PlanningIntensity intensity,
  ) async {
    final tasks = await ref.read(watchTasksProvider.future);
    final goals = await ref.read(watchGoalsProvider.future);
    final weeklyAvailability = ref.read(weeklyAvailabilityProvider).value ?? {};
    final weeklyStats = ref.read(weeklyStatsProvider).value;

    final availableWeeklyMinutes = weeklyAvailability.values
        .expand((windows) => windows)
        .fold<int>(
          0,
          (sum, window) =>
              sum + (window.endMinutesOfDay - window.startMinutesOfDay),
        );

    final taskTypeSpeedFactors = <dynamic, double>{};
    if (weeklyStats != null &&
        weeklyStats.plannedMinutes > 0 &&
        weeklyStats.completedMinutes > 0) {
      final ratio = weeklyStats.plannedMinutes / weeklyStats.completedMinutes;
      for (final type in tasks.map((task) => task.type).toSet()) {
        taskTypeSpeedFactors[type] = ratio.clamp(0.75, 1.4);
      }
    }

    return PlanningContext(
      availableWeeklyMinutes: availableWeeklyMinutes,
      currentActiveGoalsCount: goals
          .where((goal) => goal.status == GoalStatus.active)
          .length,
      recentAverageCompletedMinutesPerWeek: weeklyStats?.completedMinutes ?? 0,
      preferredSessionLengthMinutes: 60,
      existingTasks: tasks,
      existingGoals: goals,
      promptKeywords: parsed.keywords,
      isRevisionHint: parsed.isRevision,
      isFromScratchHint: parsed.isFromScratch,
      isAdvancedHint: parsed.isAdvanced,
      intensityPreference: switch (intensity) {
        PlanningIntensity.conservative =>
          PlanningIntensityPreference.conservative,
        PlanningIntensity.balanced => PlanningIntensityPreference.balanced,
        PlanningIntensity.aggressive => PlanningIntensityPreference.aggressive,
      },
      taskTypeSpeedFactors: taskTypeSpeedFactors.cast(),
      longSessionMissRate: _estimateLongSessionMissRate(weeklyStats),
      recentMissedSessions: weeklyStats?.missedSessions ?? 0,
    );
  }

  Future<AnalyticsSnapshot> _buildAnalyticsSnapshot() async {
    final weeklyStats = ref.read(weeklyStatsProvider).value;
    final selectedRangeStats = ref.read(selectedRangeStatsProvider).value;
    final tasks = await ref.read(watchTasksProvider.future);
    final factor = weeklyStats != null && weeklyStats.completedMinutes > 0
        ? (weeklyStats.plannedMinutes / weeklyStats.completedMinutes)
              .clamp(0.75, 1.4)
              .toDouble()
        : 1.0;
    final taskTypeSpeedFactors = {
      for (final type in tasks.map((task) => task.type).toSet()) type: factor,
    };

    return AnalyticsSnapshot(
      averageCompletedMinutesPerWeek: (weeklyStats?.completedMinutes ?? 0)
          .toDouble(),
      averageCompletedMinutesPerSession:
          selectedRangeStats == null ||
              selectedRangeStats.completedSessions == 0
          ? 60
          : selectedRangeStats.completedMinutes /
                selectedRangeStats.completedSessions,
      longSessionMissRate: _estimateLongSessionMissRate(weeklyStats),
      taskTypeSpeedFactors: taskTypeSpeedFactors,
      recentMissedSessions: weeklyStats?.missedSessions ?? 0,
    );
  }

  double _estimateLongSessionMissRate(dynamic weeklyStats) {
    if (weeklyStats == null) {
      return 0;
    }
    final total =
        weeklyStats.completedSessions +
        weeklyStats.missedSessions +
        weeklyStats.cancelledSessions;
    if (total == 0) {
      return 0;
    }
    return ((weeklyStats.missedSessions + weeklyStats.cancelledSessions) /
            total)
        .clamp(0, 1)
        .toDouble();
  }

  AiPlanPreview _buildPreview(AiPlanResult result, PlanningContext context) {
    final requiredWeeklyMinutes = result.suggestedWeeklyMinutes;
    final availableWeeklyMinutes = context.availableWeeklyMinutes;
    final riskLevel = _riskLevel(
      requiredWeeklyMinutes,
      availableWeeklyMinutes,
      result.goal.targetDate,
    );
    return AiPlanPreview(
      result: result,
      totalEstimatedMinutes: result.totalEstimatedMinutes,
      recommendedWeeklyMinutes: requiredWeeklyMinutes,
      availableWeeklyMinutes: availableWeeklyMinutes,
      riskLevel: riskLevel,
      summary:
          'Plan totals ${(result.totalEstimatedMinutes / 60).toStringAsFixed(1)} hours across ${result.milestones.length} milestones and ${result.tasks.length} tasks.',
    );
  }

  DeadlineRiskLevel _riskLevel(
    int requiredWeeklyMinutes,
    int availableWeeklyMinutes,
    DateTime? targetDate,
  ) {
    if (targetDate == null || availableWeeklyMinutes <= 0) {
      return DeadlineRiskLevel.low;
    }
    if (requiredWeeklyMinutes > availableWeeklyMinutes * 1.5) {
      return DeadlineRiskLevel.critical;
    }
    if (requiredWeeklyMinutes > availableWeeklyMinutes) {
      return DeadlineRiskLevel.high;
    }
    if (requiredWeeklyMinutes > (availableWeeklyMinutes * 0.75)) {
      return DeadlineRiskLevel.medium;
    }
    return DeadlineRiskLevel.low;
  }
}

class _GoalImportStore implements AiPlanGoalStore {
  const _GoalImportStore(this._repository);

  final GoalRepository _repository;

  @override
  Future<void> addDependency(TaskDependency dependency) {
    return _repository.addDependency(dependency);
  }

  @override
  Future<void> addGoal(LearningGoal goal) {
    return _repository.addGoal(goal);
  }

  @override
  Future<void> addMilestone(GoalMilestone milestone) {
    return _repository.addMilestone(milestone);
  }

  @override
  Future<List<TaskDependency>> getAllDependencies() {
    return _repository.getAllDependencies();
  }

  @override
  Future<LearningGoal?> getGoalById(String id) {
    return _repository.getGoalById(id);
  }

  @override
  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId) {
    return _repository.getMilestonesForGoal(goalId);
  }

  @override
  Future<void> updateGoal(LearningGoal goal) {
    return _repository.updateGoal(goal);
  }

  @override
  Future<void> updateMilestone(GoalMilestone milestone) {
    return _repository.updateMilestone(milestone);
  }
}

class _TaskImportStore implements AiPlanTaskStore {
  const _TaskImportStore(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> addTask(Task task) {
    return _repository.addTask(task);
  }

  @override
  Future<List<Task>> getAllTasks() {
    return _repository.getAllTasks();
  }

  @override
  Future<void> updateTask(Task task) {
    return _repository.updateTask(task);
  }
}
