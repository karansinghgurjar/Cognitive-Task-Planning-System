import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/knowledge_item.dart';

class KnowledgeRepository {
  KnowledgeRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder =
        const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<KnowledgeItem>> getAllItems() async {
    final items = await _isar.knowledgeItems.where().findAll();
    items.sort(_compareKnowledgeItems);
    return items;
  }

  Stream<List<KnowledgeItem>> watchAllItems() {
    return _isar.knowledgeItems.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllItems();
    });
  }

  Future<KnowledgeItem?> getById(String id) {
    return _isar.knowledgeItems.filter().idEqualTo(id).findFirst();
  }

  Stream<KnowledgeItem?> watchById(String id) {
    return _isar.knowledgeItems.watchLazy(fireImmediately: true).asyncMap((_) {
      return getById(id);
    });
  }

  Future<void> addItem(KnowledgeItem item) async {
    final itemToStore = item.copyWith(
      updatedAt: item.updatedAt ?? item.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.knowledgeItems.put(itemToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.knowledgeItem,
      entityId: itemToStore.id,
      entity: itemToStore,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> updateItem(KnowledgeItem item) async {
    final itemToStore = item.copyWith(
      updatedAt: item.updatedAt ?? DateTime.now(),
    );
    await _isar.writeTxn(() async {
      await _isar.knowledgeItems.put(itemToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.knowledgeItem,
      entityId: itemToStore.id,
      entity: itemToStore,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteItem(String id) async {
    final item = await _isar.knowledgeItems.filter().idEqualTo(id).findFirst();
    if (item == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.knowledgeItems.delete(item.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.knowledgeItem,
      entityId: id,
    );
  }

  Future<List<KnowledgeItem>> itemsLinkedTo(
    LinkedEntityType entityType,
    String entityId,
  ) async {
    final all = await getAllItems();
    return all.where((item) {
      return item.links.any(
        (link) => link.entityType == entityType && link.entityId == entityId,
      );
    }).toList();
  }

  Stream<List<KnowledgeItem>> watchItemsLinkedTo(
    LinkedEntityType entityType,
    String entityId,
  ) {
    return _isar.knowledgeItems.watchLazy(fireImmediately: true).asyncMap((_) {
      return itemsLinkedTo(entityType, entityId);
    });
  }

  int _compareKnowledgeItems(KnowledgeItem left, KnowledgeItem right) {
    final statusCompare = _statusRank(
      left.status,
    ).compareTo(_statusRank(right.status));
    if (statusCompare != 0) {
      return statusCompare;
    }
    final leftUpdated = left.updatedAt ?? left.createdAt;
    final rightUpdated = right.updatedAt ?? right.createdAt;
    return rightUpdated.compareTo(leftUpdated);
  }

  int _statusRank(KnowledgeStatus status) {
    switch (status) {
      case KnowledgeStatus.inbox:
        return 0;
      case KnowledgeStatus.active:
        return 1;
      case KnowledgeStatus.reviewing:
        return 2;
      case KnowledgeStatus.completed:
        return 3;
      case KnowledgeStatus.archived:
        return 4;
    }
  }
}
