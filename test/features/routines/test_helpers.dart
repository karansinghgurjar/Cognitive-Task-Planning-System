import 'package:study_flow/features/routines/domain/routine_repository.dart';
import 'package:study_flow/features/routines/domain/routine_sync_service.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';

class FakeRoutineRepository implements RoutineRepositoryContract {
  final Map<String, Routine> _routines = {};
  final Map<String, RoutineOccurrence> _occurrences = {};

  @override
  Future<void> archiveRoutine(String routineId) async {
    final routine = _routines[routineId];
    if (routine == null) {
      return;
    }
    _routines[routineId] = routine.copyWith(isArchived: true);
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    _routines.remove(routineId);
  }

  @override
  Future<List<Routine>> getActiveRoutines() async {
    return _routines.values.where((routine) => !routine.isArchived).toList();
  }

  @override
  Future<List<Routine>> getAllRoutines() async => _routines.values.toList();

  @override
  Future<List<RoutineOccurrence>> getOccurrencesForRoutine(
    String routineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _occurrences.values
        .where((occurrence) => occurrence.routineId == routineId)
        .toList();
  }

  @override
  Future<List<RoutineOccurrence>> getOccurrencesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _occurrences.values.toList();
  }

  @override
  Future<Routine?> getRoutineById(String id) async => _routines[id];

  @override
  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences) async {
    for (final occurrence in occurrences) {
      _occurrences[occurrence.id] = occurrence;
    }
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    _routines[routine.id] = routine;
  }

  @override
  Future<void> unarchiveRoutine(String routineId) async {
    final routine = _routines[routineId];
    if (routine == null) {
      return;
    }
    _routines[routineId] = routine.copyWith(isArchived: false);
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    _routines[routine.id] = routine;
  }
}

class FakeRoutineSyncService extends RoutineSyncService {
  FakeRoutineSyncService()
      : super(
          persistence: _NoopRoutinePersistence(),
        );

  bool syncAllCalled = false;
  bool syncRoutineCalled = false;
  String? lastRoutineId;

  @override
  Future<void> syncAllRoutines({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    syncAllCalled = true;
  }

  @override
  Future<void> syncRoutine(
    String routineId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    syncRoutineCalled = true;
    lastRoutineId = routineId;
  }
}

class _NoopRoutinePersistence implements RoutinePersistence {
  @override
  Future<List<Routine>> getAllRoutines() async => const [];

  @override
  Future<List<RoutineOccurrence>> getOccurrencesForRoutine(
    String routineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async => const [];

  @override
  Future<List<RoutineOccurrence>> getOccurrencesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async => const [];

  @override
  Future<Routine?> getRoutineById(String id) async => null;

  @override
  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences) async {}
}
