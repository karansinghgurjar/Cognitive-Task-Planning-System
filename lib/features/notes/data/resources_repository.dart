import 'package:isar/isar.dart';

import '../models/entity_note.dart';
import '../models/entity_resource.dart';

class ResourcesRepository {
  ResourcesRepository(this._isar);

  final Isar _isar;

  Future<void> addResource(EntityResource resource) async {
    final resourceToStore = resource.copyWith(
      updatedAt: resource.updatedAt ?? resource.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.entityResources.put(resourceToStore);
    });
  }

  Future<void> updateResource(EntityResource resource) async {
    await _isar.writeTxn(() async {
      await _isar.entityResources.put(
        resource.copyWith(updatedAt: DateTime.now()),
      );
    });
  }

  Future<void> deleteResource(String id) async {
    final resource = await _isar.entityResources.filter().idEqualTo(id).findFirst();
    if (resource == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.entityResources.delete(resource.isarId);
    });
  }

  Future<void> setPinned(String id, bool isPinned) async {
    final resource = await _isar.entityResources.filter().idEqualTo(id).findFirst();
    if (resource == null) {
      return;
    }
    await updateResource(resource.copyWith(isPinned: isPinned));
  }

  Future<void> deleteForEntity(
    EntityAttachmentType entityType,
    String entityId,
  ) async {
    final resources = await _isar.entityResources
        .filter()
        .entityTypeEqualTo(entityType)
        .and()
        .entityIdEqualTo(entityId)
        .findAll();
    if (resources.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.entityResources.deleteAll(
        resources.map((item) => item.isarId).toList(),
      );
    });
  }

  Future<List<EntityResource>> getAllResources() async {
    final resources = await _isar.entityResources.where().findAll();
    resources.sort(sortEntityResources);
    return resources;
  }

  Stream<List<EntityResource>> watchResourcesForEntity(
    EntityAttachmentType entityType,
    String entityId,
  ) {
    return _isar.entityResources.watchLazy(fireImmediately: true).asyncMap((
      _,
    ) async {
      final resources = await _isar.entityResources
          .filter()
          .entityTypeEqualTo(entityType)
          .and()
          .entityIdEqualTo(entityId)
          .findAll();
      resources.sort(sortEntityResources);
      return resources;
    });
  }
}

int sortEntityResources(EntityResource left, EntityResource right) {
  if (left.isPinned != right.isPinned) {
    return left.isPinned ? -1 : 1;
  }
  final leftUpdated = left.updatedAt ?? left.createdAt;
  final rightUpdated = right.updatedAt ?? right.createdAt;
  final updatedCompare = rightUpdated.compareTo(leftUpdated);
  if (updatedCompare != 0) {
    return updatedCompare;
  }
  return right.createdAt.compareTo(left.createdAt);
}
