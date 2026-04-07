import 'package:isar/isar.dart';

import '../models/routine.dart';

class RoutineRepository {
  RoutineRepository(this._isar);

  final Isar _isar;

  Future<void> addRoutine(Routine routine) async {
    final routineToStore =
        routine.copyWith(updatedAt: routine.updatedAt ?? routine.createdAt);
    await _isar.writeTxn(() async {
      await _isar.routines.put(routineToStore);
    });
  }

  Future<void> updateRoutine(Routine routine) async {
    await _isar.writeTxn(() async {
      await _isar.routines.put(routine.copyWith(updatedAt: DateTime.now()));
    });
  }

  Future<void> deleteRoutine(String id) async {
    final routine = await _isar.routines.filter().idEqualTo(id).findFirst();
    if (routine == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.routines.delete(routine.isarId);
    });
  }

  Future<List<Routine>> getAllRoutines() async {
    final routines = await _isar.routines.where().findAll();
    routines.sort(sortRoutines);
    return routines;
  }

  Future<List<Routine>> getActiveRoutines() async {
    final routines = await getAllRoutines();
    return routines.where((routine) => routine.isActive).toList();
  }

  Stream<List<Routine>> watchAllRoutines() {
    return _isar.routines.watchLazy(fireImmediately: true).asyncMap((_) async {
      return getAllRoutines();
    });
  }

  Stream<List<Routine>> watchActiveRoutines() {
    return watchAllRoutines().map((routines) {
      return routines.where((routine) => routine.isActive).toList();
    });
  }
}

int sortRoutines(Routine left, Routine right) {
  if (left.isActive != right.isActive) {
    return left.isActive ? -1 : 1;
  }
  final priorityCompare = left.priority.compareTo(right.priority);
  if (priorityCompare != 0) {
    return priorityCompare;
  }
  final leftUpdated = left.updatedAt ?? left.createdAt;
  final rightUpdated = right.updatedAt ?? right.createdAt;
  final updatedCompare = rightUpdated.compareTo(leftUpdated);
  if (updatedCompare != 0) {
    return updatedCompare;
  }
  return left.title.compareTo(right.title);
}
