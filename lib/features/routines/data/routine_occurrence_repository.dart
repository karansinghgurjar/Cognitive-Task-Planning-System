import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../models/routine_occurrence.dart';

class RoutineOccurrenceRepository {
  RoutineOccurrenceRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder =
        const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

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
    await _recordOccurrenceUpsert(occurrence, SyncOperationType.update);
  }

  Future<void> saveOccurrences(List<RoutineOccurrence> occurrences) async {
    if (occurrences.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineOccurrences.putAll(occurrences);
    });
    for (final occurrence in occurrences) {
      await _recordOccurrenceUpsert(occurrence, SyncOperationType.update);
    }
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
    for (final occurrence in occurrences) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.routineOccurrence,
        entityId: occurrence.id,
      );
    }
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
    for (final occurrence in occurrences) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.routineOccurrence,
        entityId: occurrence.id,
      );
    }
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
    for (final occurrence in occurrencesToDelete) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.routineOccurrence,
        entityId: occurrence.id,
      );
    }
    for (final occurrence in newOccurrences) {
      await _recordOccurrenceUpsert(occurrence, SyncOperationType.update);
    }
  }

  Future<RoutineOccurrence?> getOccurrenceById(String occurrenceId) {
    return _isar.routineOccurrences.filter().idEqualTo(occurrenceId).findFirst();
  }

  Future<int> dedupeOccurrences() async {
    final all = await _isar.routineOccurrences.where().findAll();
    final keepByLogicalKey = <String, RoutineOccurrence>{};
    final removeIds = <int>[];

    for (final occurrence in all) {
      final key = occurrence.isRecoveryInstance
          ? 'recovery:${occurrence.recoveredFromOccurrenceId ?? occurrence.id}'
          : 'standard:${occurrence.occurrenceKey}';
      final existing = keepByLogicalKey[key];
      if (existing == null) {
        keepByLogicalKey[key] = occurrence;
        continue;
      }
      final winner = _chooseOccurrenceWinner(existing, occurrence);
      final loser = identical(winner, existing) ? occurrence : existing;
      keepByLogicalKey[key] = winner;
      removeIds.add(loser.isarId);
    }

    if (removeIds.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.routineOccurrences.deleteAll(removeIds);
      });
    }
    return removeIds.length;
  }

  Future<void> _recordOccurrenceUpsert(
    RoutineOccurrence occurrence,
    SyncOperationType operationType,
  ) {
    return _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.routineOccurrence,
      entityId: occurrence.id,
      entity: occurrence,
      operationType: operationType,
    );
  }

  RoutineOccurrence _chooseOccurrenceWinner(
    RoutineOccurrence left,
    RoutineOccurrence right,
  ) {
    final statusCompare = _statusRank(right).compareTo(_statusRank(left));
    if (statusCompare > 0) {
      return right;
    }
    if (statusCompare < 0) {
      return left;
    }
    if (right.isManualOverride != left.isManualOverride) {
      return right.isManualOverride ? right : left;
    }
    final leftUpdated = left.updatedAt ?? left.createdAt;
    final rightUpdated = right.updatedAt ?? right.createdAt;
    return rightUpdated.isAfter(leftUpdated) ? right : left;
  }

  int _statusRank(RoutineOccurrence occurrence) {
    switch (occurrence.status) {
      case RoutineOccurrenceStatus.completed:
        return 4;
      case RoutineOccurrenceStatus.skipped:
        return 3;
      case RoutineOccurrenceStatus.missed:
        return 2;
      case RoutineOccurrenceStatus.pending:
        return 1;
    }
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