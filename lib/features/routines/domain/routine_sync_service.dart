import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import 'routine_date_utils.dart';
import 'routine_generation_service.dart';

abstract class RoutinePersistence {
  Future<List<Routine>> getAllRoutines();
  Future<Routine?> getRoutineById(String id);
  Future<List<RoutineOccurrence>> getOccurrencesInRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<RoutineOccurrence>> getOccurrencesForRoutine(
    String routineId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences);
}

class RoutineSyncService {
  RoutineSyncService({
    required RoutinePersistence persistence,
    RoutineGenerationService? generationService,
  }) : _persistence = persistence,
       _generationService = generationService ?? RoutineGenerationService();

  final RoutinePersistence _persistence;
  final RoutineGenerationService _generationService;

  Future<void> syncAllRoutines({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = normalizeDate(startDate);
    final normalizedEnd = normalizeDate(endDate);
    final routines = await _persistence.getAllRoutines();
    final existing = await _persistence.getOccurrencesInRange(
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );

    final existingKeys = existing.map((item) => item.occurrenceKey).toSet();
    final toSave = <RoutineOccurrence>[];

    for (final routine in routines.where((item) => !item.isArchived)) {
      final dates = _generationService.computeOccurrenceDates(
        routine,
        startDate: normalizedStart,
        endDate: normalizedEnd,
      );
      for (final occurrence in _generationService.buildOccurrences(routine, dates)) {
        if (existingKeys.add(occurrence.occurrenceKey)) {
          toSave.add(occurrence);
        }
      }
    }

    if (toSave.isNotEmpty) {
      await _persistence.saveOccurrences(toSave);
    }
  }

  Future<void> syncRoutine(
    String routineId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = normalizeDate(startDate);
    final normalizedEnd = normalizeDate(endDate);
    final routine = await _persistence.getRoutineById(routineId);
    if (routine == null || routine.isArchived) {
      return;
    }

    final existing = await _persistence.getOccurrencesForRoutine(
      routineId,
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );
    final existingKeys = existing.map((item) => item.occurrenceKey).toSet();
    final dates = _generationService.computeOccurrenceDates(
      routine,
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );
    final toSave = _generationService
        .buildOccurrences(routine, dates)
        .where((item) => !existingKeys.contains(item.occurrenceKey))
        .toList();
    if (toSave.isNotEmpty) {
      await _persistence.saveOccurrences(toSave);
    }
  }
}
