import '../../goals/models/learning_goal.dart';
import '../../tasks/models/task.dart';
import 'ai_planning_models.dart';
import 'dependency_suggestion_service.dart';
import 'duration_estimation_service.dart';
import 'goal_prompt_parser_service.dart';
import 'planning_context.dart';

class RuleBasedGoalBreakdownService {
  const RuleBasedGoalBreakdownService({
    this.parser = const GoalPromptParserService(),
    this.durationEstimationService = const DurationEstimationService(),
    this.dependencySuggestionService = const DependencySuggestionService(),
  });

  final GoalPromptParserService parser;
  final DurationEstimationService durationEstimationService;
  final DependencySuggestionService dependencySuggestionService;

  AiPlanResult generatePlan(
    NaturalLanguagePlanRequest request,
    PlanningContext context, {
    DateTime? now,
  }) {
    final parsed = parser.parse(request.prompt, now: now);
    final milestones = _buildMilestones(parsed, request);
    final tasks = _buildTasks(parsed, milestones, request);
    final estimates = durationEstimationService.estimateTasks(
      tasks,
      context,
      parsedPrompt: parsed,
    );
    final estimatedByTaskId = {
      for (final estimate in estimates) estimate.taskDraftId: estimate,
    };
    final normalizedTasks = tasks
        .map(
          (task) => task.copyWith(
            estimatedMinutes:
                estimatedByTaskId[task.id]?.estimatedMinutes ??
                task.estimatedMinutes,
            reasoning: estimatedByTaskId[task.id]?.reasoning ?? task.reasoning,
          ),
        )
        .toList();
    final dependencies = dependencySuggestionService.suggestDependencies(
      normalizedTasks,
      parsed,
    );
    final goalDraft = _buildGoalDraft(parsed, normalizedTasks, request);
    final suggestions = _buildSuggestions(
      parsed,
      context,
      goalDraft,
      normalizedTasks,
      request,
    );
    final warnings = _buildWarnings(parsed, context, normalizedTasks, request);

    return AiPlanResult(
      request: request,
      parsedPrompt: parsed,
      goal: goalDraft,
      milestones: milestones,
      tasks: normalizedTasks,
      dependencies: dependencies,
      durationEstimates: estimates,
      suggestions: suggestions,
      warnings: warnings,
      explanationSummary: _buildExplanationSummary(
        parsed,
        milestones,
        normalizedTasks,
      ),
      suggestedWeeklyMinutes: _suggestWeeklyMinutes(
        goalDraft,
        normalizedTasks,
        request,
        context,
      ),
      suggestedCadence: _buildCadence(
        goalDraft,
        normalizedTasks,
        request,
        context,
      ),
    );
  }

  List<MilestoneDraft> _buildMilestones(
    ParsedGoalPrompt parsed,
    NaturalLanguagePlanRequest request,
  ) {
    final names = _milestoneTemplates(parsed);
    return List<MilestoneDraft>.generate(names.length, (index) {
      final name = names[index];
      final estimatedMinutes = _milestoneDurationHint(parsed, name);
      return MilestoneDraft(
        id: 'milestone-${index + 1}',
        title: name,
        description:
            'Suggested from the ${parsed.inferredGoalType.label.toLowerCase()} roadmap template.',
        sequenceOrder: index + 1,
        estimatedMinutes: estimatedMinutes,
        reasoning:
            'Placed at step ${index + 1} because it builds toward ${request.prompt.trim()}.',
      );
    });
  }

  List<TaskDraft> _buildTasks(
    ParsedGoalPrompt parsed,
    List<MilestoneDraft> milestones,
    NaturalLanguagePlanRequest request,
  ) {
    final tasks = <TaskDraft>[];
    for (final milestone in milestones) {
      final milestoneTasks = _taskTitlesForMilestone(parsed, milestone.title);
      for (var index = 0; index < milestoneTasks.length; index++) {
        final taskTitle = milestoneTasks[index];
        tasks.add(
          TaskDraft(
            id: '${milestone.id}-task-${index + 1}',
            title: taskTitle,
            description: 'Suggested from the "${milestone.title}" milestone.',
            type: _inferTaskType(parsed, taskTitle),
            estimatedMinutes: _taskDurationHint(parsed, taskTitle),
            milestoneDraftId: milestone.id,
            dueDate: _taskDueDate(
              request.targetDate,
              milestone.sequenceOrder,
              milestones.length,
            ),
            reasoning: _taskReasoning(parsed, milestone.title, taskTitle),
            heuristicCategory: milestone.title.toLowerCase(),
          ),
        );
      }
    }

    if (tasks.isEmpty) {
      tasks.add(
        TaskDraft(
          id: 'task-1',
          title: parsed.titleCandidate,
          description: 'Fallback task generated from the original goal prompt.',
          type: _inferTaskType(parsed, parsed.titleCandidate),
          estimatedMinutes: 120,
          dueDate: request.targetDate,
          reasoning:
              'No detailed milestone template matched, so a coarse starter task was created.',
          heuristicCategory: 'fallback',
        ),
      );
    }

    return tasks;
  }

  GoalDraft _buildGoalDraft(
    ParsedGoalPrompt parsed,
    List<TaskDraft> tasks,
    NaturalLanguagePlanRequest request,
  ) {
    final estimatedTotalMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    return GoalDraft(
      title: parsed.titleCandidate,
      description: 'Generated from: ${request.prompt.trim()}',
      goalType: parsed.inferredGoalType,
      targetDate: request.targetDate ?? parsed.deadlineHint,
      priority: request.priority,
      estimatedTotalMinutes: estimatedTotalMinutes,
      reasoning:
          'Goal type inferred from keywords ${parsed.keywords.join(', ')}.',
    );
  }

  List<PlanningSuggestion> _buildSuggestions(
    ParsedGoalPrompt parsed,
    PlanningContext context,
    GoalDraft goal,
    List<TaskDraft> tasks,
    NaturalLanguagePlanRequest request,
  ) {
    final totalMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    final weeklyMinutes = _suggestWeeklyMinutes(goal, tasks, request, context);
    final suggestions = <PlanningSuggestion>[
      PlanningSuggestion(
        title: 'Suggested cadence',
        description:
            'Aim for about ${(weeklyMinutes / 60).toStringAsFixed(1)} hours each week to move this plan forward.',
        suggestedActionText:
            'Reserve ${context.preferredSessionLengthMinutes}-minute focus blocks ${_sessionCountLabel(weeklyMinutes, context.preferredSessionLengthMinutes)}.',
        reasoning:
            'Cadence is based on the plan size and your current weekly capacity.',
      ),
    ];

    if (request.targetDate != null) {
      suggestions.add(
        PlanningSuggestion(
          title: 'Target-date pacing',
          description:
              'The current plan needs about ${(totalMinutes / 60).toStringAsFixed(1)} total hours before ${request.targetDate!.toLocal().toIso8601String().split('T').first}.',
          suggestedActionText:
              'Generate a schedule after importing so the workload is spread across available time.',
          reasoning:
              'A target date was provided, so the plan is prepared for scheduling and feasibility checks.',
        ),
      );
    }

    if (parsed.isInterview || parsed.isExam) {
      suggestions.add(
        const PlanningSuggestion(
          title: 'Revision checkpoint',
          description:
              'Include at least one recap or mock-practice step near the end of the roadmap.',
          suggestedActionText: 'Keep a final review block before the deadline.',
          reasoning:
              'Assessment-driven goals benefit from rehearsal after concept coverage.',
        ),
      );
    }

    return suggestions;
  }

  List<AiPlanningWarning> _buildWarnings(
    ParsedGoalPrompt parsed,
    PlanningContext context,
    List<TaskDraft> tasks,
    NaturalLanguagePlanRequest request,
  ) {
    final warnings = <AiPlanningWarning>[];
    final totalMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    if (context.availableWeeklyMinutes > 0 &&
        totalMinutes > context.availableWeeklyMinutes * 2) {
      warnings.add(
        AiPlanningWarning(
          message:
              'This draft is larger than two weeks of your currently available capacity.',
          severity: AiWarningSeverity.caution,
          reasoning:
              'Estimated workload is $totalMinutes minutes vs ${context.availableWeeklyMinutes} minutes available per week.',
        ),
      );
    }
    if (parsed.isUrgent &&
        request.targetDate == null &&
        parsed.timeframeDaysHint == null) {
      warnings.add(
        const AiPlanningWarning(
          message: 'The prompt sounds urgent, but no target date was given.',
          severity: AiWarningSeverity.info,
          reasoning:
              'Adding a date will improve feasibility and scheduling advice.',
        ),
      );
    }
    if (context.currentActiveGoalsCount >= 4) {
      warnings.add(
        const AiPlanningWarning(
          message: 'You already have several active goals.',
          severity: AiWarningSeverity.caution,
          reasoning:
              'Consider pausing or deprioritizing another goal before adding a large new roadmap.',
        ),
      );
    }
    return warnings;
  }

  String _buildExplanationSummary(
    ParsedGoalPrompt parsed,
    List<MilestoneDraft> milestones,
    List<TaskDraft> tasks,
  ) {
    return 'Generated ${milestones.length} milestones and ${tasks.length} tasks from the ${parsed.inferredGoalType.label.toLowerCase()} template using keywords: ${parsed.keywords.join(', ')}.';
  }

  int _suggestWeeklyMinutes(
    GoalDraft goal,
    List<TaskDraft> tasks,
    NaturalLanguagePlanRequest request,
    PlanningContext context,
  ) {
    final totalMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedMinutes,
    );
    final targetDate = goal.targetDate;
    if (targetDate != null) {
      final days = targetDate.difference(DateTime.now()).inDays.clamp(1, 365);
      final weeks = (days / 7).ceil();
      final required = (totalMinutes / weeks).ceil();
      return required.clamp(
        60,
        context.availableWeeklyMinutes > 0
            ? context.availableWeeklyMinutes * 2
            : totalMinutes,
      );
    }
    return switch (request.intensity) {
      PlanningIntensity.conservative => (totalMinutes / 8).ceil().clamp(
        60,
        totalMinutes,
      ),
      PlanningIntensity.balanced => (totalMinutes / 6).ceil().clamp(
        90,
        totalMinutes,
      ),
      PlanningIntensity.aggressive => (totalMinutes / 4).ceil().clamp(
        120,
        totalMinutes,
      ),
    };
  }

  String _buildCadence(
    GoalDraft goal,
    List<TaskDraft> tasks,
    NaturalLanguagePlanRequest request,
    PlanningContext context,
  ) {
    final weeklyMinutes = _suggestWeeklyMinutes(goal, tasks, request, context);
    final sessions = (weeklyMinutes / context.preferredSessionLengthMinutes)
        .ceil();
    return '$sessions sessions per week at about ${context.preferredSessionLengthMinutes} minutes each.';
  }

  List<String> _milestoneTemplates(ParsedGoalPrompt parsed) {
    final keywords = parsed.keywords.toSet();
    if (keywords.contains('flutter')) {
      return const [
        'Dart basics',
        'Flutter widgets and layout',
        'State management',
        'Navigation and local storage',
        'Mini project',
      ];
    }
    if (keywords.contains('java') && keywords.contains('dsa')) {
      return const [
        'Java fundamentals revision',
        'OOP and collections',
        'Arrays and strings',
        'Linked structures and recursion',
        'Trees and graphs',
        'Mock interview practice',
      ];
    }
    if (keywords.contains('dsa')) {
      return const [
        'Core data structures',
        'Arrays and strings',
        'Linked structures',
        'Trees and graphs',
        'Practice and review',
      ];
    }
    if (parsed.isProject) {
      return const [
        'Scope and requirements',
        'Implementation',
        'Evaluation and validation',
        'Paper or presentation draft',
        'Final polish and submission',
      ];
    }
    if (parsed.isExam || parsed.keywords.contains('cv')) {
      return const [
        'Concept review',
        'Unit 1 coverage',
        'Unit 2 coverage',
        'Practice questions',
        'Final revision',
      ];
    }
    return const [
      'Foundations',
      'Core practice',
      'Applied work',
      'Review and polish',
    ];
  }

  List<String> _taskTitlesForMilestone(
    ParsedGoalPrompt parsed,
    String milestoneTitle,
  ) {
    final lower = milestoneTitle.toLowerCase();
    if (lower.contains('dart basics')) {
      return const [
        'Set up Dart syntax and types practice',
        'Solve small Dart exercises',
      ];
    }
    if (lower.contains('flutter widgets')) {
      return const [
        'Build layout practice screens',
        'Study widget composition and theming',
      ];
    }
    if (lower.contains('state management')) {
      return const [
        'Learn Riverpod state flows',
        'Refactor a sample app with state management',
      ];
    }
    if (lower.contains('navigation')) {
      return const [
        'Implement navigation and persistence',
        'Store local app data with Isar',
      ];
    }
    if (lower.contains('mini project')) {
      return const [
        'Define mini project scope',
        'Build and test the mini project',
      ];
    }
    if (lower.contains('java fundamentals')) {
      return const [
        'Revise Java syntax and control flow',
        'Practice core Java exercises',
      ];
    }
    if (lower.contains('oop')) {
      return const [
        'Review OOP principles and collections',
        'Solve Java collection practice problems',
      ];
    }
    if (lower.contains('arrays and strings')) {
      return const [
        'Practice arrays and strings questions',
        'Review common patterns and edge cases',
      ];
    }
    if (lower.contains('linked')) {
      return const [
        'Study linked structures and recursion',
        'Implement queue or stack exercises',
      ];
    }
    if (lower.contains('trees and graphs')) {
      return const [
        'Practice tree traversal problems',
        'Study graph basics and solve problems',
      ];
    }
    if (lower.contains('mock')) {
      return const [
        'Run mock interview sets',
        'Review weak areas from mock sessions',
      ];
    }
    if (lower.contains('scope')) {
      return const [
        'Define deliverables and acceptance criteria',
        'Outline the implementation plan',
      ];
    }
    if (lower.contains('implementation')) {
      return const [
        'Implement the core pipeline',
        'Validate outputs on sample cases',
      ];
    }
    if (lower.contains('evaluation')) {
      return const [
        'Prepare evaluation data or metrics',
        'Run experiments and record results',
      ];
    }
    if (lower.contains('paper')) {
      return const [
        'Draft paper or presentation structure',
        'Write results and discussion sections',
      ];
    }
    if (lower.contains('submission')) {
      return const [
        'Polish final deliverables',
        'Submit and archive materials',
      ];
    }
    if (lower.contains('review')) {
      return const ['Review notes and summaries', 'Do a timed recap session'];
    }
    if (lower.contains('practice')) {
      return const ['Solve guided practice tasks', 'Review mistakes and recap'];
    }
    if (parsed.keywords.contains('cv')) {
      return [
        'Study $milestoneTitle notes',
        'Practice $milestoneTitle questions',
      ];
    }
    return ['Study $milestoneTitle', 'Apply $milestoneTitle in practice'];
  }

  TaskType _inferTaskType(ParsedGoalPrompt parsed, String taskTitle) {
    final lower = taskTitle.toLowerCase();
    if (lower.contains('implement') ||
        lower.contains('build') ||
        lower.contains('code')) {
      return parsed.isProject ? TaskType.project : TaskType.coding;
    }
    if (lower.contains('read') ||
        lower.contains('study') ||
        lower.contains('review')) {
      return TaskType.reading;
    }
    if (parsed.isProject) {
      return TaskType.project;
    }
    if (parsed.keywords.contains('java') ||
        parsed.keywords.contains('flutter') ||
        parsed.keywords.contains('dsa')) {
      return TaskType.coding;
    }
    return TaskType.study;
  }

  int _milestoneDurationHint(ParsedGoalPrompt parsed, String milestoneTitle) {
    if (milestoneTitle.toLowerCase().contains('mini project') ||
        milestoneTitle.toLowerCase().contains('implementation')) {
      return parsed.isProject ? 360 : 240;
    }
    if (milestoneTitle.toLowerCase().contains('mock') ||
        milestoneTitle.toLowerCase().contains('revision')) {
      return 120;
    }
    return 180;
  }

  int _taskDurationHint(ParsedGoalPrompt parsed, String taskTitle) {
    final lower = taskTitle.toLowerCase();
    if (lower.contains('build and test') ||
        lower.contains('implement the core')) {
      return 180;
    }
    if (lower.contains('solve') || lower.contains('practice')) {
      return 90;
    }
    if (lower.contains('review') ||
        lower.contains('read') ||
        lower.contains('study')) {
      return 60;
    }
    if (parsed.isProject) {
      return 120;
    }
    return 75;
  }

  DateTime? _taskDueDate(
    DateTime? targetDate,
    int sequenceOrder,
    int totalMilestones,
  ) {
    if (targetDate == null) {
      return null;
    }
    final now = DateTime.now();
    final totalDays = targetDate.difference(now).inDays;
    if (totalDays <= 0) {
      return targetDate;
    }
    final fraction = sequenceOrder / totalMilestones;
    return now.add(Duration(days: (totalDays * fraction).round()));
  }

  String _taskReasoning(
    ParsedGoalPrompt parsed,
    String milestoneTitle,
    String taskTitle,
  ) {
    return 'Suggested because "$taskTitle" is a practical step under "$milestoneTitle" for ${parsed.titleCandidate}.';
  }

  String _sessionCountLabel(int weeklyMinutes, int sessionLengthMinutes) {
    final sessions = (weeklyMinutes / sessionLengthMinutes).ceil();
    return '$sessions times a week';
  }
}
