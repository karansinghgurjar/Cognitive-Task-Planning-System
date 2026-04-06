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

  testWidgets('TasksScreen can switch to archived filter view', (tester) async {
    final tasks = [
      Task(
        id: 'active-1',
        title: 'Active task',
        type: TaskType.study,
        estimatedDurationMinutes: 30,
        priority: 2,
        createdAt: DateTime(2026, 1, 1),
      ),
      Task(
        id: 'archived-1',
        title: 'Archived task',
        type: TaskType.reading,
        estimatedDurationMinutes: 45,
        priority: 3,
        isArchived: true,
        createdAt: DateTime(2026, 1, 1),
        archivedAt: DateTime(2026, 1, 2),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchTasksProvider.overrideWith((ref) => Stream.value(tasks)),
        ],
        child: const MaterialApp(home: Scaffold(body: TasksScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active task'), findsOneWidget);
    expect(find.text('Archived task'), findsNothing);

    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(find.text('Archived task'), findsOneWidget);
  });
}
