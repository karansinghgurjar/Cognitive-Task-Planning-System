import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/tasks/presentation/task_detail_screen.dart';
import 'package:study_flow/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('TaskDetailScreen shows a safe message when the task is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchTasksProvider.overrideWith((ref) => Stream.value(const <Task>[])),
        ],
        child: const MaterialApp(home: TaskDetailScreen(taskId: 'missing-task')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This task no longer exists.'), findsOneWidget);
  });
}
