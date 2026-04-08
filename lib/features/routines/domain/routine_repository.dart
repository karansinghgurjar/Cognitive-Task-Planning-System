import '../models/routine.dart';
import '../models/routine_occurrence.dart';

abstract class RoutineRepositoryContract {
  Future<List<Routine>> getAllRoutines();
  Future<List<Routine>> getActiveRoutines();
  Future<Routine?> getRoutineById(String id);

  Future<void> saveRoutine(Routine routine);
  Future<void> updateRoutine(Routine routine);
  Future<void> archiveRoutine(String routineId);
  Future<void> unarchiveRoutine(String routineId);
  Future<void> deleteRoutine(String routineId);

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
