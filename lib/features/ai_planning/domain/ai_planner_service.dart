import 'ai_planning_models.dart';
import 'planning_context.dart';

abstract class AiPlannerService {
  Future<AiPlanResult> generatePlan(
    NaturalLanguagePlanRequest request,
    PlanningContext context, {
    AnalyticsSnapshot? analyticsSnapshot,
  });

  Future<List<DurationEstimate>> estimateDurations(
    List<TaskDraft> tasks,
    PlanningContext context,
  );

  Future<AiPlanPreview> previewPlan({
    required NaturalLanguagePlanRequest request,
    required PlanningContext context,
    AnalyticsSnapshot? analyticsSnapshot,
  });

  Future<AiPlanResult> refinePlan(
    AiPlanResult existingPlan,
    PlanningContext context,
    AnalyticsSnapshot analyticsSnapshot,
  );
}
