import '../../tasks/models/task.dart';
import 'ai_planning_models.dart';
import 'planning_context.dart';

class DurationEstimationService {
  const DurationEstimationService();

  DurationEstimate estimateTask(
    TaskDraft task,
    PlanningContext context, {
    ParsedGoalPrompt? parsedPrompt,
  }) {
    final baseMinutes = _baseMinutesForTask(task);
    var multiplier = 1.0;
    final reasons = <String>[];

    if (parsedPrompt?.isFromScratch == true || context.isFromScratchHint) {
      multiplier += 0.35;
      reasons.add('from-scratch scope');
    }
    if (parsedPrompt?.isRevision == true || context.isRevisionHint) {
      multiplier -= 0.2;
      reasons.add('revision scope');
    }
    if (parsedPrompt?.isAdvanced == true || context.isAdvancedHint) {
      multiplier += 0.2;
      reasons.add('advanced depth');
    }

    final speedFactor = context.taskTypeSpeedFactors[task.type] ?? 1.0;
    if (speedFactor > 1.05) {
      multiplier *= speedFactor;
      reasons.add('historical pace for ${task.type.label.toLowerCase()} tasks');
    }

    if (context.longSessionMissRate >= 0.35 && baseMinutes >= 90) {
      multiplier -= 0.1;
      reasons.add('trimmed because long sessions are often missed');
    }

    switch (context.intensityPreference) {
      case PlanningIntensityPreference.conservative:
        multiplier += 0.1;
        reasons.add('conservative mode');
      case PlanningIntensityPreference.balanced:
        break;
      case PlanningIntensityPreference.aggressive:
        multiplier -= 0.05;
        reasons.add('aggressive mode');
    }

    final estimatedMinutes = _roundToNearestFive(
      (baseMinutes * multiplier).round().clamp(25, 8 * 60),
    );
    return DurationEstimate(
      taskDraftId: task.id,
      taskTitle: task.title,
      estimatedMinutes: estimatedMinutes,
      confidence: _confidenceFor(task, parsedPrompt),
      reasoning: reasons.isEmpty
          ? 'Estimated from the default ${task.type.label.toLowerCase()} task template.'
          : 'Estimated from the ${task.type.label.toLowerCase()} template, adjusted for ${reasons.join(', ')}.',
    );
  }

  List<DurationEstimate> estimateTasks(
    List<TaskDraft> tasks,
    PlanningContext context, {
    ParsedGoalPrompt? parsedPrompt,
  }) {
    return tasks
        .map((task) => estimateTask(task, context, parsedPrompt: parsedPrompt))
        .toList();
  }

  int _baseMinutesForTask(TaskDraft task) {
    if (task.estimatedMinutes > 0) {
      return task.estimatedMinutes;
    }
    switch (task.type) {
      case TaskType.study:
        return 75;
      case TaskType.coding:
        return 120;
      case TaskType.reading:
        return 45;
      case TaskType.project:
        return 150;
      case TaskType.misc:
        return 60;
    }
  }

  double _confidenceFor(TaskDraft task, ParsedGoalPrompt? parsedPrompt) {
    var confidence = 0.7;
    if (task.heuristicCategory != null) {
      confidence += 0.1;
    }
    if (parsedPrompt?.isUrgent == true) {
      confidence -= 0.05;
    }
    return confidence.clamp(0.35, 0.95);
  }

  int _roundToNearestFive(int minutes) {
    final remainder = minutes % 5;
    if (remainder == 0) {
      return minutes;
    }
    return minutes + (5 - remainder);
  }
}
