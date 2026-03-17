import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/ai_planning/domain/ai_planning_models.dart';
import 'package:study_flow/features/ai_planning/domain/dependency_suggestion_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('DependencySuggestionService', () {
    const service = DependencySuggestionService();

    test('adds flutter learning dependencies in the expected direction', () {
      const parsed = ParsedGoalPrompt(
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
      );
      const tasks = [
        TaskDraft(
          id: '1',
          title: 'Set up Dart syntax and types practice',
          type: TaskType.coding,
          estimatedMinutes: 60,
        ),
        TaskDraft(
          id: '2',
          title: 'Build layout practice screens',
          type: TaskType.coding,
          estimatedMinutes: 60,
        ),
        TaskDraft(
          id: '3',
          title: 'Learn Riverpod state flows',
          type: TaskType.coding,
          estimatedMinutes: 60,
        ),
      ];

      final dependencies = service.suggestDependencies(tasks, parsed);

      expect(
        dependencies.any(
          (item) => item.taskDraftId == '3' && item.dependsOnTaskDraftId == '2',
        ),
        isTrue,
      );
    });
  });
}
