import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/sync/data/sync_mutation_recorder.dart';
import 'package:study_flow/features/sync/domain/sync_models.dart';
import 'package:study_flow/features/sync/domain/sync_store_contracts.dart';
import 'package:study_flow/features/sync/models/pending_sync_operation.dart';
import 'package:study_flow/features/sync/models/sync_entity_metadata.dart';
import 'package:study_flow/features/sync/models/sync_local_state.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  test(
    'local mutation recorder creates queued operation and tombstone state',
    () async {
      final queue = _InMemoryQueueStore();
      final state = _InMemoryStateStore();
      final recorder = LocalSyncMutationRecorder(
        queueRepository: queue,
        stateRepository: state,
      );

      final task = Task(
        id: 'task-1',
        title: 'Sync me',
        type: TaskType.study,
        estimatedDurationMinutes: 60,
        priority: 1,
        createdAt: DateTime(2026, 3, 16, 9),
      );

      await recorder.recordUpsert(
        entityType: SyncEntityType.task,
        entityId: task.id,
        entity: task,
        operationType: SyncOperationType.create,
      );

      expect(queue.pending.single.operationType, SyncOperationType.create);
      expect(state.metadata['task::task-1']?.syncState, SyncState.pendingPush);

      await recorder.recordDelete(
        entityType: SyncEntityType.task,
        entityId: task.id,
      );

      expect(queue.pending.single.operationType, SyncOperationType.delete);
      expect(state.metadata['task::task-1']?.isDeleted, isTrue);
      expect(state.metadata['task::task-1']?.syncState, SyncState.deleted);
    },
  );
}

class _InMemoryQueueStore implements SyncQueueStore {
  final List<PendingSyncOperationRecord> pending = [];

  @override
  Future<void> clearAll() async => pending.clear();

  @override
  Future<void> enqueueDelete({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
  }) async {
    pending
      ..clear()
      ..add(
        PendingSyncOperationRecord(
          operationId: 'op-delete',
          entityType: entityType,
          entityId: entityId,
          operationType: SyncOperationType.delete,
          status: SyncOperationStatus.pending,
          createdAt: modifiedAt,
          lastModifiedAt: modifiedAt,
        ),
      );
  }

  @override
  Future<void> enqueueUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> payload,
    required DateTime modifiedAt,
  }) async {
    pending
      ..clear()
      ..add(
        PendingSyncOperationRecord(
          operationId: 'op-upsert',
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
  Future<List<PendingSyncOperationRecord>> getFailedOperations() async => [];

  @override
  Future<List<PendingSyncOperationRecord>> getPendingOperations() async =>
      pending;

  @override
  Future<void> markCompleted(PendingSyncOperationRecord record) async {
    pending.remove(record);
  }

  @override
  Future<void> markFailed(
    PendingSyncOperationRecord record,
    String error,
  ) async {}

  @override
  Future<void> markProcessing(PendingSyncOperationRecord record) async {}

  @override
  Future<void> retryFailedOperations() async {}
}

class _InMemoryStateStore implements SyncStateStore {
  final SyncLocalState localState = SyncLocalState(id: 1, deviceId: 'device-1');
  final Map<String, SyncEntityMetadata> metadata = {};

  @override
  Future<void> clearForRestore() async {}

  @override
  Future<List<SyncEntityMetadata>> getConflictMetadata() async => metadata
      .values
      .where((item) => item.syncState == SyncState.conflict)
      .toList();

  @override
  Future<SyncLocalState> getLocalState() async => localState;

  @override
  Future<SyncEntityMetadata?> getMetadata(
    SyncEntityType entityType,
    String entityId,
  ) async => metadata['${entityType.name}::$entityId'];

  @override
  Future<void> markConflict({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String summary,
  }) async {}

  @override
  Future<void> markSynced({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime syncedAt,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  }) async {}

  @override
  Future<void> recordLocalMutation({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  }) async {
    metadata['${entityType.name}::$entityId'] = SyncEntityMetadata(
      syncKey: '${entityType.name}::$entityId',
      entityType: entityType,
      entityId: entityId,
      lastModifiedAt: modifiedAt,
      isDeleted: isDeleted,
      syncState: isDeleted ? SyncState.deleted : SyncState.pendingPush,
      lastModifiedByDeviceId: deviceId,
    );
  }

  @override
  Future<void> updateLocalState({
    DateTime? lastSyncAt,
    DateTime? lastPullAt,
    String? lastUserId,
    String? lastSyncError,
    bool? bootstrapPending,
    String? bootstrapMessage,
    bool clearSyncError = false,
    bool clearBootstrapMessage = false,
  }) async {}
}
