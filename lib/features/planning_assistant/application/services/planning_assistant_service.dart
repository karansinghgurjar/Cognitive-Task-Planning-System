import '../../domain/models/clarification_question.dart';
import '../../domain/models/parsed_planning_intent.dart';
import '../../domain/models/planning_draft.dart';
import 'clarification_service.dart';
import 'intent_extraction_service.dart';
import 'planning_draft_generator.dart';

class PlanningAssistantService {
  const PlanningAssistantService({
    required IntentExtractionService extractionService,
    required ClarificationService clarificationService,
    required PlanningDraftGenerator draftGenerator,
  }) : _extractionService = extractionService,
       _clarificationService = clarificationService,
       _draftGenerator = draftGenerator;

  final IntentExtractionService _extractionService;
  final ClarificationService _clarificationService;
  final PlanningDraftGenerator _draftGenerator;

  ParsedPlanningIntent parse(String input) {
    return _extractionService.extract(input);
  }

  List<ClarificationQuestion> buildClarifications(ParsedPlanningIntent intent) {
    return _clarificationService.buildQuestions(intent);
  }

  ParsedPlanningIntent applyClarificationAnswers(
    ParsedPlanningIntent base,
    List<ClarificationAnswer> answers,
  ) {
    var augmentedInput = base.rawInput;
    for (final answer in answers) {
      if (answer.value.trim().isEmpty) {
        continue;
      }
      augmentedInput = '$augmentedInput ${answer.value.trim()}';
    }
    return parse(augmentedInput);
  }

  PlanningDraft generateDraft(
    ParsedPlanningIntent intent, {
    List<ClarificationAnswer> answers = const <ClarificationAnswer>[],
  }) {
    final resolvedIntent = answers.isEmpty
        ? intent
        : applyClarificationAnswers(intent, answers);
    return _draftGenerator.generate(resolvedIntent);
  }
}
