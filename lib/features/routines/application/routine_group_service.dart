import '../models/routine.dart';
import '../models/routine_group.dart';

class RoutineGroupService {
  const RoutineGroupService();

  RoutineGroup assignRoutines(
    RoutineGroup group,
    Iterable<String> routineIds, {
    DateTime? now,
  }) {
    final merged = {...group.routineIds, ...routineIds}.toList()..sort();
    return group.copyWith(routineIds: merged, updatedAt: now ?? DateTime.now());
  }

  RoutineGroup removeRoutines(
    RoutineGroup group,
    Iterable<String> routineIds, {
    DateTime? now,
  }) {
    final removalSet = routineIds.toSet();
    return group.copyWith(
      routineIds: group.routineIds.where((id) => !removalSet.contains(id)).toList(),
      updatedAt: now ?? DateTime.now(),
    );
  }

  List<Routine> filterRoutinesForGroup(
    RoutineGroup group,
    Iterable<Routine> routines,
  ) {
    final allowed = group.routineIds.toSet();
    return routines.where((routine) => allowed.contains(routine.id)).toList();
  }
}
