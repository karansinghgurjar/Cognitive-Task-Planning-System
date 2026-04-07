import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/goal_milestone.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/presentation/goal_detail_screen.dart';
import 'package:study_flow/features/goals/providers/goal_providers.dart';
import 'package:study_flow/features/recommendations/providers/recommendation_providers.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/schedule/providers/schedule_providers.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('GoalDetailScreen shows a safe message when the goal is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchGoalsProvider.overrideWith(
            (ref) => Stream.value(const <LearningGoal>[]),
          ),
          watchMilestonesForGoalProvider.overrideWith(
            (ref, goalId) => Stream.value(const <GoalMilestone>[]),
          ),
          watchTasksProvider.overrideWith((ref) => Stream.value(const <Task>[])),
          watchAllSessionsProvider.overrideWith(
            (ref) => Stream.value(const <PlannedSession>[]),
          ),
          goalFeasibilityReportProvider.overrideWith(
            (ref, goalId) => const AsyncData(null),
          ),
        ],
        child: const MaterialApp(home: GoalDetailScreen(goalId: 'missing-goal')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Goal not found'), findsOneWidget);
    expect(find.text('This goal no longer exists.'), findsOneWidget);
  });
}
