import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/presentation/routines_screen.dart';
import 'package:study_flow/features/routines/providers/routine_providers.dart';

void main() {
  testWidgets('RoutinesScreen shows empty active state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchAllRoutinesProvider.overrideWith((ref) => Stream.value(const <Routine>[])),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No routines yet'), findsOneWidget);
  });

  testWidgets('RoutinesScreen can switch to archived tab', (tester) async {
    final routines = [
      Routine(
        id: 'active',
        title: 'Active Routine',
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      ),
      Routine(
        id: 'archived',
        title: 'Archived Routine',
        isArchived: true,
        createdAt: DateTime(2026, 4, 1),
        anchorDate: DateTime(2026, 4, 1),
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchAllRoutinesProvider.overrideWith((ref) => Stream.value(routines)),
        ],
        child: const MaterialApp(home: RoutinesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Active Routine'), findsOneWidget);
    expect(find.text('Archived Routine'), findsNothing);

    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();

    expect(find.text('Archived Routine'), findsOneWidget);
  });
}
