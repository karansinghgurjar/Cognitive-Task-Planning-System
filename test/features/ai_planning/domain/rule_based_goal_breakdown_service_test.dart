import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/ai_planning/domain/ai_planning_models.dart';
import 'package:study_flow/features/ai_planning/domain/planning_context.dart';
import 'package:study_flow/features/ai_planning/domain/rule_based_goal_breakdown_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';

void main() {
  group('RuleBasedGoalBreakdownService', () {
    const service = RuleBasedGoalBreakdownService();
    const context = PlanningContext(
      availableWeeklyMinutes: 600,
      currentActiveGoalsCount: 1,
      recentAverageCompletedMinutesPerWeek: 300,
      preferredSessionLengthMinutes: 60,
      existingTasks: [],
      existingGoals: [],
      promptKeywords: ['flutter'],
      isRevisionHint: false,
      isFromScratchHint: true,
      isAdvancedHint: false,
    );

    test(
      'builds flutter roadmap with explainable milestones and dependencies',
      () {
        final result = service.generatePlan(
          const NaturalLanguagePlanRequest(
            prompt: 'Learn Flutter for app development from scratch',
            priority: 2,
          ),
          context,
          now: DateTime(2026, 3, 16),
        );

        expect(result.goal.goalType, GoalType.learning);
        expect(
          result.milestones.map((item) => item.title),
          containsAll([
            'Dart basics',
            'Flutter widgets and layout',
            'State management',
            'Navigation and local storage',
            'Mini project',
          ]),
        );
        expect(result.tasks, isNotEmpty);
        expect(
          result.dependencies.any(
            (dependency) => dependency.reason.contains(
              'Widgets are easier after Dart basics',
            ),
          ),
          isTrue,
        );
        expect(result.explanationSummary, contains('Generated'));
      },
    );
  });
}
