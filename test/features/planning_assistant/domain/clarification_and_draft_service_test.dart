import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/planning_assistant/application/services/clarification_service.dart';
import 'package:study_flow/features/planning_assistant/application/services/intent_extraction_service.dart';
import 'package:study_flow/features/planning_assistant/application/services/planning_assistant_service.dart';
import 'package:study_flow/features/planning_assistant/application/services/planning_draft_generator.dart';
import 'package:study_flow/features/planning_assistant/domain/models/clarification_question.dart';

void main() {
  group('ClarificationService', () {
    const extraction = IntentExtractionService();
    const clarification = ClarificationService();
    const assistant = PlanningAssistantService(
      extractionService: extraction,
      clarificationService: clarification,
      draftGenerator: PlanningDraftGenerator(),
    );

    test('asks for missing high-impact details only', () {
      final intent = extraction.extract('I want to study more.');
      final questions = clarification.buildQuestions(intent);

      expect(
        questions.any(
          (question) => question.type == ClarificationType.goalScope,
        ),
        isTrue,
      );
      expect(
        questions.any(
          (question) => question.type == ClarificationType.goalHorizon,
        ),
        isFalse,
      );
    });

    test('avoids unnecessary clarification for well-specified routine', () {
      final intent = extraction.extract(
        'I want to spend 1 hour daily on thesis work for the next 6 weeks in the morning.',
      );
      final questions = clarification.buildQuestions(intent);

      expect(
        questions.where((question) => question.required).length,
        lessThanOrEqualTo(1),
      );
    });

    test('clarification answers update resulting draft', () {
      final parsed = assistant.parse('I want to improve DSA.');
      final draft = assistant.generateDraft(
        parsed,
        answers: const <ClarificationAnswer>[
          ClarificationAnswer(
            questionId: 'goal_horizon',
            value: 'next 6 weeks',
          ),
          ClarificationAnswer(
            questionId: 'schedule_preference',
            value: 'Evening',
          ),
          ClarificationAnswer(questionId: 'duration', value: '60 min'),
        ],
      );

      expect(draft.goals, isNotEmpty);
      expect(draft.routines, isNotEmpty);
      expect(draft.routines.first.preferredStartMinuteOfDay, 19 * 60);
      expect(draft.routines.first.durationMinutes, 60);
    });

    test('generated draft stays deterministic for the same input', () {
      final parsed = assistant.parse(
        'I need a deep work system for weekdays over the next 6 weeks.',
      );

      final first = assistant.generateDraft(parsed);
      final second = assistant.generateDraft(parsed);

      expect(
        first.goals.map((goal) => goal.title).toList(),
        second.goals.map((goal) => goal.title).toList(),
      );
      expect(
        first.routines.map((routine) => routine.title).toList(),
        second.routines.map((routine) => routine.title).toList(),
      );
      expect(
        first.tasks.map((task) => task.title).toList(),
        second.tasks.map((task) => task.title).toList(),
      );
      expect(
        first.loadEstimate.weeklyMinutes,
        second.loadEstimate.weeklyMinutes,
      );
    });
  });
}
