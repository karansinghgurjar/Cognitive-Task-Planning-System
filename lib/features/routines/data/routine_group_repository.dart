import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/routine_group.dart';

class RoutineGroupRepository {
  RoutineGroupRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder =
        const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<RoutineGroup>> getAllGroups() async {
    final groups = await _isar.routineGroups.where().findAll();
    groups.sort((left, right) => left.name.compareTo(right.name));
    return groups;
  }

  Future<RoutineGroup?> getById(String id) {
    return _isar.routineGroups.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveGroup(RoutineGroup group) async {
    final groupToStore = group.copyWith(
      updatedAt: group.updatedAt ?? group.createdAt,
    );
    await _isar.writeTxn(() async {
      await _isar.routineGroups.put(groupToStore);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.routineGroup,
      entityId: groupToStore.id,
      entity: groupToStore,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteGroup(String id) async {
    final group = await getById(id);
    if (group == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineGroups.delete(group.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.routineGroup,
      entityId: id,
    );
  }

  Stream<List<RoutineGroup>> watchGroups() {
    return _isar.routineGroups.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllGroups();
    });
  }
}