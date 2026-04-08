import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutinePlanningSummary {
  const RoutinePlanningSummary({
    required this.scheduledRoutineCount,
    required this.flexibleNeedsPlacementCount,
    required this.recoverableMissedCount,
    required this.consistencyCount,
    required this.totalPlannedMinutes,
  });

  final int scheduledRoutineCount;
  final int flexibleNeedsPlacementCount;
  final int recoverableMissedCount;
  final int consistencyCount;
  final int totalPlannedMinutes;
}

class RoutineOrchestrationService {
  const RoutineOrchestrationService();

  RoutinePlanningSummary summarizeDaily({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    return _summarizeRange(
      routines: routines,
      occurrences: occurrences,
      now: now,
      startDate: today,
      endDate: today,
    );
  }

  RoutinePlanningSummary summarizeWeekly({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
  }) {
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endDate = startDate.add(const Duration(days: 6));
    return _summarizeRange(
      routines: routines,
      occurrences: occurrences,
      now: now,
      startDate: startDate,
      endDate: endDate,
    );
  }

  RoutinePlanningSummary _summarizeRange({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final routineById = {for (final routine in routines) routine.id: routine};
    final inRange = occurrences.where((occurrence) {
      return !occurrence.occurrenceDate.isBefore(startDate) &&
          !occurrence.occurrenceDate.isAfter(endDate);
    }).toList();
    final scheduledRoutineCount = inRange
        .where((occurrence) => occurrence.scheduledStart != null)
        .length;
    final flexibleNeedsPlacementCount = inRange.where((occurrence) {
      final routine = routineById[occurrence.routineId];
      return occurrence.needsAttention && (routine?.isFlexible ?? false);
    }).length;
    final recoverableMissedCount = inRange.where((occurrence) {
      if (occurrence.effectiveStatusAt(now) != RoutineOccurrenceStatus.missed) {
        return false;
      }
      return occurrence.recoveryDismissedAt == null;
    }).length;
    final consistencyCount = inRange.where((occurrence) {
      final routine = routineById[occurrence.routineId];
      return routine?.countsTowardConsistency ?? false;
    }).length;
    final totalPlannedMinutes = inRange.fold<int>(0, (sum, occurrence) {
      return sum + (occurrence.durationMinutes ?? 0);
    });
    return RoutinePlanningSummary(
      scheduledRoutineCount: scheduledRoutineCount,
      flexibleNeedsPlacementCount: flexibleNeedsPlacementCount,
      recoverableMissedCount: recoverableMissedCount,
      consistencyCount: consistencyCount,
      totalPlannedMinutes: totalPlannedMinutes,
    );
  }
}
