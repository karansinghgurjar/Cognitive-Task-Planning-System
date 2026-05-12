import '../../domain/models/parsed_planning_intent.dart';
import '../../../goals/models/learning_goal.dart';
import '../../../routines/domain/routine_enums.dart';
import '../../../tasks/models/task.dart';

class IntentExtractionService {
  const IntentExtractionService();

  ParsedPlanningIntent extract(String rawInput) {
    final normalized = _normalize(rawInput);
    final goals = <GoalIntent>[];
    final routines = <RoutineIntent>[];
    final tasks = <TaskIntent>[];
    final constraints = <PlanningConstraint>[];
    final ambiguities = <String>[];
    final assumptions = <String>[];
    final extractedSignals = <String>{};

    final horizon = _extractHorizon(normalized);
    if (horizon != null) {
      extractedSignals.add('horizon');
    }

    final intensity = _extractIntensity(normalized);
    if (intensity != null) {
      extractedSignals.add('intensity');
    }

    constraints.addAll(_extractConstraints(normalized));
    if (constraints.isNotEmpty) {
      extractedSignals.add('constraints');
    }

    final preferredDays = _extractPreferredDays(normalized);
    final preferredTime = _extractPreferredTime(normalized);
    final explicitDuration = _extractDurationMinutes(normalized);

    final goalLike = _looksLikeGoal(normalized);
    if (goalLike) {
      final goalIntent = _buildGoalIntent(normalized, explicitDuration);
      goals.add(goalIntent);
      extractedSignals.add('goal');
    }

    if (_looksLikeRoutine(normalized) ||
        _supportsRoutineInference(normalized)) {
      routines.add(
        _buildRoutineIntent(
          normalized,
          preferredDays: preferredDays,
          preferredTime: preferredTime,
          durationMinutes: explicitDuration,
          linkedGoalTitle: goals.isEmpty ? null : goals.first.title,
        ),
      );
      extractedSignals.add('routine');
    }

    if (_looksLikeTask(normalized)) {
      tasks.add(
        TaskIntent(
          title: _taskTitleFor(normalized),
          taskType: _taskTypeFor(normalized),
          estimatedMinutes: explicitDuration ?? 60,
          linkedGoalTitle: goals.isEmpty ? null : goals.first.title,
          explanation:
              'Added because your request includes a concrete work item, not only a long-term intent.',
        ),
      );
      extractedSignals.add('task');
    }

    if (goals.isEmpty && routines.isEmpty && tasks.isEmpty) {
      ambiguities.add(
        'The request does not clearly specify a goal, routine, or concrete work item yet.',
      );
    }
    if (goalLike && _isGenericGoalRequest(normalized)) {
      ambiguities.add(
        'The request still needs a more specific planning target.',
      );
    }
    if (horizon == null && goals.isNotEmpty) {
      ambiguities.add('The goal has no clear time horizon yet.');
    }
    if (explicitDuration == null && routines.isNotEmpty) {
      assumptions.add(
        'Used a default 60-minute routine block because no duration was provided.',
      );
    }
    if (preferredTime == null && routines.isNotEmpty) {
      assumptions.add(
        'Marked routine suggestions flexible because no fixed time preference was provided.',
      );
    }
    if (preferredDays.isEmpty && routines.isNotEmpty) {
      assumptions.add(
        'Used weekdays for routine suggestions because no day preference was provided.',
      );
    }

    var confidence = 0.35;
    confidence += extractedSignals.length * 0.14;
    if (normalized.split(' ').length >= 4) {
      confidence += 0.08;
    }
    if (ambiguities.isNotEmpty) {
      confidence -= ambiguities.length * 0.08;
    }
    confidence = confidence.clamp(0.2, 0.95);

    return ParsedPlanningIntent(
      rawInput: rawInput.trim(),
      goals: goals,
      routines: routines,
      tasks: tasks,
      horizon: horizon,
      intensity: intensity,
      constraints: constraints,
      confidence: confidence,
      ambiguities: ambiguities,
      assumptions: assumptions,
    );
  }

  GoalIntent _buildGoalIntent(String normalized, int? explicitDuration) {
    final goalType = _goalTypeFor(normalized);
    return GoalIntent(
      title: _goalTitleFor(normalized),
      type: goalType,
      goalType: _goalEntityTypeFor(goalType),
      estimatedWeeklyMinutes: explicitDuration == null
          ? null
          : explicitDuration * 5,
      explanation:
          'Inferred from the outcome-oriented wording in your request.',
    );
  }

  RoutineIntent _buildRoutineIntent(
    String normalized, {
    required List<int> preferredDays,
    required int? preferredTime,
    required int? durationMinutes,
    required String? linkedGoalTitle,
  }) {
    final isFlexible = preferredTime == null || normalized.contains('flexible');
    return RoutineIntent(
      title: _routineTitleFor(normalized),
      routineType: _routineTypeFor(normalized),
      preferredDays: preferredDays,
      preferredStartMinuteOfDay: preferredTime,
      durationMinutes: durationMinutes ?? 60,
      repeatType: _repeatTypeFor(normalized, preferredDays),
      isFlexible: isFlexible,
      autoRecovery: !normalized.contains('no recovery'),
      linkedGoalTitle: linkedGoalTitle,
      explanation: isFlexible
          ? 'Marked flexible because the request did not commit to one fixed start time.'
          : 'Fixed timing was inferred from the time preference in your request.',
    );
  }

  TimeHorizon? _extractHorizon(String normalized) {
    final match = RegExp(
      r'(?:next|over the next|within)\s+(\d+)\s+(day|days|week|weeks|month|months)',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final value = int.tryParse(match.group(1) ?? '');
    final unitText = match.group(2) ?? '';
    if (value == null) {
      return null;
    }
    if (unitText.startsWith('day')) {
      return TimeHorizon(value: value, unit: TimeHorizonUnit.days);
    }
    if (unitText.startsWith('week')) {
      return TimeHorizon(value: value, unit: TimeHorizonUnit.weeks);
    }
    return TimeHorizon(value: value, unit: TimeHorizonUnit.months);
  }

  PlanningIntensityLevel? _extractIntensity(String normalized) {
    if (normalized.contains('lightly') ||
        normalized.contains('easy') ||
        normalized.contains('gentle')) {
      return PlanningIntensityLevel.light;
    }
    if (normalized.contains('aggressive') || normalized.contains('intense')) {
      return PlanningIntensityLevel.aggressive;
    }
    if (normalized.contains('consistent') ||
        normalized.contains('daily') ||
        normalized.contains('weekday')) {
      return PlanningIntensityLevel.balanced;
    }
    return null;
  }

  List<PlanningConstraint> _extractConstraints(String normalized) {
    final constraints = <PlanningConstraint>[];
    if (normalized.contains('only weekdays') ||
        normalized.contains('weekdays only')) {
      constraints.add(
        const PlanningConstraint(
          type: PlanningConstraintType.weekdaysOnly,
          value: 'weekdays',
          explanation: 'The request explicitly restricts work to weekdays.',
        ),
      );
    }
    if (normalized.contains('weekends only') ||
        normalized.contains('only weekends')) {
      constraints.add(
        const PlanningConstraint(
          type: PlanningConstraintType.weekendsOnly,
          value: 'weekends',
          explanation: 'The request explicitly restricts work to weekends.',
        ),
      );
    }
    final beforeMatch = RegExp(
      r'before\s+(\d{1,2})\s*pm',
    ).firstMatch(normalized);
    if (beforeMatch != null) {
      constraints.add(
        PlanningConstraint(
          type: PlanningConstraintType.unavailableAfter,
          value: beforeMatch.group(1)!,
          explanation:
              'The request limits work to before a specific evening cutoff.',
        ),
      );
    }
    if (normalized.contains('after office') ||
        normalized.contains('after work')) {
      constraints.add(
        const PlanningConstraint(
          type: PlanningConstraintType.availabilityContext,
          value: 'after office',
          explanation: 'The routine should fit after work hours.',
        ),
      );
    }
    if (normalized.contains('after college')) {
      constraints.add(
        const PlanningConstraint(
          type: PlanningConstraintType.availabilityContext,
          value: 'after college',
          explanation: 'The routine should fit after college hours.',
        ),
      );
    }
    return constraints;
  }

  List<int> _extractPreferredDays(String normalized) {
    if (normalized.contains('weekdays')) {
      return const <int>[
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      ];
    }
    if (normalized.contains('weekends')) {
      return const <int>[DateTime.saturday, DateTime.sunday];
    }
    if (normalized.contains('daily') || normalized.contains('every day')) {
      return const <int>[
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ];
    }
    final timesPerWeek = RegExp(
      r'(\d+)\s*x\s*/?\s*week',
    ).firstMatch(normalized);
    if (timesPerWeek != null) {
      final count = int.tryParse(timesPerWeek.group(1) ?? '') ?? 3;
      return const <int>[
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ].take(count.clamp(1, 7)).toList();
    }
    return const <int>[];
  }

  int? _extractPreferredTime(String normalized) {
    if (normalized.contains('morning')) {
      return 7 * 60;
    }
    if (normalized.contains('afternoon')) {
      return 14 * 60;
    }
    if (normalized.contains('evening')) {
      return 19 * 60;
    }
    final hourMatch = RegExp(r'(\d{1,2})\s*pm').firstMatch(normalized);
    if (hourMatch != null) {
      final hour = int.tryParse(hourMatch.group(1) ?? '');
      if (hour != null) {
        return (hour % 12 + 12) * 60;
      }
    }
    return null;
  }

  int? _extractDurationMinutes(String normalized) {
    final hourMatch = RegExp(r'(\d+(?:\.\d+)?)\s*hour').firstMatch(normalized);
    if (hourMatch != null) {
      final hours = double.tryParse(hourMatch.group(1) ?? '');
      if (hours != null) {
        return (hours * 60).round();
      }
    }
    final minuteMatch = RegExp(
      r'(\d+)\s*(?:min|mins|minute|minutes)',
    ).firstMatch(normalized);
    if (minuteMatch != null) {
      return int.tryParse(minuteMatch.group(1) ?? '');
    }
    return null;
  }

  bool _looksLikeGoal(String normalized) {
    return normalized.contains('want to') ||
        normalized.contains('prepare for') ||
        normalized.contains('improve') ||
        normalized.contains('build a') ||
        normalized.contains('need a') ||
        normalized.contains('create a') ||
        normalized.contains('help me create');
  }

  bool _looksLikeRoutine(String normalized) {
    return normalized.contains('daily') ||
        normalized.contains('weekday') ||
        normalized.contains('weekend') ||
        normalized.contains('routine') ||
        normalized.contains('every') ||
        normalized.contains('consistent');
  }

  bool _supportsRoutineInference(String normalized) {
    return normalized.contains('dsa') ||
        normalized.contains('gate') ||
        normalized.contains('placement') ||
        normalized.contains('thesis') ||
        normalized.contains('workout') ||
        normalized.contains('fitness') ||
        normalized.contains('deep work');
  }

  bool _isGenericGoalRequest(String normalized) {
    return normalized == 'i want to study more.' ||
        normalized == 'i want to study more' ||
        normalized.endsWith('study more.') ||
        normalized.endsWith('study more');
  }

  bool _looksLikeTask(String normalized) {
    return normalized.contains('track') ||
        normalized.contains('resume') ||
        normalized.contains('portfolio') ||
        normalized.contains('blind 75') ||
        normalized.contains('reading') ||
        normalized.contains('review');
  }

  GoalIntentType _goalTypeFor(String normalized) {
    if (normalized.contains('gate') ||
        normalized.contains('exam') ||
        normalized.contains('placement')) {
      return GoalIntentType.examPrep;
    }
    if (normalized.contains('workout') || normalized.contains('fitness')) {
      return GoalIntentType.fitness;
    }
    if (normalized.contains('thesis')) {
      return GoalIntentType.thesis;
    }
    if (normalized.contains('deep work')) {
      return GoalIntentType.deepWork;
    }
    if (normalized.contains('dsa') ||
        normalized.contains('coding') ||
        normalized.contains('interview')) {
      return GoalIntentType.skillBuilding;
    }
    return GoalIntentType.custom;
  }

  GoalType _goalEntityTypeFor(GoalIntentType type) {
    switch (type) {
      case GoalIntentType.examPrep:
        return GoalType.examPrep;
      case GoalIntentType.fitness:
      case GoalIntentType.deepWork:
      case GoalIntentType.skillBuilding:
      case GoalIntentType.custom:
        return GoalType.learning;
      case GoalIntentType.thesis:
        return GoalType.project;
    }
  }

  RoutineType _routineTypeFor(String normalized) {
    if (normalized.contains('workout') || normalized.contains('fitness')) {
      return RoutineType.health;
    }
    if (normalized.contains('review')) {
      return RoutineType.review;
    }
    if (normalized.contains('thesis') || normalized.contains('project')) {
      return RoutineType.project;
    }
    return RoutineType.study;
  }

  RoutineRepeatType _repeatTypeFor(String normalized, List<int> preferredDays) {
    if (normalized.contains('weekdays')) {
      return RoutineRepeatType.weekdays;
    }
    if (preferredDays.isNotEmpty &&
        preferredDays.length < 5 &&
        preferredDays.length != 7) {
      return RoutineRepeatType.selectedWeekdays;
    }
    if (normalized.contains('weekly') || normalized.contains('weekend')) {
      return RoutineRepeatType.weekly;
    }
    return RoutineRepeatType.daily;
  }

  TaskType _taskTypeFor(String normalized) {
    if (normalized.contains('read') || normalized.contains('thesis')) {
      return TaskType.reading;
    }
    if (normalized.contains('project') ||
        normalized.contains('portfolio') ||
        normalized.contains('resume')) {
      return TaskType.project;
    }
    if (normalized.contains('dsa') ||
        normalized.contains('gate') ||
        normalized.contains('study')) {
      return TaskType.study;
    }
    if (normalized.contains('coding')) {
      return TaskType.coding;
    }
    return TaskType.misc;
  }

  String _goalTitleFor(String normalized) {
    if (normalized.contains('gate')) {
      return 'GATE Preparation';
    }
    if (normalized.contains('placement')) {
      return 'Placement Preparation';
    }
    if (normalized.contains('thesis')) {
      return 'Thesis Progress';
    }
    if (normalized.contains('workout') || normalized.contains('fitness')) {
      return 'Fitness Consistency';
    }
    if (normalized.contains('deep work')) {
      return 'Deep Work System';
    }
    if (normalized.contains('dsa')) {
      return 'DSA Improvement';
    }
    return _titleize(normalized);
  }

  String _routineTitleFor(String normalized) {
    if (normalized.contains('workout') || normalized.contains('fitness')) {
      return 'Workout Block';
    }
    if (normalized.contains('thesis')) {
      return 'Thesis Work Block';
    }
    if (normalized.contains('deep work')) {
      return 'Deep Work Block';
    }
    if (normalized.contains('dsa')) {
      return 'DSA Practice';
    }
    return 'Focused Work Block';
  }

  String _taskTitleFor(String normalized) {
    if (normalized.contains('blind 75')) {
      return 'Track Blind 75 Progress';
    }
    if (normalized.contains('resume')) {
      return 'Refine Resume';
    }
    if (normalized.contains('portfolio')) {
      return 'Update Portfolio';
    }
    if (normalized.contains('reading')) {
      return 'Research Reading';
    }
    return 'Initial Planning Task';
  }

  String _normalize(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _titleize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
