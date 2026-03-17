import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/sync/data/auth_sync_service.dart';
import 'package:study_flow/features/sync/data/remote_sync_repository.dart';
import 'package:study_flow/features/sync/data/sync_entity_codec.dart';
import 'package:study_flow/features/sync/domain/bootstrap_sync_service.dart';
import 'package:study_flow/features/sync/domain/conflict_resolution_service.dart';
import 'package:study_flow/features/sync/domain/sync_engine_service.dart';
import 'package:study_flow/features/sync/domain/sync_models.dart';
import 'package:study_flow/features/sync/domain/sync_store_contracts.dart';
import 'package:study_flow/features/sync/models/pending_sync_operation.dart';
import 'package:study_flow/features/sync/models/sync_entity_metadata.dart';
import 'package:study_flow/features/sync/models/sync_local_state.dart';
import 'package:study_flow/features/sync/models/sync_run_record.dart';

void main() {
  test(
    'sync engine applies pulled remote changes including tombstones',
    () async {
      final localStore = _InMemoryLocalSyncStore();
      final queue = _InMemoryQueueStore();
      final state = _InMemoryStateStore();
      final remote = _FakeRemoteSyncRepository(
        pulledChanges: [
          SyncEntityEnvelope(
            entityType: SyncEntityType.task,
            entityId: 'task-1',
            userId: 'user-1',
            data: const {'id': 'task-1'},
            lastModifiedAt: DateTime(2026, 3, 16, 12),
            lastModifiedByDeviceId: 'remote-device',
          ),
          SyncEntityEnvelope(
            entityType: SyncEntityType.task,
            entityId: 'task-2',
            userId: 'user-1',
            data: null,
            isDeleted: true,
            lastModifiedAt: DateTime(2026, 3, 16, 13),
            lastModifiedByDeviceId: 'remote-device',
          ),
        ],
      );
      final engine = SyncEngineService(
        authService: _FakeAuthSyncService(),
        queueRepository: queue,
        stateRepository: state,
        localSyncStore: localStore,
        remoteSyncRepository: remote,
        syncRunRepository: _InMemoryRunStore(),
        conflictResolutionService: const ConflictResolutionService(),
        bootstrapSyncService: const BootstrapSyncService(),
        codec: const SyncEntityCodec(),
        isOnline: () async => true,
      );

      final result = await engine.pullRemoteChanges();

      expect(result.pulledCount, 2);
      expect(localStore.appliedChanges, hasLength(2));
      expect(localStore.appliedChanges.last.isDeleted, isTrue);
    },
  );
}

class _FakeAuthSyncService extends AuthSyncService {
  @override
  SyncAccountSummary getCurrentAccount() {
    return const SyncAccountSummary(
      isConfigured: true,
      isSignedIn: true,
      userId: 'user-1',
      email: 'sync@example.com',
    );
  }
}

class _FakeRemoteSyncRepository implements RemoteSyncRepository {
  _FakeRemoteSyncRepository({required this.pulledChanges});

  final List<SyncEntityEnvelope> pulledChanges;

  @override
  bool get isConfigured => true;

  @override
  Future<int> countRemoteEntities(String userId) async => pulledChanges.length;

  @override
  Future<List<SyncEntityEnvelope>> pullChanges({
    required String userId,
    DateTime? since,
  }) async => pulledChanges;

  @override
  Future<void> pushChanges(List<SyncEntityEnvelope> changes) async {}

  @override
  Future<void> replaceAll({
    required String userId,
    required List<SyncEntityEnvelope> entities,
  }) async {}
}

class _InMemoryQueueStore implements SyncQueueStore {
  @override
  Future<void> clearAll() async {}

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
  }) async {}

  @override
  Future<List<PendingSyncOperationRecord>> getFailedOperations() async =>
      const [];

  @override
  Future<List<PendingSyncOperationRecord>> getPendingOperations() async =>
      const [];

  @override
  Future<void> markCompleted(PendingSyncOperationRecord record) async {}

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

  @override
  Future<void> clearForRestore() async {}

  @override
  Future<List<SyncEntityMetadata>> getConflictMetadata() async => const [];

  @override
  Future<SyncLocalState> getLocalState() async => localState;

  @override
  Future<SyncEntityMetadata?> getMetadata(
    SyncEntityType entityType,
    String entityId,
  ) async => null;

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
  }) async {}

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

class _InMemoryLocalSyncStore implements LocalSyncStoreContract {
  final List<SyncEntityEnvelope> appliedChanges = [];

  @override
  Future<void> applyRemoteChanges(List<SyncEntityEnvelope> envelopes) async {
    appliedChanges.addAll(envelopes);
  }

  @override
  Future<int> countLocalEntities() async => 0;

  @override
  Future<SyncEntityEnvelope?> exportEntityEnvelope({
    required SyncEntityType entityType,
    required String entityId,
    required String userId,
    required String deviceId,
  }) async => null;

  @override
  Future<List<SyncEntityEnvelope>> exportAllEntities({
    required String userId,
    required String deviceId,
  }) async => const [];

  @override
  Future<void> replaceAllWithRemote(List<SyncEntityEnvelope> envelopes) async {
    appliedChanges
      ..clear()
      ..addAll(envelopes);
  }
}

class _InMemoryRunStore implements SyncRunStore {
  @override
  Future<void> addRun(SyncRunRecord run) async {}
}
