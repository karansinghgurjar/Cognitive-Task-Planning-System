import '../../ai_planning/domain/ai_planning_models.dart';
import '../../goals/models/learning_goal.dart';
import '../../tasks/models/task.dart';
import '../models/quick_capture_item.dart';

class QuickCaptureParserService {
  const QuickCaptureParserService();

  static const _goalPhrases = [
    'learn',
    'master',
    'prepare for',
    'study for exam',
    'build',
    'complete project',
    'finish project',
    'ship',
  ];

  static const _taskPhrases = [
    'revise',
    'finish',
    'read',
    'watch',
    'solve',
    'submit',
    'update',
    'fix',
    'review',
    'complete',
    'write',
    'implement',
    'practice',
    'prepare',
    'work on',
  ];

  static const _notePhrases = [
    'idea',
    'maybe',
    'remember',
    'thought',
    'note',
    'explore',
    'consider',
  ];

  QuickCaptureSuggestedType classify(String input) {
    final normalized = _normalize(input);
    if (normalized.isEmpty) {
      return QuickCaptureSuggestedType.unknown;
    }

    final looksLikeGoalPreparation =
        normalized.contains('prepare') &&
        (normalized.contains('interview') || normalized.contains('exam'));
    if (looksLikeGoalPreparation || _matchesAnyPhrase(normalized, _goalPhrases)) {
      return QuickCaptureSuggestedType.goal;
    }
    if (_matchesAnyPhrase(normalized, _taskPhrases)) {
      return QuickCaptureSuggestedType.task;
    }
    if (_matchesAnyPhrase(normalized, _notePhrases)) {
      return QuickCaptureSuggestedType.note;
    }
    if (normalized.split(' ').length >= 4) {
      return QuickCaptureSuggestedType.note;
    }
    return QuickCaptureSuggestedType.unknown;
  }

  TaskDraft? toTaskDraft(
    String input, {
    String id = 'quick-capture-task-draft',
    DateTime? dueDate,
  }) {
    final normalized = _normalize(input);
    final classification = classify(input);
    if (normalized.isEmpty || classification == QuickCaptureSuggestedType.goal) {
      return null;
    }

    return TaskDraft(
      id: id,
      title: _titleize(input),
      description: 'Created from Quick Capture: ${input.trim()}',
      type: _inferTaskType(normalized),
      estimatedMinutes: _estimateMinutes(normalized),
      dueDate: dueDate,
      reasoning: _taskReasoning(classification),
      heuristicCategory: 'quick_capture_v1',
    );
  }

  GoalDraft? toGoalDraft(
    String input, {
    int priority = 3,
    DateTime? targetDate,
  }) {
    final normalized = _normalize(input);
    if (normalized.isEmpty || classify(input) != QuickCaptureSuggestedType.goal) {
      return null;
    }

    return GoalDraft(
      title: _titleize(input),
      description: 'Created from Quick Capture: ${input.trim()}',
      goalType: _inferGoalType(normalized),
      targetDate: targetDate,
      priority: priority,
      estimatedTotalMinutes: _estimateGoalMinutes(normalized),
      reasoning: 'Classified as a goal because it uses learning/project language and reads like a higher-level outcome.',
    );
  }

  String _normalize(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesAnyPhrase(String input, List<String> phrases) {
    return phrases.any((phrase) => input.contains(phrase));
  }

  String _titleize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  TaskType _inferTaskType(String normalized) {
    if (normalized.contains('code') ||
        normalized.contains('api') ||
        normalized.contains('sync') ||
        normalized.contains('fix') ||
        normalized.contains('implement')) {
      return TaskType.coding;
    }
    if (normalized.contains('read') || normalized.contains('paper')) {
      return TaskType.reading;
    }
    if (normalized.contains('project') || normalized.contains('submission')) {
      return TaskType.project;
    }
    if (normalized.contains('study') ||
        normalized.contains('revise') ||
        normalized.contains('prepare') ||
        normalized.contains('exam') ||
        normalized.contains('dsa') ||
        normalized.contains('java')) {
      return TaskType.study;
    }
    return TaskType.misc;
  }

  GoalType _inferGoalType(String normalized) {
    if (normalized.contains('exam') || normalized.contains('interview')) {
      return GoalType.examPrep;
    }
    if (normalized.contains('project') ||
        normalized.contains('build') ||
        normalized.contains('ship') ||
        normalized.contains('submission')) {
      return GoalType.project;
    }
    if (normalized.contains('work')) {
      return GoalType.work;
    }
    return GoalType.learning;
  }

  int _estimateMinutes(String normalized) {
    if (normalized.contains('quick') || normalized.split(' ').length <= 3) {
      return 30;
    }
    if (normalized.contains('read') || normalized.contains('review')) {
      return 45;
    }
    if (normalized.contains('fix') || normalized.contains('update')) {
      return 60;
    }
    if (normalized.contains('prepare') || normalized.contains('revise')) {
      return 90;
    }
    return 60;
  }

  int _estimateGoalMinutes(String normalized) {
    if (normalized.contains('project') || normalized.contains('build')) {
      return 600;
    }
    if (normalized.contains('interview') || normalized.contains('exam')) {
      return 900;
    }
    return 720;
  }

  String _taskReasoning(QuickCaptureSuggestedType classification) {
    switch (classification) {
      case QuickCaptureSuggestedType.task:
        return 'Classified as a task because it contains action-oriented verbs and reads like a concrete next step.';
      case QuickCaptureSuggestedType.note:
        return 'Classified as a note-like capture, but converted into a task draft because it looks actionable enough for later triage.';
      case QuickCaptureSuggestedType.unknown:
        return 'Kept as a lightweight task draft because the text is short and actionable, but classification confidence is low.';
      case QuickCaptureSuggestedType.goal:
        return 'Goal-like capture was not converted into a task draft.';
    }
  }
}
