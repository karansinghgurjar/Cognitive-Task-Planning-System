import '../models/pending_sync_operation.dart';
import '../models/sync_entity_metadata.dart';
import '../models/sync_local_state.dart';
import '../models/sync_run_record.dart';
import 'sync_models.dart';

abstract class SyncQueueStore {
  Future<List<PendingSyncOperationRecord>> getPendingOperations();

  Future<List<PendingSyncOperationRecord>> getFailedOperations();

  Future<void> enqueueUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> payload,
    required DateTime modifiedAt,
  });

  Future<void> enqueueDelete({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
  });

  Future<void> markProcessing(PendingSyncOperationRecord record);

  Future<void> markCompleted(PendingSyncOperationRecord record);

  Future<void> markFailed(PendingSyncOperationRecord record, String error);

  Future<void> retryFailedOperations();

  Future<void> clearAll();
}

abstract class SyncStateStore {
  Future<SyncLocalState> getLocalState();

  Future<SyncEntityMetadata?> getMetadata(
    SyncEntityType entityType,
    String entityId,
  );

  Future<List<SyncEntityMetadata>> getConflictMetadata();

  Future<void> recordLocalMutation({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  });

  Future<void> markSynced({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime syncedAt,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  });

  Future<void> markConflict({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String summary,
  });

  Future<void> updateLocalState({
    DateTime? lastSyncAt,
    DateTime? lastPullAt,
    String? lastUserId,
    String? lastSyncError,
    bool? bootstrapPending,
    String? bootstrapMessage,
    bool clearSyncError = false,
    bool clearBootstrapMessage = false,
  });

  Future<void> clearForRestore();
}

abstract class LocalSyncStoreContract {
  Future<int> countLocalEntities();

  Future<List<SyncEntityEnvelope>> exportAllEntities({
    required String userId,
    required String deviceId,
  });

  Future<SyncEntityEnvelope?> exportEntityEnvelope({
    required SyncEntityType entityType,
    required String entityId,
    required String userId,
    required String deviceId,
  });

  Future<void> applyRemoteChanges(List<SyncEntityEnvelope> envelopes);

  Future<void> replaceAllWithRemote(List<SyncEntityEnvelope> envelopes);
}

abstract class SyncRunStore {
  Future<void> addRun(SyncRunRecord run);
}
