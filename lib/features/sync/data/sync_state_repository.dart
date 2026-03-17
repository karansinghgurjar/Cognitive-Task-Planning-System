// ignore_for_file: annotate_overrides

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../domain/sync_models.dart';
import '../domain/sync_store_contracts.dart';
import '../models/sync_entity_metadata.dart';
import '../models/sync_local_state.dart';

class SyncStateRepository implements SyncStateStore {
  SyncStateRepository(this._isar, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  static const localStateId = 1;

  final Isar _isar;
  final Uuid _uuid;

  Future<SyncLocalState> getLocalState() async {
    final existing = await _isar.syncLocalStates.get(localStateId);
    if (existing != null) {
      return existing;
    }
    final state = SyncLocalState(id: localStateId, deviceId: _uuid.v4());
    await _isar.writeTxn(() async {
      await _isar.syncLocalStates.put(state);
    });
    return state;
  }

  Stream<SyncLocalState> watchLocalState() async* {
    yield await getLocalState();
    yield* _isar.syncLocalStates
        .watchObject(localStateId, fireImmediately: false)
        .asyncMap((value) async => value ?? getLocalState());
  }

  Future<SyncEntityMetadata?> getMetadata(
    SyncEntityType entityType,
    String entityId,
  ) {
    return _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo('${entityType.name}::$entityId')
        .findFirst();
  }

  Future<List<SyncEntityMetadata>> getConflictMetadata() async {
    final items = await _isar.syncEntityMetadatas.where().findAll();
    items.sort(
      (left, right) => right.lastModifiedAt.compareTo(left.lastModifiedAt),
    );
    return items.where((item) => item.syncState == SyncState.conflict).toList();
  }

  Stream<List<SyncEntityMetadata>> watchConflictMetadata() {
    return _isar.syncEntityMetadatas.watchLazy(fireImmediately: true).asyncMap((
      _,
    ) {
      return getConflictMetadata();
    });
  }

  Future<void> recordLocalMutation({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  }) async {
    final syncKey = '${entityType.name}::$entityId';
    final existing = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo(syncKey)
        .findFirst();
    final metadata =
        existing ??
        SyncEntityMetadata(
          syncKey: syncKey,
          entityType: entityType,
          entityId: entityId,
          lastModifiedAt: modifiedAt,
        );
    metadata.lastModifiedAt = modifiedAt;
    metadata.isDeleted = isDeleted;
    metadata.syncState = isDeleted ? SyncState.deleted : SyncState.pendingPush;
    metadata.lastModifiedByDeviceId = deviceId;
    metadata.lastError = null;
    metadata.lastConflictSummary = null;
    await _isar.writeTxn(() async {
      await _isar.syncEntityMetadatas.put(metadata);
    });
  }

  Future<void> markSynced({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime syncedAt,
    required DateTime modifiedAt,
    required String deviceId,
    bool isDeleted = false,
  }) async {
    final syncKey = '${entityType.name}::$entityId';
    final existing = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo(syncKey)
        .findFirst();
    final metadata =
        existing ??
        SyncEntityMetadata(
          syncKey: syncKey,
          entityType: entityType,
          entityId: entityId,
          lastModifiedAt: modifiedAt,
        );
    metadata.lastModifiedAt = modifiedAt;
    metadata.lastSyncedAt = syncedAt;
    metadata.isDeleted = isDeleted;
    metadata.syncState = isDeleted ? SyncState.deleted : SyncState.synced;
    metadata.lastModifiedByDeviceId = deviceId;
    metadata.lastError = null;
    metadata.lastConflictSummary = null;
    await _isar.writeTxn(() async {
      await _isar.syncEntityMetadatas.put(metadata);
    });
  }

  Future<void> markConflict({
    required SyncEntityType entityType,
    required String entityId,
    required DateTime modifiedAt,
    required String summary,
  }) async {
    final syncKey = '${entityType.name}::$entityId';
    final existing = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo(syncKey)
        .findFirst();
    final metadata =
        existing ??
        SyncEntityMetadata(
          syncKey: syncKey,
          entityType: entityType,
          entityId: entityId,
          lastModifiedAt: modifiedAt,
        );
    metadata.lastModifiedAt = modifiedAt;
    metadata.syncState = SyncState.conflict;
    metadata.lastConflictSummary = summary;
    await _isar.writeTxn(() async {
      await _isar.syncEntityMetadatas.put(metadata);
    });
  }

  Future<void> updateLocalState({
    DateTime? lastSyncAt,
    DateTime? lastPullAt,
    String? lastUserId,
    String? lastSyncError,
    bool? bootstrapPending,
    String? bootstrapMessage,
    bool clearSyncError = false,
    bool clearBootstrapMessage = false,
  }) async {
    final state = await getLocalState();
    state.lastSyncAt = lastSyncAt ?? state.lastSyncAt;
    state.lastPullAt = lastPullAt ?? state.lastPullAt;
    state.lastUserId = lastUserId ?? state.lastUserId;
    state.lastSyncError = clearSyncError
        ? null
        : lastSyncError ?? state.lastSyncError;
    state.bootstrapPending = bootstrapPending ?? state.bootstrapPending;
    state.bootstrapMessage = clearBootstrapMessage
        ? null
        : bootstrapMessage ?? state.bootstrapMessage;
    await _isar.writeTxn(() async {
      await _isar.syncLocalStates.put(state);
    });
  }

  Future<void> clearForRestore() async {
    final state = await getLocalState();
    await _isar.writeTxn(() async {
      await _isar.syncEntityMetadatas.clear();
      state.lastSyncAt = null;
      state.lastPullAt = null;
      state.lastSyncError = null;
      state.bootstrapPending = true;
      state.bootstrapMessage =
          'Backup restore changed local data. Review bootstrap sync before syncing again.';
      await _isar.syncLocalStates.put(state);
    });
  }
}
