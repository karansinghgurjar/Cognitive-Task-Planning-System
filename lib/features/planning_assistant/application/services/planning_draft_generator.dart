import '../../../goals/models/learning_goal.dart';
import '../../../routines/domain/routine_enums.dart';
import '../../../tasks/models/task.dart';
import '../../domain/models/parsed_planning_intent.dart';
import '../../domain/models/planning_draft.dart';

class PlanningDraftGenerator {
  const PlanningDraftGenerator();

  PlanningDraft generate(ParsedPlanningIntent intent) {
    final goalDrafts = intent.goals
        .map(
          (goal) => GoalDraft(
            title: goal.title,
            goalType: goal.goalType ?? _fallbackGoalType(goal.type),
            priority: 2,
            targetDate: intent.horizon == null
                ? null
                : DateTime.now().add(
                    Duration(days: intent.horizon!.approximateDays),
                  ),
            estimatedTotalMinutes: _estimatedTotalMinutes(intent, goal),
            description:
                'Generated from natural-language intent: "${intent.rawInput}"',
            explanation: goal.explanation,
          ),
        )
        .toList();

    final routineDrafts = <RoutineDraft>[
      ...intent.routines.map(
        (routine) => RoutineDraft(
          title: routine.title,
          routineType: routine.routineType,
          repeatType:
              routine.repeatType ?? _repeatTypeForDays(routine.preferredDays),
          isFlexible: routine.isFlexible,
          durationMinutes: routine.durationMinutes ?? 60,
          preferredStartMinuteOfDay: routine.preferredStartMinuteOfDay,
          preferredDays: routine.preferredDays.isEmpty
              ? const <int>[
                  DateTime.monday,
                  DateTime.tuesday,
                  DateTime.wednesday,
                  DateTime.thursday,
                  DateTime.friday,
                ]
              : routine.preferredDays,
          linkedGoalTitle: routine.linkedGoalTitle,
          autoRecovery: routine.autoRecovery,
          explanation:
              routine.explanation ??
              'Generated from your schedule preference and planning goal.',
        ),
      ),
      ..._goalSupportRoutines(intent),
    ];

    final taskDrafts = <TaskDraft>[
      ...intent.tasks.map(
        (task) => TaskDraft(
          title: task.title,
          taskType: task.taskType,
          estimatedMinutes: task.estimatedMinutes ?? 60,
          linkedGoalTitle: task.linkedGoalTitle,
          explanation:
              task.explanation ??
              'Added because your request includes a concrete work stream.',
        ),
      ),
      ..._goalSupportTasks(intent),
    ];

    final projectDrafts = _projectDrafts(intent);
    final explanations = <String>[
      ...goalDrafts.map(
        (goal) =>
            'Added "${goal.title}" because the request describes a long-term outcome.',
      ),
      ...routineDrafts.map((routine) => routine.explanation),
      ...taskDrafts.map((task) => task.explanation),
    ];

    final routineMinutes = routineDrafts.fold<int>(
      0,
      (sum, routine) =>
          sum + routine.durationMinutes * _weeklyOccurrences(routine),
    );
    final taskMinutes = taskDrafts.fold<int>(
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
      if (_eveningRoutineCount(routineDrafts) >= 4)
        const PlanningWarning(
          message: 'Several routines are clustered into evenings.',
          severity: PlanningWarningSeverity.info,
          explanation:
              'Multiple evening blocks may cause overload on busy weekdays.',
        ),
      if (routineDrafts.length > 5)
        const PlanningWarning(
          message: 'This plan creates a fairly large routine system.',
          severity: PlanningWarningSeverity.info,
          explanation:
              'Preview carefully so the assistant does not create more recurring structure than you want.',
        ),
    ];

    return PlanningDraft(
      goals: _dedupeGoals(goalDrafts),
      routines: _dedupeRoutines(routineDrafts),
      projects: projectDrafts,
      tasks: _dedupeTasks(taskDrafts),
      loadEstimate: PlanningLoadEstimate(
        weeklyMinutes: weeklyMinutes,
        routineMinutes: routineMinutes,
        taskMinutes: taskMinutes,
        summary:
            'This draft adds about ${_formatMinutes(weeklyMinutes)} per week, with ${_formatMinutes(routineMinutes)} recurring and ${_formatMinutes(taskMinutes)} initial task setup.',
      ),
      warnings: warnings,
      assumptions: intent.assumptions,
      explanations: explanations,
    );
  }

  List<RoutineDraft> _goalSupportRoutines(ParsedPlanningIntent intent) {
    if (intent.goals.isEmpty) {
      return const <RoutineDraft>[];
    }
    final goal = intent.goals.first;
    switch (goal.type) {
      case GoalIntentType.examPrep:
        return <RoutineDraft>[
          RoutineDraft(
            title: 'Revision Block',
            routineType: RoutineType.review,
            repeatType: RoutineRepeatType.weekly,
            isFlexible: true,
            durationMinutes: 90,
            preferredDays: const <int>[DateTime.sunday],
            linkedGoalTitle: goal.title,
            explanation:
                'Added a weekly revision block because exam preparation benefits from regular consolidation.',
          ),
        ];
      case GoalIntentType.thesis:
        return <RoutineDraft>[
          RoutineDraft(
            title: 'Weekly Synthesis Block',
            routineType: RoutineType.project,
            repeatType: RoutineRepeatType.weekly,
            isFlexible: true,
            durationMinutes: 60,
            preferredDays: const <int>[DateTime.friday],
            linkedGoalTitle: goal.title,
            explanation:
                'Added a weekly synthesis block so thesis progress is not only fragmented into reading sessions.',
          ),
        ];
      case GoalIntentType.deepWork:
        return <RoutineDraft>[
          RoutineDraft(
            title: 'Weekly Review Block',
            routineType: RoutineType.review,
            repeatType: RoutineRepeatType.weekly,
            isFlexible: true,
            durationMinutes: 45,
            preferredDays: const <int>[DateTime.friday],
            linkedGoalTitle: goal.title,
            explanation:
                'Added a weekly review block because deep-work systems work better with a reset point.',
          ),
        ];
      case GoalIntentType.fitness:
      case GoalIntentType.skillBuilding:
      case GoalIntentType.custom:
        return const <RoutineDraft>[];
    }
  }

  List<TaskDraft> _goalSupportTasks(ParsedPlanningIntent intent) {
    if (intent.goals.isEmpty) {
      return const <TaskDraft>[];
    }
    final goal = intent.goals.first;
    switch (goal.type) {
      case GoalIntentType.examPrep:
        return <TaskDraft>[
          TaskDraft(
            title: 'Track Topic Coverage',
            taskType: TaskType.study,
            estimatedMinutes: 45,
            linkedGoalTitle: goal.title,
            explanation:
                'Added a tracking task so the plan has one concrete system artifact, not only routines.',
          ),
          TaskDraft(
            title: 'Create Weekly Mock Review',
            taskType: TaskType.study,
            estimatedMinutes: 60,
            linkedGoalTitle: goal.title,
            explanation:
                'Added a weekly review task because exam prep usually needs feedback loops, not only repetition.',
          ),
        ];
      case GoalIntentType.thesis:
        return <TaskDraft>[
          TaskDraft(
            title: 'Define Thesis Milestones',
            taskType: TaskType.project,
            estimatedMinutes: 75,
            linkedGoalTitle: goal.title,
            explanation:
                'Added a milestone-definition task so thesis work starts with structure, not only recurring effort.',
          ),
        ];
      case GoalIntentType.skillBuilding:
        return <TaskDraft>[
          TaskDraft(
            title: 'Create Progress Tracker',
            taskType: TaskType.study,
            estimatedMinutes: 30,
            linkedGoalTitle: goal.title,
            explanation:
                'Added a progress tracker task so improvement can be measured explicitly.',
          ),
        ];
      case GoalIntentType.deepWork:
        return <TaskDraft>[
          TaskDraft(
            title: 'Define Deep Work Rules',
            taskType: TaskType.misc,
            estimatedMinutes: 30,
            linkedGoalTitle: goal.title,
            explanation:
                'Added a setup task because a deep-work system needs explicit rules for when it is used.',
          ),
        ];
      case GoalIntentType.fitness:
      case GoalIntentType.custom:
        return const <TaskDraft>[];
    }
  }

  List<ProjectDraft> _projectDrafts(ParsedPlanningIntent intent) {
    if (intent.goals.isEmpty) {
      return const <ProjectDraft>[];
    }
    final goal = intent.goals.first;
    if (goal.type == GoalIntentType.thesis ||
        goal.type == GoalIntentType.examPrep ||
        goal.type == GoalIntentType.skillBuilding) {
      return <ProjectDraft>[
        ProjectDraft(
          title: '${goal.title} System',
          linkedGoalTitle: goal.title,
          explanation:
              'Grouped related setup tasks and routines into one previewable planning system.',
        ),
      ];
    }
    return const <ProjectDraft>[];
  }

  int _estimatedTotalMinutes(ParsedPlanningIntent intent, GoalIntent goal) {
    final horizonDays = intent.horizon?.approximateDays ?? 42;
    final weeklyMinutes =
        goal.estimatedWeeklyMinutes ??
        _weeklyMinutesForIntensity(intent.intensity);
    return ((horizonDays / 7) * weeklyMinutes).round();
  }

  int _weeklyMinutesForIntensity(PlanningIntensityLevel? intensity) {
    switch (intensity) {
      case PlanningIntensityLevel.light:
        return 180;
      case PlanningIntensityLevel.aggressive:
        return 480;
      case PlanningIntensityLevel.balanced:
      case null:
        return 300;
    }
  }

  GoalType _fallbackGoalType(GoalIntentType type) {
    switch (type) {
      case GoalIntentType.examPrep:
        return GoalType.examPrep;
      case GoalIntentType.thesis:
        return GoalType.project;
      case GoalIntentType.fitness:
      case GoalIntentType.deepWork:
      case GoalIntentType.skillBuilding:
      case GoalIntentType.custom:
        return GoalType.learning;
    }
  }

  RoutineRepeatType _repeatTypeForDays(List<int> preferredDays) {
    if (preferredDays.length == 5 &&
        preferredDays.every((day) => day <= DateTime.friday)) {
      return RoutineRepeatType.weekdays;
    }
    if (preferredDays.length == 7) {
      return RoutineRepeatType.daily;
    }
    if (preferredDays.length <= 1) {
      return RoutineRepeatType.weekly;
    }
    return RoutineRepeatType.selectedWeekdays;
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

  int _eveningRoutineCount(List<RoutineDraft> routines) {
    return routines.where((routine) {
      final start = routine.preferredStartMinuteOfDay;
      return start != null && start >= 18 * 60;
    }).length;
  }

  List<GoalDraft> _dedupeGoals(List<GoalDraft> goals) {
    final seen = <String>{};
    return goals.where((goal) => seen.add(goal.title.toLowerCase())).toList();
  }

  List<RoutineDraft> _dedupeRoutines(List<RoutineDraft> routines) {
    final seen = <String>{};
    return routines
        .where((routine) => seen.add(routine.title.toLowerCase()))
        .toList();
  }

  List<TaskDraft> _dedupeTasks(List<TaskDraft> tasks) {
    final seen = <String>{};
    return tasks.where((task) => seen.add(task.title.toLowerCase())).toList();
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
