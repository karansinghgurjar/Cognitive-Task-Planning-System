import '../domain/sync_models.dart';
import '../domain/sync_store_contracts.dart';
import 'sync_entity_codec.dart';

abstract class SyncMutationRecorder {
  Future<void> recordUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required Object entity,
    required SyncOperationType operationType,
  });

  Future<void> recordDelete({
    required SyncEntityType entityType,
    required String entityId,
  });
}

class NoopSyncMutationRecorder implements SyncMutationRecorder {
  const NoopSyncMutationRecorder();

  @override
  Future<void> recordDelete({
    required SyncEntityType entityType,
    required String entityId,
  }) async {}

  @override
  Future<void> recordUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required Object entity,
    required SyncOperationType operationType,
  }) async {}
}

class LocalSyncMutationRecorder implements SyncMutationRecorder {
  LocalSyncMutationRecorder({
    required SyncQueueStore queueRepository,
    required SyncStateStore stateRepository,
    SyncEntityCodec codec = const SyncEntityCodec(),
  }) : _queueRepository = queueRepository,
       _stateRepository = stateRepository,
       _codec = codec;

  final SyncQueueStore _queueRepository;
  final SyncStateStore _stateRepository;
  final SyncEntityCodec _codec;

  @override
  Future<void> recordUpsert({
    required SyncEntityType entityType,
    required String entityId,
    required Object entity,
    required SyncOperationType operationType,
  }) async {
    final now = DateTime.now();
    final localState = await _stateRepository.getLocalState();
    await _stateRepository.recordLocalMutation(
      entityType: entityType,
      entityId: entityId,
      modifiedAt: now,
      deviceId: localState.deviceId,
    );
    await _queueRepository.enqueueUpsert(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: _codec.encodeEntity(entityType, entity),
      modifiedAt: now,
    );
  }

  @override
  Future<void> recordDelete({
    required SyncEntityType entityType,
    required String entityId,
  }) async {
    final now = DateTime.now();
    final localState = await _stateRepository.getLocalState();
    await _stateRepository.recordLocalMutation(
      entityType: entityType,
      entityId: entityId,
      modifiedAt: now,
      deviceId: localState.deviceId,
      isDeleted: true,
    );
    await _queueRepository.enqueueDelete(
      entityType: entityType,
      entityId: entityId,
      modifiedAt: now,
    );
  }
}
