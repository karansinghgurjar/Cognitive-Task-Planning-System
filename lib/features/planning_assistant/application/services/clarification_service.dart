import '../../domain/models/clarification_question.dart';
import '../../domain/models/parsed_planning_intent.dart';

class ClarificationService {
  const ClarificationService();

  List<ClarificationQuestion> buildQuestions(ParsedPlanningIntent intent) {
    final questions = <ClarificationQuestion>[];
    final needsGoalScope =
        intent.goals.isEmpty ||
        intent.ambiguities.any(
          (ambiguity) => ambiguity.contains('specific planning target'),
        );
    if (needsGoalScope) {
      questions.add(
        const ClarificationQuestion(
          id: 'goal_scope',
          question: 'What are you planning for?',
          type: ClarificationType.goalScope,
          required: true,
        ),
      );
    }
    if (!needsGoalScope && intent.horizon == null && intent.goals.isNotEmpty) {
      questions.add(
        const ClarificationQuestion(
          id: 'goal_horizon',
          question: 'What is the rough horizon for this plan?',
          type: ClarificationType.goalHorizon,
          options: <String>['2 weeks', '6 weeks', '3 months', '6 months'],
          required: true,
        ),
      );
    }
    if (intent.routines.isNotEmpty &&
        intent.routines.every((routine) => routine.durationMinutes == null)) {
      questions.add(
        const ClarificationQuestion(
          id: 'duration',
          question: 'How long should the main work block be?',
          type: ClarificationType.duration,
          options: <String>['30 min', '45 min', '60 min', '90 min'],
          required: false,
        ),
      );
    }
    if (intent.routines.isNotEmpty &&
        intent.routines.every(
          (routine) =>
              routine.preferredStartMinuteOfDay == null && routine.isFlexible,
        )) {
      questions.add(
        const ClarificationQuestion(
          id: 'schedule_preference',
          question: 'Do you prefer morning, afternoon, or evening?',
          type: ClarificationType.schedulePreference,
          options: <String>['Morning', 'Afternoon', 'Evening', 'Flexible'],
          required: false,
        ),
      );
    }
    if (intent.intensity == null) {
      questions.add(
        const ClarificationQuestion(
          id: 'intensity',
          question: 'How dense should the plan feel?',
          type: ClarificationType.intensity,
          options: <String>['Light', 'Balanced', 'Aggressive'],
          required: false,
        ),
      );
    }
    return questions;
  }
}
