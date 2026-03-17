// ignore_for_file: annotate_overrides

import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../domain/sync_models.dart';
import '../domain/sync_store_contracts.dart';
import '../models/pending_sync_operation.dart';

class SyncQueueRepository implements SyncQueueStore {
  SyncQueueRepository(this._isar, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Isar _isar;
  final Uuid _uuid;

  Future<List<PendingSyncOperationRecord>> getPendingOperations() async {
    final records = await _isar.pendingSyncOperationRecords.where().findAll();
    records.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return records
        .where((item) => item.status == SyncOperationStatus.pending)
        .toList();
  }

  Future<List<PendingSyncOperationRecord>> getFailedOperations() async {
    final records = await _isar.pendingSyncOperationRecords.where().findAll();
    records.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return records
        .where((item) => item.status == SyncOperationStatus.failed)
        .toList();
  }

  Stream<List<PendingSyncOperationRecord>> watchPendingOperations() {
    return _isar.pendingSyncOperationRecords
        .watchLazy(fireImmediately: true)
        .asyncMap((_) {
          return getPendingOperations();
        });
  }

  Stream<List<PendingSyncOperationRecord>> watchAllOperations() {
    return _isar.pendingSyncOperationRecords
        .watchLazy(fireImmediately: true)
        .asyncMap((_) async {
          final records = await _isar.pendingSyncOperationRecords
              .where()
              .findAll();
          records.sort(
            (left, right) => right.createdAt.compareTo(left.createdAt),
          );
          return records;
        });
  }

  Future<int> getPendingCount() async => (await getPendingOperations()).length;

  Future<int> getFailedCount() async => (await getFailedOperations()).length;

  Future<void> enqueueUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> payload,
    required DateTime modifiedAt,
  }) async {
    await _enqueue(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payloadJson: jsonEncode(payload),
      modifiedAt: modifiedAt,
    );
  }

  Future<void> enqueueDelete({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
  }) async {
    await _enqueue(
      entityType: entityType,
      entityId: entityId,
      operationType: SyncOperationType.delete,
      payloadJson: null,
      modifiedAt: modifiedAt,
    );
  }

  Future<void> _enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required String? payloadJson,
    required DateTime modifiedAt,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.pendingSyncOperationRecords
          .filter()
          .entityTypeEqualTo(entityType)
          .and()
          .entityIdEqualTo(entityId)
          .findAll();
      if (existing.isNotEmpty) {
        await _isar.pendingSyncOperationRecords.deleteAll(
          existing.map((item) => item.isarId).toList(),
        );
      }

      await _isar.pendingSyncOperationRecords.put(
        PendingSyncOperationRecord(
          operationId: _uuid.v4(),
          entityType: entityType,
          entityId: entityId,
          operationType: operationType,
          status: SyncOperationStatus.pending,
          createdAt: DateTime.now(),
          lastModifiedAt: modifiedAt,
          payloadJson: payloadJson,
        ),
      );
    });
  }

  Future<void> markProcessing(PendingSyncOperationRecord record) async {
    record.status = SyncOperationStatus.processing;
    record.lastAttemptAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.pendingSyncOperationRecords.put(record);
    });
  }

  Future<void> markCompleted(PendingSyncOperationRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.pendingSyncOperationRecords.delete(record.isarId);
    });
  }

  Future<void> markFailed(
    PendingSyncOperationRecord record,
    String error,
  ) async {
    record.status = SyncOperationStatus.failed;
    record.retryCount += 1;
    record.lastAttemptAt = DateTime.now();
    record.lastError = error;
    await _isar.writeTxn(() async {
      await _isar.pendingSyncOperationRecords.put(record);
    });
  }

  Future<void> retryFailedOperations() async {
    final failed = await getFailedOperations();
    await _isar.writeTxn(() async {
      for (final item in failed) {
        item.status = SyncOperationStatus.pending;
        item.lastError = null;
        await _isar.pendingSyncOperationRecords.put(item);
      }
    });
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.pendingSyncOperationRecords.clear();
    });
  }
}
