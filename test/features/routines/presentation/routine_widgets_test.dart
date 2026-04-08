import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/routines/presentation/routine_widgets.dart';
import 'package:study_flow/features/routines/providers/routine_providers.dart';

void main() {
  testWidgets('RoutineOccurrenceCard exposes today actions for pending items', (
    tester,
  ) async {
    final routine = Routine(
      id: 'routine-1',
      title: 'Workout',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
    );
    final occurrence = RoutineOccurrence(
      id: 'occ-1',
      routineId: 'routine-1',
      occurrenceDate: DateTime(2026, 4, 9),
      scheduledStart: DateTime(2026, 4, 9, 18),
      createdAt: DateTime(2026, 4, 9, 8),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RoutineOccurrenceCard(
              item: RoutineOccurrenceItem(
                routine: routine,
                occurrence: occurrence,
                effectiveStatus: occurrence.status,
              ),
              showInlineActions: true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Snooze'), findsOneWidget);
  });
}
