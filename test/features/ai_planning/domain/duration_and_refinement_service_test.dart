import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/ai_planning/domain/adaptive_plan_refinement_service.dart';
import 'package:study_flow/features/ai_planning/domain/ai_planning_models.dart';
import 'package:study_flow/features/ai_planning/domain/duration_estimation_service.dart';
import 'package:study_flow/features/ai_planning/domain/planning_context.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('DurationEstimationService', () {
    const service = DurationEstimationService();
    const context = PlanningContext(
      availableWeeklyMinutes: 480,
      currentActiveGoalsCount: 2,
      recentAverageCompletedMinutesPerWeek: 260,
      preferredSessionLengthMinutes: 60,
      existingTasks: [],
      existingGoals: [],
      promptKeywords: ['java', 'dsa'],
      isRevisionHint: true,
      isFromScratchHint: false,
      isAdvancedHint: false,
      taskTypeSpeedFactors: {TaskType.coding: 1.2},
      longSessionMissRate: 0.4,
    );

    test('adjusts estimates for revision and historical pace', () {
      const task = TaskDraft(
        id: 'task-1',
        title: 'Practice arrays and strings questions',
        type: TaskType.coding,
        estimatedMinutes: 90,
      );
      const parsed = ParsedGoalPrompt(
        originalPrompt: 'Prepare Java + DSA revision',
        normalizedPrompt: 'prepare java + dsa revision',
        titleCandidate: 'Java and DSA Preparation',
        inferredGoalType: GoalType.examPrep,
        keywords: ['java', 'dsa'],
        topicTokens: ['java', 'dsa'],
        isRevision: true,
        isFromScratch: false,
        isAdvanced: false,
        isExam: false,
        isInterview: true,
        isProject: false,
        isUrgent: false,
      );

      final estimate = service.estimateTask(
        task,
        context,
        parsedPrompt: parsed,
      );

      expect(estimate.estimatedMinutes, greaterThanOrEqualTo(75));
      expect(estimate.reasoning, contains('revision scope'));
      expect(estimate.reasoning, contains('historical pace'));
    });
  });

  group('AdaptivePlanRefinementService', () {
    const service = AdaptivePlanRefinementService();

    test('shrinks long tasks when misses are frequent', () {
      const plan = AiPlanResult(
        request: NaturalLanguagePlanRequest(prompt: 'Learn Flutter'),
        parsedPrompt: ParsedGoalPrompt(
          originalPrompt: 'Learn Flutter',
          normalizedPrompt: 'learn flutter',
          titleCandidate: 'Learn Flutter',
          inferredGoalType: GoalType.learning,
          keywords: ['flutter'],
          topicTokens: ['flutter'],
          isRevision: false,
          isFromScratch: true,
          isAdvanced: false,
          isExam: false,
          isInterview: false,
          isProject: false,
          isUrgent: false,
        ),
        goal: GoalDraft(
          title: 'Learn Flutter',
          goalType: GoalType.learning,
          priority: 2,
        ),
        milestones: [],
        tasks: [
          TaskDraft(
            id: 'task-1',
            title: 'Build and test the mini project',
            type: TaskType.coding,
            estimatedMinutes: 120,
          ),
        ],
        dependencies: [],
        durationEstimates: [],
        suggestions: [],
        warnings: [],
        explanationSummary: 'Base plan',
        suggestedWeeklyMinutes: 180,
        suggestedCadence: '3 sessions per week.',
      );
      const snapshot = AnalyticsSnapshot(
        averageCompletedMinutesPerWeek: 200,
        averageCompletedMinutesPerSession: 42,
        longSessionMissRate: 0.5,
        taskTypeSpeedFactors: {TaskType.coding: 1.25},
        recentMissedSessions: 4,
      );
      const context = PlanningContext(
        availableWeeklyMinutes: 480,
        currentActiveGoalsCount: 1,
        recentAverageCompletedMinutesPerWeek: 200,
        preferredSessionLengthMinutes: 60,
        existingTasks: [],
        existingGoals: [],
        promptKeywords: ['flutter'],
        isRevisionHint: false,
        isFromScratchHint: true,
        isAdvancedHint: false,
      );

      final refined = service.refineUsingHistory(plan, snapshot, context);

      expect(refined.tasks.single.estimatedMinutes, 60);
      expect(refined.warnings, isNotEmpty);
      expect(
        refined.explanationSummary,
        contains('Refined using recent completion speed'),
      );
    });
  });
}
