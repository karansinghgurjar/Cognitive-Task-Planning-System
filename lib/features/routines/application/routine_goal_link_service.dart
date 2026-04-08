import '../../goals/models/learning_goal.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineGoalContribution {
  const RoutineGoalContribution({
    required this.goalId,
    required this.completedOccurrenceCount,
    required this.completedMinutes,
  });

  final String goalId;
  final int completedOccurrenceCount;
  final int completedMinutes;
}

class RoutineGoalLinkService {
  const RoutineGoalLinkService();

  RoutineGoalContribution? contributionForGoal({
    required LearningGoal goal,
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
  }) {
    final linkedRoutines = routines
        .where((routine) => routine.linkedGoalId == goal.id)
        .toList();
    if (linkedRoutines.isEmpty) {
      return null;
    }

    final routineById = {for (final routine in linkedRoutines) routine.id: routine};
    var completedCount = 0;
    var completedMinutes = 0;

    for (final occurrence in occurrences) {
      final routine = routineById[occurrence.routineId];
      if (routine == null || occurrence.status != RoutineOccurrenceStatus.completed) {
        continue;
      }
      completedCount += 1;
      completedMinutes +=
          occurrence.durationMinutes ?? routine.preferredDurationMinutes ?? 0;
    }

    return RoutineGoalContribution(
      goalId: goal.id,
      completedOccurrenceCount: completedCount,
      completedMinutes: completedMinutes,
    );
  }
}
