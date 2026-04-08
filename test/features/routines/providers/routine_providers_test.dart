import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/routines/providers/routine_providers.dart';

void main() {
  test('buildRoutineOccurrenceItems keeps only range items and sorts pending first', () {
    final routine = Routine(
      id: 'routine-1',
      title: 'Workout',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
    );
    final occurrences = [
      RoutineOccurrence(
        id: 'completed',
        routineId: 'routine-1',
        occurrenceDate: DateTime(2026, 4, 9),
        status: RoutineOccurrenceStatus.completed,
        createdAt: DateTime(2026, 4, 9, 7),
      ),
      RoutineOccurrence(
        id: 'pending',
        routineId: 'routine-1',
        occurrenceDate: DateTime(2026, 4, 9),
        scheduledStart: DateTime(2026, 4, 9, 18),
        createdAt: DateTime(2026, 4, 9, 7),
      ),
      RoutineOccurrence(
        id: 'outside-range',
        routineId: 'routine-1',
        occurrenceDate: DateTime(2026, 4, 10),
        createdAt: DateTime(2026, 4, 9, 7),
      ),
    ];

    final items = buildRoutineOccurrenceItems(
      routines: [routine],
      occurrences: occurrences,
      now: DateTime(2026, 4, 9, 12),
      startDate: DateTime(2026, 4, 9),
      endDate: DateTime(2026, 4, 9),
    );

    expect(items.length, 2);
    expect(items.first.occurrence.id, 'pending');
    expect(items.last.occurrence.id, 'completed');
  });

  test('groupRoutineOccurrencesByWeekday groups items for weekly rendering', () {
    final routine = Routine(
      id: 'routine-1',
      title: 'Reading',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
    );
    final items = buildRoutineOccurrenceItems(
      routines: [routine],
      occurrences: [
        RoutineOccurrence(
          id: 'mon',
          routineId: 'routine-1',
          occurrenceDate: DateTime(2026, 4, 6),
          createdAt: DateTime(2026, 4, 6, 7),
        ),
        RoutineOccurrence(
          id: 'wed',
          routineId: 'routine-1',
          occurrenceDate: DateTime(2026, 4, 8),
          createdAt: DateTime(2026, 4, 8, 7),
        ),
      ],
      now: DateTime(2026, 4, 6, 12),
      startDate: DateTime(2026, 4, 6),
      endDate: DateTime(2026, 4, 12),
    );

    final grouped = groupRoutineOccurrencesByWeekday(items);

    expect(grouped[DateTime.monday], hasLength(1));
    expect(grouped[DateTime.wednesday], hasLength(1));
  });
}
