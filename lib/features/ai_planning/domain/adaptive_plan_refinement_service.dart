import 'ai_planning_models.dart';
import 'planning_context.dart';

class AdaptivePlanRefinementService {
  const AdaptivePlanRefinementService();

  AiPlanResult refineUsingHistory(
    AiPlanResult plan,
    AnalyticsSnapshot snapshot,
    PlanningContext context,
  ) {
    final adjustedTasks = <TaskDraft>[];
    final updatedWarnings = List<AiPlanningWarning>.from(plan.warnings);

    for (final task in plan.tasks) {
      var updated = task;
      final speedFactor = snapshot.taskTypeSpeedFactors[task.type] ?? 1.0;
      if (speedFactor >= 1.15) {
        updated = updated.copyWith(
          estimatedMinutes: ((task.estimatedMinutes * speedFactor).round())
              .clamp(25, 8 * 60),
          reasoning:
              '${task.reasoning ?? 'Estimated task.'} Adjusted upward to reflect recent slower completion speed.',
        );
      }
      if (snapshot.longSessionMissRate >= 0.4 &&
          updated.estimatedMinutes > 75) {
        updated = updated.copyWith(
          estimatedMinutes: 60,
          reasoning:
              '${updated.reasoning ?? 'Estimated task.'} Reduced to fit shorter sessions because long sessions are often missed.',
        );
      }
      adjustedTasks.add(updated);
    }

    if (snapshot.recentMissedSessions >= 3) {
      updatedWarnings.add(
        const AiPlanningWarning(
          message: 'Recent misses suggest using shorter, more frequent tasks.',
          severity: AiWarningSeverity.caution,
          reasoning:
              'The plan was refined to avoid oversized sessions where possible.',
        ),
      );
    }

    final adjustedDurations = adjustedTasks
        .map(
          (task) => DurationEstimate(
            taskDraftId: task.id,
            taskTitle: task.title,
            estimatedMinutes: task.estimatedMinutes,
            confidence: 0.72,
            reasoning:
                task.reasoning ??
                'Refined from historical completion behavior.',
          ),
        )
        .toList();

    final updatedSummary =
        '${plan.explanationSummary} Refined using recent completion speed and miss patterns.';
    final updatedWeeklyMinutes = plan.suggestedWeeklyMinutes > 0
        ? plan.suggestedWeeklyMinutes +
              (snapshot.recentMissedSessions >= 3 ? 30 : 0)
        : plan.suggestedWeeklyMinutes;

    return plan.copyWith(
      tasks: adjustedTasks,
      durationEstimates: adjustedDurations,
      warnings: updatedWarnings,
      explanationSummary: updatedSummary,
      suggestedWeeklyMinutes: updatedWeeklyMinutes,
      suggestedCadence:
          '${plan.suggestedCadence} Adjusted for recent completion behavior.',
    );
  }
}
