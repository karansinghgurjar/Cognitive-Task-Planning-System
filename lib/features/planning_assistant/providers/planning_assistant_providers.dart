import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../goals/data/goal_repository.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../routines/data/routine_repository.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/models/routine.dart';
import '../../routines/providers/routine_intelligence_providers.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/models/task.dart';
import '../application/services/clarification_service.dart';
import '../application/services/intent_extraction_service.dart';
import '../application/services/planning_assistant_apply_service.dart';
import '../application/services/planning_assistant_service.dart';
import '../application/services/planning_draft_generator.dart';
import '../domain/models/clarification_question.dart';
import '../domain/models/parsed_planning_intent.dart';
import '../domain/models/planning_draft.dart';

final intentExtractionServiceProvider = Provider<IntentExtractionService>((
  ref,
) {
  return const IntentExtractionService();
});

final planningClarificationServiceProvider = Provider<ClarificationService>((
  ref,
) {
  return const ClarificationService();
});

final planningDraftGeneratorProvider = Provider<PlanningDraftGenerator>((ref) {
  return const PlanningDraftGenerator();
});

final planningAssistantServiceProvider = Provider<PlanningAssistantService>((
  ref,
) {
  return PlanningAssistantService(
    extractionService: ref.read(intentExtractionServiceProvider),
    clarificationService: ref.read(planningClarificationServiceProvider),
    draftGenerator: ref.read(planningDraftGeneratorProvider),
  );
});

final planningAssistantApplyServiceProvider =
    FutureProvider<PlanningAssistantApplyService>((ref) async {
      final isar = await ref.watch(isarInstanceProvider.future);
      final goalStore = GoalRepository(isar);
      final taskStore = TaskRepository(isar);
      final routineStore = RoutineRepository(isar);
      return PlanningAssistantApplyService(
        goalStore: _PlanningAssistantGoalStore(goalStore),
        taskStore: _PlanningAssistantTaskStore(taskStore),
        routineStore: _PlanningAssistantRoutineStore(routineStore),
        postApplyRefresh: () async {
          await ref
              .read(routineIntelligenceControllerProvider.notifier)
              .runSchedulingIntegration();
        },
      );
    });

class PlanningAssistantState {
  const PlanningAssistantState({
    this.prompt = '',
    this.parsedIntent,
    this.questions = const <ClarificationQuestion>[],
    this.answers = const <String, String>{},
    this.draft,
    this.applyResult,
    this.isBusy = false,
  });

  final String prompt;
  final ParsedPlanningIntent? parsedIntent;
  final List<ClarificationQuestion> questions;
  final Map<String, String> answers;
  final PlanningDraft? draft;
  final PlanningApplyResult? applyResult;
  final bool isBusy;

  PlanningAssistantState copyWith({
    String? prompt,
    ParsedPlanningIntent? parsedIntent,
    bool clearParsedIntent = false,
    List<ClarificationQuestion>? questions,
    Map<String, String>? answers,
    PlanningDraft? draft,
    bool clearDraft = false,
    PlanningApplyResult? applyResult,
    bool clearApplyResult = false,
    bool? isBusy,
  }) {
    return PlanningAssistantState(
      prompt: prompt ?? this.prompt,
      parsedIntent: clearParsedIntent
          ? null
          : parsedIntent ?? this.parsedIntent,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      draft: clearDraft ? null : draft ?? this.draft,
      applyResult: clearApplyResult ? null : applyResult ?? this.applyResult,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

final planningAssistantControllerProvider =
    StateNotifierProvider<PlanningAssistantController, PlanningAssistantState>((
      ref,
    ) {
      return PlanningAssistantController(ref);
    });

class PlanningAssistantController
    extends StateNotifier<PlanningAssistantState> {
  PlanningAssistantController(this._ref)
    : super(const PlanningAssistantState());

  final Ref _ref;

  void setPrompt(String value) {
    state = state.copyWith(
      prompt: value,
      clearDraft: true,
      clearApplyResult: true,
    );
  }

  void analyzePrompt() {
    final service = _ref.read(planningAssistantServiceProvider);
    final parsedIntent = service.parse(state.prompt);
    final questions = service.buildClarifications(parsedIntent);
    state = state.copyWith(
      parsedIntent: parsedIntent,
      questions: questions,
      clearDraft: true,
      clearApplyResult: true,
    );
  }

  void answerQuestion(String id, String value) {
    state = state.copyWith(
      answers: <String, String>{...state.answers, id: value},
    );
  }

  void generateDraft() {
    final parsedIntent = state.parsedIntent;
    if (parsedIntent == null) {
      analyzePrompt();
    }
    final service = _ref.read(planningAssistantServiceProvider);
    final resolvedIntent = service.parse(state.prompt);
    final answers = state.answers.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) =>
              ClarificationAnswer(questionId: entry.key, value: entry.value),
        )
        .toList();
    final draft = service.generateDraft(resolvedIntent, answers: answers);
    state = state.copyWith(
      parsedIntent: resolvedIntent,
      draft: draft,
      clearApplyResult: true,
    );
  }

  void removeGoal(int index) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    final nextGoals = [...draft.goals]..removeAt(index);
    state = state.copyWith(
      draft: _recalculateDraft(draft.copyWith(goals: nextGoals)),
    );
  }

  void removeRoutine(int index) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    final nextRoutines = [...draft.routines]..removeAt(index);
    state = state.copyWith(
      draft: _recalculateDraft(draft.copyWith(routines: nextRoutines)),
    );
  }

  void removeTask(int index) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    final nextTasks = [...draft.tasks]..removeAt(index);
    state = state.copyWith(
      draft: _recalculateDraft(draft.copyWith(tasks: nextTasks)),
    );
  }

  void updateRoutine(int index, RoutineDraft draftUpdate) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }
    final nextRoutines = [...draft.routines];
    nextRoutines[index] = draftUpdate;
    state = state.copyWith(
      draft: _recalculateDraft(draft.copyWith(routines: nextRoutines)),
    );
  }

  Future<PlanningApplyResult?> applyDraft() async {
    final draft = state.draft;
    if (draft == null) {
      return null;
    }
    state = state.copyWith(isBusy: true, clearApplyResult: true);
    try {
      final service = await _ref.read(
        planningAssistantApplyServiceProvider.future,
      );
      final result = await service.applyDraft(draft);
      state = state.copyWith(isBusy: false, applyResult: result);
      return result;
    } catch (_) {
      state = state.copyWith(isBusy: false);
      rethrow;
    }
  }

  void reset() {
    state = const PlanningAssistantState();
  }

  PlanningDraft _recalculateDraft(PlanningDraft draft) {
    final routineMinutes = draft.routines.fold<int>(
      0,
      (sum, routine) =>
          sum + routine.durationMinutes * _weeklyOccurrences(routine),
    );
    final taskMinutes = draft.tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    final weeklyMinutes = routineMinutes + taskMinutes;
    final warnings = <PlanningWarning>[
      if (weeklyMinutes > 14 * 60)
        const PlanningWarning(
          message: 'This draft is dense for a normal week.',
          severity: PlanningWarningSeverity.caution,
          explanation:
              'Weekly load crossed the default 14-hour comfort threshold. Reduce intensity or remove one routine before applying.',
        ),
      if (draft.routines.where((routine) {
            final start = routine.preferredStartMinuteOfDay;
            return start != null && start >= 18 * 60;
          }).length >=
          4)
        const PlanningWarning(
          message: 'Several routines are clustered into evenings.',
          severity: PlanningWarningSeverity.info,
          explanation:
              'Multiple evening blocks may cause overload on busy weekdays.',
        ),
    ];
    return draft.copyWith(
      loadEstimate: PlanningLoadEstimate(
        weeklyMinutes: weeklyMinutes,
        routineMinutes: routineMinutes,
        taskMinutes: taskMinutes,
        summary:
            'This draft adds about ${_formatMinutes(weeklyMinutes)} per week, with ${_formatMinutes(routineMinutes)} recurring and ${_formatMinutes(taskMinutes)} initial task setup.',
      ),
      warnings: warnings,
    );
  }

  int _weeklyOccurrences(RoutineDraft routine) {
    switch (routine.repeatType) {
      case RoutineRepeatType.daily:
        return 7;
      case RoutineRepeatType.weekdays:
        return 5;
      case RoutineRepeatType.selectedWeekdays:
        return routine.preferredDays.isEmpty ? 3 : routine.preferredDays.length;
      case RoutineRepeatType.weekly:
        return routine.preferredDays.isEmpty ? 1 : routine.preferredDays.length;
      case RoutineRepeatType.monthly:
        return 1;
    }
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) {
      return '${remainder}m';
    }
    if (remainder == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainder}m';
  }
}

class _PlanningAssistantGoalStore implements PlanningAssistantGoalStore {
  const _PlanningAssistantGoalStore(this._repository);

  final GoalRepository _repository;

  @override
  Future<void> addGoal(LearningGoal goal) => _repository.addGoal(goal);

  @override
  Future<void> addMilestone(GoalMilestone milestone) =>
      _repository.addMilestone(milestone);

  @override
  Future<List<LearningGoal>> getAllGoals() => _repository.getAllGoals();
}

class _PlanningAssistantTaskStore implements PlanningAssistantTaskStore {
  const _PlanningAssistantTaskStore(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> addTask(Task task) => _repository.addTask(task);

  @override
  Future<List<Task>> getAllTasks() => _repository.getAllTasks();
}

class _PlanningAssistantRoutineStore implements PlanningAssistantRoutineStore {
  const _PlanningAssistantRoutineStore(this._repository);

  final RoutineRepository _repository;

  @override
  Future<List<Routine>> getAllRoutines() => _repository.getAllRoutines();

  @override
  Future<void> saveRoutine(Routine routine) => _repository.saveRoutine(routine);
}
