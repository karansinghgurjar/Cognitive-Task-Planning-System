import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/ai_planning/domain/goal_prompt_parser_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';

void main() {
  group('GoalPromptParserService', () {
    const service = GoalPromptParserService();

    test('parses interview preparation prompt with timeframe hints', () {
      final parsed = service.parse(
        'Prepare Java + DSA for product-based interviews in 2 months',
        now: DateTime(2026, 3, 16),
      );

      expect(parsed.inferredGoalType, GoalType.examPrep);
      expect(parsed.keywords, containsAll(['java', 'dsa', 'interviews']));
      expect(parsed.isInterview, isTrue);
      expect(parsed.timeframeDaysHint, 60);
      expect(parsed.deadlineHint, DateTime(2026, 5, 15));
      expect(parsed.titleCandidate, 'Java and DSA Preparation');
    });

    test('detects project intent and urgency flags', () {
      final parsed = service.parse(
        'Finish my SAR-to-RGB project and paper submission asap',
      );

      expect(parsed.inferredGoalType, GoalType.project);
      expect(parsed.isProject, isTrue);
      expect(parsed.isUrgent, isTrue);
      expect(
        parsed.titleCandidate,
        'My Sar-to-rgb Project And Paper Submission Asap',
      );
    });
  });
}
