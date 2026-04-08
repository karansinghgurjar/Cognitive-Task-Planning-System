import 'package:isar/isar.dart';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
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
    final normalizedStart = normalizeDate(start);
    final normalizedEnd = normalizeDate(end);
    final occurrences = await _isar.routineOccurrences
        .filter()
        .occurrenceDateGreaterThan(normalizedStart, include: true)
        .and()
        .occurrenceDateLessThan(normalizedEnd, include: true)
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

  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences) async {
    if (occurrences.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineOccurrences.putAll(occurrences);
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

  Future<void> deleteOccurrenceIds(List<String> occurrenceIds) async {
    if (occurrenceIds.isEmpty) {
      return;
    }
    final occurrences = await _isar.routineOccurrences
        .filter()
        .anyOf(occurrenceIds, (query, id) => query.idEqualTo(id))
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
    bool keepSkipped = true,
  }) async {
    final existingOccurrences = await getOccurrencesInRange(start, end);
    final occurrencesToDelete = existingOccurrences.where((occurrence) {
      if (keepCompleted && occurrence.isCompleted) {
        return false;
      }
      if (keepSkipped &&
          occurrence.effectiveStatus == RoutineOccurrenceStatus.skipped) {
        return false;
      }
      return occurrence.status == RoutineOccurrenceStatus.pending ||
          occurrence.status == RoutineOccurrenceStatus.missed ||
          occurrence.status == RoutineOccurrenceStatus.skipped;
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

  Future<RoutineOccurrence?> getOccurrenceById(String occurrenceId) {
    return _isar.routineOccurrences.filter().idEqualTo(occurrenceId).findFirst();
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
}
