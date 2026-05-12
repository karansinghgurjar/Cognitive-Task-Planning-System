import '../../../goals/models/learning_goal.dart';
import '../../../routines/domain/routine_enums.dart';
import '../../../tasks/models/task.dart';

enum PlanningWarningSeverity { info, caution, high }

class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.goalType,
    required this.priority,
    this.description,
    this.targetDate,
    this.estimatedTotalMinutes,
    this.explanation,
  });

  final String title;
  final GoalType goalType;
  final int priority;
  final String? description;
  final DateTime? targetDate;
  final int? estimatedTotalMinutes;
  final String? explanation;
}

class RoutineDraft {
  const RoutineDraft({
    required this.title,
    required this.routineType,
    required this.repeatType,
    required this.isFlexible,
    required this.durationMinutes,
    required this.explanation,
    this.preferredStartMinuteOfDay,
    this.preferredDays = const <int>[],
    this.linkedGoalTitle,
    this.autoRecovery = false,
  });

  final String title;
  final RoutineType routineType;
  final RoutineRepeatType repeatType;
  final bool isFlexible;
  final int durationMinutes;
  final String explanation;
  final int? preferredStartMinuteOfDay;
  final List<int> preferredDays;
  final String? linkedGoalTitle;
  final bool autoRecovery;

  RoutineDraft copyWith({
    String? title,
    RoutineType? routineType,
    RoutineRepeatType? repeatType,
    bool? isFlexible,
    int? durationMinutes,
    String? explanation,
    int? preferredStartMinuteOfDay,
    bool clearPreferredStartMinuteOfDay = false,
    List<int>? preferredDays,
    String? linkedGoalTitle,
    bool clearLinkedGoalTitle = false,
    bool? autoRecovery,
  }) {
    return RoutineDraft(
      title: title ?? this.title,
      routineType: routineType ?? this.routineType,
      repeatType: repeatType ?? this.repeatType,
      isFlexible: isFlexible ?? this.isFlexible,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      explanation: explanation ?? this.explanation,
      preferredStartMinuteOfDay: clearPreferredStartMinuteOfDay
          ? null
          : preferredStartMinuteOfDay ?? this.preferredStartMinuteOfDay,
      preferredDays: preferredDays ?? this.preferredDays,
      linkedGoalTitle: clearLinkedGoalTitle
          ? null
          : linkedGoalTitle ?? this.linkedGoalTitle,
      autoRecovery: autoRecovery ?? this.autoRecovery,
    );
  }
}

class ProjectDraft {
  const ProjectDraft({
    required this.title,
    required this.explanation,
    this.linkedGoalTitle,
  });

  final String title;
  final String explanation;
  final String? linkedGoalTitle;
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.taskType,
    required this.estimatedMinutes,
    required this.explanation,
    this.linkedGoalTitle,
    this.projectTitle,
    this.milestoneTitle,
    this.dueDate,
  });

  final String title;
  final TaskType taskType;
  final int estimatedMinutes;
  final String explanation;
  final String? linkedGoalTitle;
  final String? projectTitle;
  final String? milestoneTitle;
  final DateTime? dueDate;
}

class PlanningLoadEstimate {
  const PlanningLoadEstimate({
    required this.weeklyMinutes,
    required this.routineMinutes,
    required this.taskMinutes,
    required this.summary,
  });

  final int weeklyMinutes;
  final int routineMinutes;
  final int taskMinutes;
  final String summary;
}

class PlanningWarning {
  const PlanningWarning({
    required this.message,
    required this.severity,
    required this.explanation,
  });

  final String message;
  final PlanningWarningSeverity severity;
  final String explanation;
}

class PlanningDraft {
  const PlanningDraft({
    required this.goals,
    required this.routines,
    required this.projects,
    required this.tasks,
    required this.loadEstimate,
    required this.warnings,
    required this.assumptions,
    required this.explanations,
  });

  final List<GoalDraft> goals;
  final List<RoutineDraft> routines;
  final List<ProjectDraft> projects;
  final List<TaskDraft> tasks;
  final PlanningLoadEstimate loadEstimate;
  final List<PlanningWarning> warnings;
  final List<String> assumptions;
  final List<String> explanations;

  PlanningDraft copyWith({
    List<GoalDraft>? goals,
    List<RoutineDraft>? routines,
    List<ProjectDraft>? projects,
    List<TaskDraft>? tasks,
    PlanningLoadEstimate? loadEstimate,
    List<PlanningWarning>? warnings,
    List<String>? assumptions,
    List<String>? explanations,
  }) {
    return PlanningDraft(
      goals: goals ?? this.goals,
      routines: routines ?? this.routines,
      projects: projects ?? this.projects,
      tasks: tasks ?? this.tasks,
      loadEstimate: loadEstimate ?? this.loadEstimate,
      warnings: warnings ?? this.warnings,
      assumptions: assumptions ?? this.assumptions,
      explanations: explanations ?? this.explanations,
    );
  }
}
