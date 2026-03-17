import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/sync/domain/sync_models.dart';
import 'package:study_flow/features/sync/domain/sync_store_contracts.dart';
import 'package:study_flow/features/sync/models/pending_sync_operation.dart';

void main() {
  test('failed operations can be retried and return to pending', () async {
    final queue = _InMemoryQueueStore();
    await queue.enqueueUpsert(
      entityType: SyncEntityType.task,
      entityId: 'task-1',
      operationType: SyncOperationType.update,
      payload: const {'id': 'task-1'},
      modifiedAt: DateTime(2026, 3, 16, 10),
    );

    await queue.markFailed(queue.pending.single, 'offline');
    expect(queue.failed, hasLength(1));

    await queue.retryFailedOperations();
    expect(queue.pending, hasLength(1));
    expect(queue.pending.single.status, SyncOperationStatus.pending);
  });
}

class _InMemoryQueueStore implements SyncQueueStore {
  final List<PendingSyncOperationRecord> pending = [];
  final List<PendingSyncOperationRecord> failed = [];

  @override
  Future<void> clearAll() async {
    pending.clear();
    failed.clear();
  }

  @override
  Future<void> enqueueDelete({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
  }) async {}

  @override
  Future<void> enqueueUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> payload,
    required DateTime modifiedAt,
  }) async {
    pending.add(
      PendingSyncOperationRecord(
        operationId: 'op-1',
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        status: SyncOperationStatus.pending,
        createdAt: modifiedAt,
        lastModifiedAt: modifiedAt,
        payloadJson: payload.toString(),
      ),
    );
  }

  @override
  Future<List<PendingSyncOperationRecord>> getFailedOperations() async =>
      failed;

  @override
  Future<List<PendingSyncOperationRecord>> getPendingOperations() async =>
      pending;

  @override
  Future<void> markCompleted(PendingSyncOperationRecord record) async {
    pending.remove(record);
    failed.remove(record);
  }

  @override
  Future<void> markFailed(
    PendingSyncOperationRecord record,
    String error,
  ) async {
    pending.remove(record);
    record.status = SyncOperationStatus.failed;
    record.lastError = error;
    failed.add(record);
  }

  @override
  Future<void> markProcessing(PendingSyncOperationRecord record) async {}

  @override
  Future<void> retryFailedOperations() async {
    for (final item in List<PendingSyncOperationRecord>.from(failed)) {
      item.status = SyncOperationStatus.pending;
      item.lastError = null;
      pending.add(item);
    }
    failed.clear();
  }
}
