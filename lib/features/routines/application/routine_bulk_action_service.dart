import '../models/routine.dart';
import '../models/routine_group.dart';

class RoutineBulkActionService {
  const RoutineBulkActionService();

  List<Routine> archiveAll(
    Iterable<Routine> routines, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return routines
        .map(
          (routine) => routine.copyWith(
            isArchived: true,
            archivedAt: timestamp,
            updatedAt: timestamp,
          ),
        )
        .toList();
  }

  List<Routine> shiftPreferredTimes(
    Iterable<Routine> routines,
    int minutes, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return routines
        .map(
          (routine) => routine.copyWith(
            preferredStartMinuteOfDay: _shift(
              routine.preferredStartMinuteOfDay,
              minutes,
            ),
            timeWindowStartMinuteOfDay: _shift(
              routine.timeWindowStartMinuteOfDay,
              minutes,
            ),
            timeWindowEndMinuteOfDay: _shift(
              routine.timeWindowEndMinuteOfDay,
              minutes,
            ),
            updatedAt: timestamp,
          ),
        )
        .toList();
  }

  List<Routine> linkGoal(
    Iterable<Routine> routines,
    String? goalId, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return routines
        .map(
          (routine) => routine.copyWith(
            linkedGoalId: goalId,
            clearLinkedGoalId: goalId == null,
            updatedAt: timestamp,
          ),
        )
        .toList();
  }

  List<Routine> linkProject(
    Iterable<Routine> routines,
    String? projectId, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return routines
        .map(
          (routine) => routine.copyWith(
            linkedProjectId: projectId,
            clearLinkedProjectId: projectId == null,
            updatedAt: timestamp,
          ),
        )
        .toList();
  }

  RoutineGroup moveToGroup(
    RoutineGroup group,
    Iterable<Routine> routines, {
    DateTime? now,
  }) {
    final merged = {...group.routineIds, ...routines.map((routine) => routine.id)}.toList()
      ..sort();
    return group.copyWith(routineIds: merged, updatedAt: now ?? DateTime.now());
  }

  int? _shift(int? minuteOfDay, int shift) {
    if (minuteOfDay == null) {
      return null;
    }
    final shifted = (minuteOfDay + shift) % 1440;
    return shifted < 0 ? shifted + 1440 : shifted;
  }
}
