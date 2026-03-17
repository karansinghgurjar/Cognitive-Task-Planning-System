import '../domain/ai_planning_models.dart';
import '../domain/adaptive_plan_refinement_service.dart';
import '../domain/planning_context.dart';
import '../domain/rule_based_goal_breakdown_service.dart';
import '../../recommendations/domain/recommendation_models.dart';
import 'ai_planner_adapter.dart';

class RuleBasedPlannerAdapter extends AiPlannerAdapter {
  const RuleBasedPlannerAdapter({
    this.breakdownService = const RuleBasedGoalBreakdownService(),
    this.refinementService = const AdaptivePlanRefinementService(),
  });

  final RuleBasedGoalBreakdownService breakdownService;
  final AdaptivePlanRefinementService refinementService;

  @override
  String get adapterLabel => 'Rule-based planner';

  @override
  Future<AiPlanResult> generatePlan(
    NaturalLanguagePlanRequest request,
    PlanningContext context, {
    AnalyticsSnapshot? analyticsSnapshot,
  }) async {
    final base = breakdownService.generatePlan(request, context);
    if (analyticsSnapshot == null) {
      return base;
    }
    return refinementService.refineUsingHistory(
      base,
      analyticsSnapshot,
      context,
    );
  }

  @override
  Future<List<DurationEstimate>> estimateDurations(
    List<TaskDraft> tasks,
    PlanningContext context,
  ) async {
    return breakdownService.durationEstimationService.estimateTasks(
      tasks,
      context,
    );
  }

  @override
  Future<AiPlanPreview> previewPlan({
    required NaturalLanguagePlanRequest request,
    required PlanningContext context,
    AnalyticsSnapshot? analyticsSnapshot,
  }) async {
    final result = await generatePlan(
      request,
      context,
      analyticsSnapshot: analyticsSnapshot,
    );
    final availableWeeklyMinutes = context.availableWeeklyMinutes;
    final requiredWeeklyMinutes = result.suggestedWeeklyMinutes;
    final riskLevel =
        requiredWeeklyMinutes > availableWeeklyMinutes &&
            availableWeeklyMinutes > 0
        ? (requiredWeeklyMinutes > availableWeeklyMinutes * 1.5
              ? DeadlineRiskLevel.high
              : DeadlineRiskLevel.medium)
        : DeadlineRiskLevel.low;

    return AiPlanPreview(
      result: result,
      totalEstimatedMinutes: result.totalEstimatedMinutes,
      recommendedWeeklyMinutes: requiredWeeklyMinutes,
      availableWeeklyMinutes: availableWeeklyMinutes,
      riskLevel: riskLevel,
      summary:
          'Plan totals ${(result.totalEstimatedMinutes / 60).toStringAsFixed(1)} hours. Recommended pace is ${(requiredWeeklyMinutes / 60).toStringAsFixed(1)} hours per week.',
    );
  }

  @override
  Future<AiPlanResult> refinePlan(
    AiPlanResult existingPlan,
    PlanningContext context,
    AnalyticsSnapshot analyticsSnapshot,
  ) async {
    return refinementService.refineUsingHistory(
      existingPlan,
      analyticsSnapshot,
      context,
    );
  }
}
