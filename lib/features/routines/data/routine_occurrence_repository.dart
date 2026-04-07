import 'package:isar/isar.dart';

import '../models/routine_occurrence.dart';

class RoutineOccurrenceRepository {
  RoutineOccurrenceRepository(this._isar);

  final Isar _isar;

  Future<List<RoutineOccurrence>> getAllOccurrences() async {
    final occurrences = await _isar.routineOccurrences.where().findAll();
    occurrences.sort(_compareOccurrences);
    return occurrences;
  }

  Stream<List<RoutineOccurrence>> watchAllOccurrences() {
    return _isar.routineOccurrences.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllOccurrences();
    });
  }

  Future<List<RoutineOccurrence>> getOccurrencesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final occurrences = await _isar.routineOccurrences
        .filter()
        .scheduledStartLessThan(end)
        .and()
        .scheduledEndGreaterThan(start)
        .findAll();
    occurrences.sort(_compareOccurrences);
    return occurrences;
  }

  Stream<List<RoutineOccurrence>> watchOccurrencesInRange(
    DateTime start,
    DateTime end,
  ) {
    return _isar.routineOccurrences.watchLazy(fireImmediately: true).asyncMap((_) {
      return getOccurrencesInRange(start, end);
    });
  }

  Future<void> updateOccurrence(RoutineOccurrence occurrence) async {
    await _isar.writeTxn(() async {
      await _isar.routineOccurrences.put(occurrence);
    });
  }

  Future<void> deleteForRoutine(String routineId) async {
    final occurrences = await _isar.routineOccurrences
        .filter()
        .routineIdEqualTo(routineId)
        .findAll();
    if (occurrences.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineOccurrences.deleteAll(
        occurrences.map((occurrence) => occurrence.isarId).toList(),
      );
    });
  }

  Future<void> replaceFutureOccurrencesInRange({
    required DateTime start,
    required DateTime end,
    required List<RoutineOccurrence> newOccurrences,
    bool keepCompleted = true,
  }) async {
    final existingOccurrences = await getOccurrencesInRange(start, end);
    final occurrencesToDelete = existingOccurrences.where((occurrence) {
      if (keepCompleted && occurrence.isCompleted) {
        return false;
      }
      return occurrence.status == RoutineOccurrenceStatus.pending ||
          occurrence.status == RoutineOccurrenceStatus.missed ||
          occurrence.status == RoutineOccurrenceStatus.cancelled;
    }).toList();

    await _isar.writeTxn(() async {
      if (occurrencesToDelete.isNotEmpty) {
        await _isar.routineOccurrences.deleteAll(
          occurrencesToDelete.map((occurrence) => occurrence.isarId).toList(),
        );
      }
      if (newOccurrences.isNotEmpty) {
        await _isar.routineOccurrences.putAll(newOccurrences);
      }
    });
  }

  int _compareOccurrences(RoutineOccurrence left, RoutineOccurrence right) {
    return left.scheduledStart.compareTo(right.scheduledStart);
  }
}
