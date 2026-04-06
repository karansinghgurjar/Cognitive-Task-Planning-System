import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/goals/presentation/goals_screen.dart';
import 'package:study_flow/features/goals/providers/goal_providers.dart';
import 'package:study_flow/features/quick_capture/providers/quick_capture_providers.dart';

void main() {
  testWidgets('GoalsScreen shows first-use empty state when no goals exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchGoalsProvider.overrideWith(
            (ref) => Stream.value(const <LearningGoal>[]),
          ),
          unprocessedCaptureCountProvider.overrideWith((ref) {
            return const AsyncData(0);
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: GoalsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No goals yet'), findsOneWidget);
    expect(find.textContaining('generate a plan'), findsOneWidget);
  });
}
