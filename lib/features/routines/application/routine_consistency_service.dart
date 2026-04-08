import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

enum RoutineAnalyticsRange { last7Days, last30Days, allTime }

class RoutineConsistencySummary {
  const RoutineConsistencySummary({
    required this.routineId,
    required this.totalOccurrences,
    required this.closedOccurrences,
    required this.completedCount,
    required this.skippedCount,
    required this.missedCount,
    required this.pendingCount,
    required this.completionRate,
    required this.lastCompletedAt,
    required this.lastMissedAt,
    required this.totalCompletedMinutes,
    required this.healthLabel,
    required this.trendLabel,
  });

  final String routineId;
  final int totalOccurrences;
  final int closedOccurrences;
  final int completedCount;
  final int skippedCount;
  final int missedCount;
  final int pendingCount;
  final double completionRate;
  final DateTime? lastCompletedAt;
  final DateTime? lastMissedAt;
  final int totalCompletedMinutes;
  final String healthLabel;
  final String trendLabel;

  String get insightLabel {
    if (closedOccurrences == 0) {
      return 'No closed routine history yet';
    }
    if (completionRate >= 0.8) {
      return 'Strong consistency';
    }
    if (missedCount >= completedCount && missedCount > 0) {
      return 'Misses are outweighing completions';
    }
    if (completedCount == 0) {
      return 'No completions yet';
    }
    return 'Routine is building consistency';
  }
}

class RoutineConsistencyService {
  const RoutineConsistencyService();

  RoutineConsistencySummary summarize({
    required Routine routine,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
    required RoutineAnalyticsRange range,
  }) {
    final filtered = _filterByRange(occurrences, now, range);
    final completed = filtered
        .where((item) => item.status == RoutineOccurrenceStatus.completed)
        .toList();
    final skipped = filtered
        .where((item) => item.status == RoutineOccurrenceStatus.skipped)
        .toList();
    final missed = filtered
        .where((item) => item.effectiveStatusAt(now) == RoutineOccurrenceStatus.missed)
        .toList();
    final pending = filtered
        .where((item) => item.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending)
        .toList();
    final closed = completed.length + skipped.length + missed.length;

    return RoutineConsistencySummary(
      routineId: routine.id,
      totalOccurrences: filtered.length,
      closedOccurrences: closed,
      completedCount: completed.length,
      skippedCount: skipped.length,
      missedCount: missed.length,
      pendingCount: pending.length,
      completionRate: closed == 0 ? 0 : completed.length / closed,
      lastCompletedAt: completed
          .map((item) => item.completedAt ?? item.updatedAt ?? item.createdAt)
          .fold<DateTime?>(null, _latest),
      lastMissedAt: missed
          .map((item) => item.missedAt ?? item.updatedAt ?? item.createdAt)
          .fold<DateTime?>(null, _latest),
      totalCompletedMinutes: completed.fold<int>(
        0,
        (sum, item) => sum + (item.durationMinutes ?? routine.preferredDurationMinutes ?? 0),
      ),
      healthLabel: _healthLabel(
        completedCount: completed.length,
        missedCount: missed.length,
        closedCount: closed,
      ),
      trendLabel: _trendLabel(
        current: _windowCompletionRate(filtered),
        previous: _previousWindowCompletionRate(occurrences, now, range),
      ),
    );
  }

  List<RoutineOccurrence> _filterByRange(
    List<RoutineOccurrence> occurrences,
    DateTime now,
    RoutineAnalyticsRange range,
  ) {
    if (range == RoutineAnalyticsRange.allTime) {
      return occurrences;
    }
    final days = range == RoutineAnalyticsRange.last7Days ? 7 : 30;
    final start = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: days - 1),
    );
    return occurrences.where((item) => !item.occurrenceDate.isBefore(start)).toList();
  }

  DateTime? _latest(DateTime? current, DateTime? value) {
    if (value == null) {
      return current;
    }
    if (current == null || value.isAfter(current)) {
      return value;
    }
    return current;
  }

  String _healthLabel({
    required int completedCount,
    required int missedCount,
    required int closedCount,
  }) {
    if (closedCount == 0) {
      return 'Inactive';
    }
    final completionRate = completedCount / closedCount;
    if (completionRate >= 0.8) {
      return 'On track';
    }
    if (missedCount > completedCount) {
      return 'At risk';
    }
    return 'Mixed';
  }

  String _trendLabel({
    required double current,
    required double? previous,
  }) {
    if (previous == null) {
      return 'No comparison yet';
    }
    if (current >= previous + 0.15) {
      return 'Improving over the previous window';
    }
    if (current <= previous - 0.15) {
      return 'Behind the previous window';
    }
    return 'Holding steady';
  }

  double _windowCompletionRate(List<RoutineOccurrence> occurrences) {
    final completed = occurrences
        .where((item) => item.status == RoutineOccurrenceStatus.completed)
        .length;
    final skipped = occurrences
        .where((item) => item.status == RoutineOccurrenceStatus.skipped)
        .length;
    final missed = occurrences
        .where((item) => item.status == RoutineOccurrenceStatus.missed)
        .length;
    final closed = completed + skipped + missed;
    return closed == 0 ? 0 : completed / closed;
  }

  double? _previousWindowCompletionRate(
    List<RoutineOccurrence> occurrences,
    DateTime now,
    RoutineAnalyticsRange range,
  ) {
    if (range == RoutineAnalyticsRange.allTime) {
      return null;
    }
    final days = range == RoutineAnalyticsRange.last7Days ? 7 : 30;
    final end = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: days),
    );
    final start = end.subtract(Duration(days: days - 1));
    final previous = occurrences.where((item) {
      return !item.occurrenceDate.isBefore(start) &&
          !item.occurrenceDate.isAfter(end);
    }).toList();
    return _windowCompletionRate(previous);
  }
}
