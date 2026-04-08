import 'package:isar/isar.dart';

import '../models/routine_group.dart';

class RoutineGroupRepository {
  RoutineGroupRepository(this._isar);

  final Isar _isar;

  Future<List<RoutineGroup>> getAllGroups() async {
    final groups = await _isar.routineGroups.where().findAll();
    groups.sort((left, right) => left.name.compareTo(right.name));
    return groups;
  }

  Future<RoutineGroup?> getById(String id) {
    return _isar.routineGroups.filter().idEqualTo(id).findFirst();
  }

  Future<void> saveGroup(RoutineGroup group) async {
    await _isar.writeTxn(() async {
      await _isar.routineGroups.put(group);
    });
  }

  Future<void> deleteGroup(String id) async {
    final group = await getById(id);
    if (group == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routineGroups.delete(group.isarId);
    });
  }

  Stream<List<RoutineGroup>> watchGroups() {
    return _isar.routineGroups.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllGroups();
    });
  }
}
