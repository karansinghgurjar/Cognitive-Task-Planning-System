import 'package:isar/isar.dart';

import '../domain/routine_repository.dart';
import '../domain/routine_sync_service.dart';
import '../domain/routine_date_utils.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineRepository
    implements RoutineRepositoryContract, RoutinePersistence {
  RoutineRepository(this._isar);

  final Isar _isar;

  Future<void> addRoutine(Routine routine) async {
    await saveRoutine(routine);
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    final routineToStore =
        routine.copyWith(updatedAt: routine.updatedAt ?? routine.createdAt);
    await _isar.writeTxn(() async {
      await _isar.routines.put(routineToStore);
    });
  }

  @override
  Future<void> updateRoutine(Routine routine) async {
    await _isar.writeTxn(() async {
      await _isar.routines.put(routine.copyWith(updatedAt: DateTime.now()));
    });
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final routine = await _isar.routines.filter().idEqualTo(id).findFirst();
    if (routine == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routines.delete(routine.isarId);
    });
  }

  @override
  Future<List<Routine>> getAllRoutines() async {
    final routines = await _isar.routines.where().findAll();
    routines.sort(sortRoutines);
    return routines;
  }

  @override
  Future<List<Routine>> getActiveRoutines() async {
    final routines = await getAllRoutines();
    return routines.where((routine) => routine.generatesOccurrences).toList();
  }

  @override
  Future<Routine?> getRoutineById(String id) {
    return _isar.routines.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<void> archiveRoutine(String routineId) async {
    final routine = await getRoutineById(routineId);
    if (routine == null) {
      return;
    }
    await updateRoutine(
      routine.copyWith(
        isArchived: true,
        archivedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> unarchiveRoutine(String routineId) async {
    final routine = await getRoutineById(routineId);
    if (routine == null) {
      return;
    }
    await updateRoutine(
      routine.copyWith(
        isArchived: false,
        clearArchivedAt: true,
      ),
    );
  }

  Stream<List<Routine>> watchAllRoutines() {
    return _isar.routines.watchLazy(fireImmediately: true).asyncMap((_) async {
      return getAllRoutines();
    });
  }

  Stream<List<Routine>> watchActiveRoutines() {
    return watchAllRoutines().map((routines) {
      return routines.where((routine) => routine.generatesOccurrences).toList();
    });
  }

  @override
  Future<List<RoutineOccurrence>> getOccurrencesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = normalizeDate(startDate);
    final normalizedEnd = normalizeDate(endDate);
    final occurrences = await _isar.routineOccurrences
        .filter()
        .occurrenceDateGreaterThan(normalizedStart, include: true)
        .and()
        .occurrenceDateLessThan(normalizedEnd, include: true)
        .findAll();
    occurrences.sort(_compareOccurrences);
    return occurrences;
  }

  @override
  Future<List<RoutineOccurrence>> getOccurrencesForRoutine(
    String routineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _isar.routineOccurrences.filter().routineIdEqualTo(routineId);
    if (startDate != null) {
      query = query.and().occurrenceDateGreaterThan(
        normalizeDate(startDate),
        include: true,
      );
    }
    if (endDate != null) {
      query = query.and().occurrenceDateLessThan(
        normalizeDate(endDate),
        include: true,
      );
    }
    final occurrences = await query.findAll();
    occurrences.sort(_compareOccurrences);
    return occurrences;
  }

  @override
  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences) async {
    if (occurrences.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineOccurrences.putAll(occurrences);
    });
  }
}

int sortRoutines(Routine left, Routine right) {
  if (left.generatesOccurrences != right.generatesOccurrences) {
    return left.generatesOccurrences ? -1 : 1;
  }
  if (left.isArchived != right.isArchived) {
    return left.isArchived ? 1 : -1;
  }
  final priorityCompare = left.priority.compareTo(right.priority);
  if (priorityCompare != 0) {
    return priorityCompare;
  }
  final leftUpdated = left.updatedAt ?? left.createdAt;
  final rightUpdated = right.updatedAt ?? right.createdAt;
  final updatedCompare = rightUpdated.compareTo(leftUpdated);
  if (updatedCompare != 0) {
    return updatedCompare;
  }
  return left.title.compareTo(right.title);
}

int _compareOccurrences(RoutineOccurrence left, RoutineOccurrence right) {
  final dateCompare = left.occurrenceDate.compareTo(right.occurrenceDate);
  if (dateCompare != 0) {
    return dateCompare;
  }
  final leftStart = left.scheduledStart;
  final rightStart = right.scheduledStart;
  if (leftStart != null && rightStart != null) {
    return leftStart.compareTo(rightStart);
  }
  if (leftStart == null && rightStart != null) {
    return 1;
  }
  if (leftStart != null && rightStart == null) {
    return -1;
  }
  return left.id.compareTo(right.id);
}
