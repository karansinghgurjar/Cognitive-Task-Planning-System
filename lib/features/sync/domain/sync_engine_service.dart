import '../data/auth_sync_service.dart';
import '../data/remote_sync_repository.dart';
import '../data/sync_entity_codec.dart';
import '../models/pending_sync_operation.dart';
import '../models/sync_run_record.dart';
import 'bootstrap_sync_service.dart';
import 'conflict_resolution_service.dart';
import 'sync_models.dart';
import 'sync_store_contracts.dart';

class SyncEngineService {
  SyncEngineService({
    required AuthSyncService authService,
    required SyncQueueStore queueRepository,
    required SyncStateStore stateRepository,
    required LocalSyncStoreContract localSyncStore,
    required RemoteSyncRepository remoteSyncRepository,
    required SyncRunStore syncRunRepository,
    required ConflictResolutionService conflictResolutionService,
    required BootstrapSyncService bootstrapSyncService,
    SyncEntityCodec codec = const SyncEntityCodec(),
    required Future<bool> Function() isOnline,
  }) : _authService = authService,
       _queueRepository = queueRepository,
       _stateRepository = stateRepository,
       _localSyncStore = localSyncStore,
       _remoteSyncRepository = remoteSyncRepository,
       _syncRunRepository = syncRunRepository,
       _conflictResolutionService = conflictResolutionService,
       _bootstrapSyncService = bootstrapSyncService,
       _codec = codec,
       _isOnline = isOnline;

  final AuthSyncService _authService;
  final SyncQueueStore _queueRepository;
  final SyncStateStore _stateRepository;
  final LocalSyncStoreContract _localSyncStore;
  final RemoteSyncRepository _remoteSyncRepository;
  final SyncRunStore _syncRunRepository;
  final ConflictResolutionService _conflictResolutionService;
  final BootstrapSyncService _bootstrapSyncService;
  final SyncEntityCodec _codec;
  final Future<bool> Function() _isOnline;

  Future<SyncResult> syncNow() async {
    final startedAt = DateTime.now();
    final account = _authService.getCurrentAccount();
    if (!account.isConfigured ||
        !account.isSignedIn ||
        account.userId == null) {
      return _finish(
        SyncResult(startedAt: startedAt, finishedAt: DateTime.now()),
        record: false,
      );
    }

    if (!await _isOnline()) {
      return _finish(
        SyncResult(
          startedAt: startedAt,
          finishedAt: DateTime.now(),
          wasOffline: true,
        ),
      );
    }

    final bootstrapPlan = await prepareBootstrapPlan();
    if (bootstrapPlan.requirement == BootstrapRequirement.choose) {
      await _stateRepository.updateLocalState(
        bootstrapPending: true,
        bootstrapMessage: bootstrapPlan.message,
        lastUserId: account.userId,
      );
      return _finish(
        SyncResult(
          startedAt: startedAt,
          finishedAt: DateTime.now(),
          requiredBootstrap: true,
          errors: [bootstrapPlan.message ?? 'Bootstrap decision required.'],
        ),
      );
    }
    if (bootstrapPlan.requirement == BootstrapRequirement.uploadLocal) {
      await applyBootstrapChoice(BootstrapChoice.uploadLocal);
    } else if (bootstrapPlan.requirement ==
        BootstrapRequirement.downloadRemote) {
      await applyBootstrapChoice(BootstrapChoice.downloadRemote);
    }

    final pushResult = await pushPendingChanges();
    final pullResult = await pullRemoteChanges();

    final combined = SyncResult(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      failedCount: pushResult.failedCount + pullResult.failedCount,
      conflicts: [...pushResult.conflicts, ...pullResult.conflicts],
      errors: [...pushResult.errors, ...pullResult.errors],
      wasOffline: pushResult.wasOffline || pullResult.wasOffline,
    );
    await _stateRepository.updateLocalState(
      lastSyncAt: combined.finishedAt,
      lastUserId: account.userId,
      lastSyncError: combined.errors.isEmpty
          ? null
          : combined.errors.join('\n'),
      clearSyncError: combined.errors.isEmpty,
      bootstrapPending: false,
      clearBootstrapMessage: true,
    );
    return _finish(combined);
  }

  Future<BootstrapPlan> prepareBootstrapPlan() async {
    final account = _authService.getCurrentAccount();
    if (!account.isSignedIn ||
        account.userId == null ||
        !_remoteSyncRepository.isConfigured) {
      return const BootstrapPlan(
        requirement: BootstrapRequirement.none,
        localEntityCount: 0,
        remoteEntityCount: 0,
      );
    }
    final localState = await _stateRepository.getLocalState();
    final localCount = await _localSyncStore.countLocalEntities();
    final remoteCount = await _remoteSyncRepository.countRemoteEntities(
      account.userId!,
    );
    return _bootstrapSyncService.evaluate(
      localEntityCount: localCount,
      remoteEntityCount: remoteCount,
      hasPreviousSync:
          localState.lastUserId == account.userId &&
          localState.lastSyncAt != null,
    );
  }

  Future<SyncResult> applyBootstrapChoice(BootstrapChoice choice) async {
    final startedAt = DateTime.now();
    final account = _authService.getCurrentAccount();
    if (!account.isSignedIn || account.userId == null) {
      throw StateError('Sign in before bootstrapping sync.');
    }
    if (!await _isOnline()) {
      return _finish(
        SyncResult(
          startedAt: startedAt,
          finishedAt: DateTime.now(),
          wasOffline: true,
        ),
      );
    }

    final localState = await _stateRepository.getLocalState();
    switch (choice) {
      case BootstrapChoice.uploadLocal:
        final entities = await _localSyncStore.exportAllEntities(
          userId: account.userId!,
          deviceId: localState.deviceId,
        );
        await _remoteSyncRepository.replaceAll(
          userId: account.userId!,
          entities: entities,
        );
        await _stateRepository.updateLocalState(
          lastSyncAt: DateTime.now(),
          lastPullAt: DateTime.now(),
          lastUserId: account.userId,
          bootstrapPending: false,
          clearBootstrapMessage: true,
          clearSyncError: true,
        );
        return _finish(
          SyncResult(
            startedAt: startedAt,
            finishedAt: DateTime.now(),
            pushedCount: entities.length,
          ),
        );
      case BootstrapChoice.downloadRemote:
        final remote = await _remoteSyncRepository.pullChanges(
          userId: account.userId!,
        );
        await _localSyncStore.replaceAllWithRemote(remote);
        await _queueRepository.clearAll();
        await _stateRepository.updateLocalState(
          lastSyncAt: DateTime.now(),
          lastPullAt: DateTime.now(),
          lastUserId: account.userId,
          bootstrapPending: false,
          clearBootstrapMessage: true,
          clearSyncError: true,
        );
        return _finish(
          SyncResult(
            startedAt: startedAt,
            finishedAt: DateTime.now(),
            pulledCount: remote.length,
          ),
        );
      case BootstrapChoice.merge:
        final localEntities = await _localSyncStore.exportAllEntities(
          userId: account.userId!,
          deviceId: localState.deviceId,
        );
        await _remoteSyncRepository.pushChanges(localEntities);
        await _stateRepository.updateLocalState(
          lastUserId: account.userId,
          bootstrapPending: false,
          clearBootstrapMessage: true,
        );
        final result = await pullRemoteChanges();
        return _finish(
          SyncResult(
            startedAt: startedAt,
            finishedAt: DateTime.now(),
            pushedCount: localEntities.length,
            pulledCount: result.pulledCount,
            conflicts: result.conflicts,
            failedCount: result.failedCount,
            errors: result.errors,
          ),
        );
    }
  }

  Future<SyncResult> pushPendingChanges() async {
    final startedAt = DateTime.now();
    final account = _authService.getCurrentAccount();
    if (!account.isSignedIn || account.userId == null) {
      return SyncResult(startedAt: startedAt, finishedAt: DateTime.now());
    }
    if (!await _isOnline()) {
      return SyncResult(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        wasOffline: true,
      );
    }

    final localState = await _stateRepository.getLocalState();
    final operations = await _queueRepository.getPendingOperations();
    var pushedCount = 0;
    var failedCount = 0;
    final errors = <String>[];

    for (final operation in operations) {
      await _queueRepository.markProcessing(operation);
      try {
        final envelope = _operationToEnvelope(
          operation,
          userId: account.userId!,
          deviceId: localState.deviceId,
        );
        if (envelope == null) {
          await _queueRepository.markCompleted(operation);
          continue;
        }
        await _remoteSyncRepository.pushChanges([envelope]);
        await _stateRepository.markSynced(
          entityType: operation.entityType,
          entityId: operation.entityId,
          syncedAt: DateTime.now(),
          modifiedAt: operation.lastModifiedAt,
          deviceId: localState.deviceId,
          isDeleted: operation.operationType == SyncOperationType.delete,
        );
        await _queueRepository.markCompleted(operation);
        pushedCount += 1;
      } catch (error) {
        failedCount += 1;
        errors.add(error.toString());
        await _queueRepository.markFailed(operation, error.toString());
      }
    }

    return SyncResult(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      pushedCount: pushedCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  Future<SyncResult> pullRemoteChanges() async {
    final startedAt = DateTime.now();
    final account = _authService.getCurrentAccount();
    if (!account.isSignedIn || account.userId == null) {
      return SyncResult(startedAt: startedAt, finishedAt: DateTime.now());
    }
    if (!await _isOnline()) {
      return SyncResult(
        startedAt: startedAt,
        finishedAt: DateTime.now(),
        wasOffline: true,
      );
    }

    final localState = await _stateRepository.getLocalState();
    final remoteChanges = await _remoteSyncRepository.pullChanges(
      userId: account.userId!,
      since: localState.lastPullAt,
    );
    final conflicts = <SyncConflict>[];
    final applyRemote = <SyncEntityEnvelope>[];

    for (final remoteChange in remoteChanges) {
      final metadata = await _stateRepository.getMetadata(
        remoteChange.entityType,
        remoteChange.entityId,
      );
      final conflict = _conflictResolutionService.detectConflict(
        remoteEnvelope: remoteChange,
        localMetadata: metadata,
      );
      if (conflict == null) {
        applyRemote.add(remoteChange);
        continue;
      }

      conflicts.add(conflict);
      await _stateRepository.markConflict(
        entityType: remoteChange.entityType,
        entityId: remoteChange.entityId,
        modifiedAt: remoteChange.lastModifiedAt,
        summary: conflict.description,
      );
      if (conflict.resolution == SyncConflictResolution.useRemote) {
        applyRemote.add(remoteChange);
      } else {
        final localWinner = await _localSyncStore.exportEntityEnvelope(
          entityType: remoteChange.entityType,
          entityId: remoteChange.entityId,
          userId: account.userId!,
          deviceId: localState.deviceId,
        );
        if (localWinner != null) {
          await _remoteSyncRepository.pushChanges([localWinner]);
          await _stateRepository.markSynced(
            entityType: localWinner.entityType,
            entityId: localWinner.entityId,
            syncedAt: DateTime.now(),
            modifiedAt: localWinner.lastModifiedAt,
            deviceId: localState.deviceId,
            isDeleted: localWinner.isDeleted,
          );
        }
      }
    }

    await applyRemoteChanges(applyRemote);
    final maxPulledAt = remoteChanges.isEmpty
        ? localState.lastPullAt
        : remoteChanges
              .map((item) => item.lastModifiedAt)
              .reduce((left, right) => left.isAfter(right) ? left : right);
    await _stateRepository.updateLocalState(
      lastPullAt: maxPulledAt,
      lastUserId: account.userId,
      clearSyncError: true,
    );

    return SyncResult(
      startedAt: startedAt,
      finishedAt: DateTime.now(),
      pulledCount: applyRemote.length,
      conflicts: conflicts,
    );
  }

  Future<void> applyRemoteChanges(List<SyncEntityEnvelope> changes) async {
    await _localSyncStore.applyRemoteChanges(changes);
  }

  Future<SyncResult> retryFailedChanges() async {
    await _queueRepository.retryFailedOperations();
    return syncNow();
  }

  SyncEntityEnvelope? _operationToEnvelope(
    PendingSyncOperationRecord operation, {
    required String userId,
    required String deviceId,
  }) {
    if (operation.operationType == SyncOperationType.delete) {
      return SyncEntityEnvelope(
        entityType: operation.entityType,
        entityId: operation.entityId,
        userId: userId,
        data: null,
        isDeleted: true,
        lastModifiedAt: operation.lastModifiedAt,
        lastModifiedByDeviceId: deviceId,
      );
    }

    final payload = _codec.decodePayloadJson(operation.payloadJson);
    if (payload == null) {
      return null;
    }
    return SyncEntityEnvelope(
      entityType: operation.entityType,
      entityId: operation.entityId,
      userId: userId,
      data: payload,
      lastModifiedAt: operation.lastModifiedAt,
      lastModifiedByDeviceId: deviceId,
    );
  }

  Future<SyncResult> _finish(SyncResult result, {bool record = true}) async {
    if (record) {
      await _syncRunRepository.addRun(
        SyncRunRecord(
          startedAt: result.startedAt,
          finishedAt: result.finishedAt,
          status: result.success ? SyncRunStatus.success : SyncRunStatus.failed,
          pushedCount: result.pushedCount,
          pulledCount: result.pulledCount,
          conflictCount: result.conflicts.length,
          errorSummary: result.errors.isEmpty ? null : result.errors.join('\n'),
        ),
      );
    }
    return result;
  }
}
