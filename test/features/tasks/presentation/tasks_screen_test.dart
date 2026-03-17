import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/tasks/presentation/tasks_screen.dart';
import 'package:study_flow/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('TasksScreen shows polished empty state when no tasks exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchTasksProvider.overrideWith((ref) => Stream.value(const <Task>[])),
        ],
        child: const MaterialApp(home: Scaffold(body: TasksScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(
      find.textContaining('Add your first task'),
      findsOneWidget,
    );
  });
}
