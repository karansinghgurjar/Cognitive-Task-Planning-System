import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/application/routine_occurrence_controller.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_generation_service.dart';
import 'package:study_flow/features/routines/domain/routine_scheduling_service.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';

void main() {
  test('complete occurrence sets completed status and timestamp', () async {
    RoutineOccurrence? stored = RoutineOccurrence(
      id: 'occ-1',
      routineId: 'routine-1',
      occurrenceDate: DateTime(2026, 4, 9),
      createdAt: DateTime(2026, 4, 9, 8),
    );

    final controller = RoutineOccurrenceController(
      loadOccurrenceById: (_) async => stored,
      updateOccurrence: (occurrence) async => stored = occurrence,
      schedulingService: RoutineSchedulingService(
        generationService: RoutineGenerationService(),
      ),
      nowProvider: () => DateTime(2026, 4, 9, 10),
    );

    await controller.completeOccurrence('occ-1');

    expect(stored!.status, RoutineOccurrenceStatus.completed);
    expect(stored!.completedAt, DateTime(2026, 4, 9, 10));
  });

  test('skip occurrence is safe on completed items', () async {
    RoutineOccurrence? stored = RoutineOccurrence(
      id: 'occ-1',
      routineId: 'routine-1',
      occurrenceDate: DateTime(2026, 4, 9),
      status: RoutineOccurrenceStatus.completed,
      createdAt: DateTime(2026, 4, 9, 8),
      completedAt: DateTime(2026, 4, 9, 9),
    );

    final controller = RoutineOccurrenceController(
      loadOccurrenceById: (_) async => stored,
      updateOccurrence: (occurrence) async => stored = occurrence,
      schedulingService: RoutineSchedulingService(
        generationService: RoutineGenerationService(),
      ),
      nowProvider: () => DateTime(2026, 4, 9, 10),
    );

    await controller.skipOccurrence('occ-1');

    expect(stored!.status, RoutineOccurrenceStatus.completed);
    expect(stored!.completedAt, DateTime(2026, 4, 9, 9));
  });

  test('snooze updates scheduled time conservatively', () async {
    RoutineOccurrence? stored = RoutineOccurrence(
      id: 'occ-1',
      routineId: 'routine-1',
      occurrenceDate: DateTime(2026, 4, 9),
      scheduledStart: DateTime(2026, 4, 9, 18),
      scheduledEnd: DateTime(2026, 4, 9, 19),
      createdAt: DateTime(2026, 4, 9, 8),
    );

    final controller = RoutineOccurrenceController(
      loadOccurrenceById: (_) async => stored,
      updateOccurrence: (occurrence) async => stored = occurrence,
      schedulingService: RoutineSchedulingService(
        generationService: RoutineGenerationService(),
      ),
      nowProvider: () => DateTime(2026, 4, 9, 10),
    );

    await controller.snoozeOccurrence(
      'occ-1',
      DateTime(2026, 4, 9, 18, 30),
      notes: 'Snoozed',
    );

    expect(stored!.scheduledStart, DateTime(2026, 4, 9, 18, 30));
    expect(stored!.scheduledEnd, DateTime(2026, 4, 9, 19, 30));
    expect(stored!.status, RoutineOccurrenceStatus.pending);
  });
}
