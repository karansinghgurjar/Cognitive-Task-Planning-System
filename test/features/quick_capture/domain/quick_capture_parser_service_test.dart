import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/quick_capture/domain/quick_capture_parser_service.dart';
import 'package:study_flow/features/quick_capture/models/quick_capture_item.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  const service = QuickCaptureParserService();

  test('classifies higher-level learning prompt as goal', () {
    expect(
      service.classify('Learn Flutter for app development'),
      QuickCaptureSuggestedType.goal,
    );
  });

  test('classifies action-oriented prompt as task', () {
    expect(
      service.classify('Revise Java OOP'),
      QuickCaptureSuggestedType.task,
    );
  });

  test('classifies vague freeform prompt as note', () {
    expect(
      service.classify('Idea maybe explore better sync UX later'),
      QuickCaptureSuggestedType.note,
    );
  });

  test('builds task draft with inferred type and estimate', () {
    final draft = service.toTaskDraft('Fix sync conflict handling');

    expect(draft, isNotNull);
    expect(draft!.type, TaskType.coding);
    expect(draft.estimatedMinutes, 60);
    expect(draft.reasoning, contains('task'));
  });

  test('builds goal draft only for goal-like captures', () {
    final draft = service.toGoalDraft('Prepare DSA for interviews');

    expect(draft, isNotNull);
    expect(draft!.goalType, GoalType.examPrep);
    expect(draft.estimatedTotalMinutes, greaterThan(0));
    expect(draft.reasoning, contains('goal'));
    expect(service.toGoalDraft('Fix timetable overlap bug'), isNull);
  });
}
