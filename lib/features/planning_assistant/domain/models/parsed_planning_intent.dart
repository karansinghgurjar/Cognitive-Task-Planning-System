import '../../../goals/models/learning_goal.dart';
import '../../../routines/domain/routine_enums.dart';
import '../../../tasks/models/task.dart';

enum PlanningIntensityLevel { light, balanced, aggressive }

enum TimeHorizonUnit { days, weeks, months }

enum PlanningConstraintType {
  preferredDays,
  preferredTime,
  unavailableDays,
  unavailableAfter,
  unavailableBefore,
  weekdaysOnly,
  weekendsOnly,
  availabilityContext,
}

enum GoalIntentType {
  examPrep,
  fitness,
  thesis,
  deepWork,
  skillBuilding,
  custom,
}

class TimeHorizon {
  const TimeHorizon({required this.value, required this.unit});

  final int value;
  final TimeHorizonUnit unit;

  int get approximateDays {
    switch (unit) {
      case TimeHorizonUnit.days:
        return value;
      case TimeHorizonUnit.weeks:
        return value * 7;
      case TimeHorizonUnit.months:
        return value * 30;
    }
  }
}

class PlanningConstraint {
  const PlanningConstraint({
    required this.type,
    required this.value,
    required this.explanation,
  });

  final PlanningConstraintType type;
  final String value;
  final String explanation;
}

class GoalIntent {
  const GoalIntent({
    required this.title,
    required this.type,
    this.goalType,
    this.estimatedWeeklyMinutes,
    this.explanation,
  });

  final String title;
  final GoalIntentType type;
  final GoalType? goalType;
  final int? estimatedWeeklyMinutes;
  final String? explanation;
}

class RoutineIntent {
  const RoutineIntent({
    required this.title,
    required this.routineType,
    this.preferredDays = const <int>[],
    this.preferredStartMinuteOfDay,
    this.durationMinutes,
    this.repeatType,
    this.isFlexible = true,
    this.autoRecovery = false,
    this.linkedGoalTitle,
    this.explanation,
  });

  final String title;
  final RoutineType routineType;
  final List<int> preferredDays;
  final int? preferredStartMinuteOfDay;
  final int? durationMinutes;
  final RoutineRepeatType? repeatType;
  final bool isFlexible;
  final bool autoRecovery;
  final String? linkedGoalTitle;
  final String? explanation;
}

class TaskIntent {
  const TaskIntent({
    required this.title,
    required this.taskType,
    this.estimatedMinutes,
    this.linkedGoalTitle,
    this.explanation,
  });

  final String title;
  final TaskType taskType;
  final int? estimatedMinutes;
  final String? linkedGoalTitle;
  final String? explanation;
}

class ParsedPlanningIntent {
  const ParsedPlanningIntent({
    required this.rawInput,
    required this.goals,
    required this.routines,
    required this.tasks,
    required this.constraints,
    required this.confidence,
    required this.ambiguities,
    required this.assumptions,
    this.horizon,
    this.intensity,
  });

  final String rawInput;
  final List<GoalIntent> goals;
  final List<RoutineIntent> routines;
  final List<TaskIntent> tasks;
  final TimeHorizon? horizon;
  final PlanningIntensityLevel? intensity;
  final List<PlanningConstraint> constraints;
  final double confidence;
  final List<String> ambiguities;
  final List<String> assumptions;

  bool get needsClarification => ambiguities.isNotEmpty || confidence < 0.7;
}
