import '../../schedule/models/planned_session.dart';
import '../../timetable/domain/availability_service.dart';
import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineSchedulerIntegrationResult {
  const RoutineSchedulerIntegrationResult({
    required this.updatedOccurrences,
    required this.unscheduledOccurrences,
  });

  final List<RoutineOccurrence> updatedOccurrences;
  final List<RoutineOccurrence> unscheduledOccurrences;
}

class RoutineSchedulerIntegrationService {
  const RoutineSchedulerIntegrationService();

  RoutineSchedulerIntegrationResult integrate({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<PlannedSession> plannedSessions,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime now,
  }) {
    final routineById = {for (final routine in routines) routine.id: routine};
    final horizonOccurrences = occurrences.where((occurrence) {
      return !occurrence.occurrenceDate.isBefore(normalizeDate(startDate)) &&
          !occurrence.occurrenceDate.isAfter(normalizeDate(endDate)) &&
          occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
    }).toList()
      ..sort((left, right) {
        final leftRoutine = routineById[left.routineId];
        final rightRoutine = routineById[right.routineId];
        final priorityCompare =
            (leftRoutine?.priority ?? 99).compareTo(rightRoutine?.priority ?? 99);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return left.occurrenceDate.compareTo(right.occurrenceDate);
      });

    final occupiedByDate = <DateTime, List<_TimeRange>>{};
    for (final session in plannedSessions.where((session) => session.blocksScheduling)) {
      final date = normalizeDate(session.start);
      occupiedByDate.putIfAbsent(date, () => []).add(_TimeRange(session.start, session.end));
    }

    final updates = <RoutineOccurrence>[];
    final unscheduled = <RoutineOccurrence>[];

    for (final occurrence in horizonOccurrences) {
      final routine = routineById[occurrence.routineId];
      if (routine == null) {
        continue;
      }

      final normalizedDate = occurrence.occurrenceDate;
      final occupied = occupiedByDate.putIfAbsent(normalizedDate, () => []);

      if (!routine.isFlexible) {
        final fixedUpdate = _placeFixedRoutine(
          occurrence: occurrence,
          routine: routine,
          occupied: occupied,
        );
        updates.add(fixedUpdate);
        if (fixedUpdate.scheduledStart != null && fixedUpdate.scheduledEnd != null) {
          occupied.add(_TimeRange(fixedUpdate.scheduledStart!, fixedUpdate.scheduledEnd!));
        } else if (fixedUpdate.needsAttention) {
          unscheduled.add(fixedUpdate);
        }
        continue;
      }

      final flexibleUpdate = _placeFlexibleRoutine(
        occurrence: occurrence,
        routine: routine,
        weeklyAvailability: weeklyAvailability,
        occupied: occupied,
      );
      updates.add(flexibleUpdate);
      if (flexibleUpdate.scheduledStart != null && flexibleUpdate.scheduledEnd != null) {
        occupied.add(
          _TimeRange(flexibleUpdate.scheduledStart!, flexibleUpdate.scheduledEnd!),
        );
      }
      if (flexibleUpdate.needsAttention) {
        unscheduled.add(flexibleUpdate);
      }
    }

    return RoutineSchedulerIntegrationResult(
      updatedOccurrences: updates,
      unscheduledOccurrences: unscheduled,
    );
  }

  RoutineOccurrence _placeFixedRoutine({
    required RoutineOccurrence occurrence,
    required Routine routine,
    required List<_TimeRange> occupied,
  }) {
    if (routine.preferredStartMinuteOfDay == null) {
      return occurrence.copyWith(
        needsAttention: true,
        clearScheduledStart: true,
        clearScheduledEnd: true,
        isAutoScheduled: false,
        schedulingNote: 'Fixed routine needs a preferred time',
      );
    }

    final start = composeDateAndMinute(
      occurrence.occurrenceDate,
      routine.preferredStartMinuteOfDay!,
    );
    final end = start.add(Duration(minutes: routine.preferredDurationMinutes ?? 60));
    final conflicts = occupied.any((range) => range.overlaps(start, end));

    return occurrence.copyWith(
      scheduledStart: start,
      scheduledEnd: end,
      needsAttention: conflicts,
      isAutoScheduled: false,
      schedulingNote: conflicts ? 'Conflicts with existing schedule' : 'Fixed placement',
    );
  }

  RoutineOccurrence _placeFlexibleRoutine({
    required RoutineOccurrence occurrence,
    required Routine routine,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<_TimeRange> occupied,
  }) {
    if (occurrence.scheduledStart != null &&
        !occurrence.isAutoScheduled &&
        !occurrence.needsAttention) {
      return occurrence;
    }

    final durationMinutes = occurrence.durationMinutes ?? routine.preferredDurationMinutes;
    if (durationMinutes == null || durationMinutes <= 0) {
      return occurrence.copyWith(
        needsAttention: true,
        schedulingNote: 'Flexible routine needs a duration to auto-place',
      );
    }

    final windows = weeklyAvailability[occurrence.occurrenceDate.weekday] ?? const [];
    final candidates = <_TimeRange>[];
    for (final window in windows) {
      final start = composeDateAndMinute(
        occurrence.occurrenceDate,
        window.startHour * 60 + window.startMinute,
      );
      final end = composeDateAndMinute(
        occurrence.occurrenceDate,
        window.endHour * 60 + window.endMinute,
      );
      final constrained = _applyRoutineWindow(
        start: start,
        end: end,
        routine: routine,
      );
      if (constrained != null) {
        candidates.add(constrained);
      }
    }

    final fit = _chooseBestFit(
      candidates: candidates,
      occupied: occupied,
      durationMinutes: durationMinutes,
      preferredStartMinuteOfDay: routine.preferredStartMinuteOfDay,
      date: occurrence.occurrenceDate,
    );

    if (fit == null) {
      return occurrence.copyWith(
        clearScheduledStart: true,
        clearScheduledEnd: true,
        needsAttention: true,
        isAutoScheduled: false,
        schedulingNote: 'No valid slot found in the current schedule',
      );
    }

    return occurrence.copyWith(
      scheduledStart: fit.start,
      scheduledEnd: fit.end,
      needsAttention: false,
      isAutoScheduled: true,
      schedulingNote: 'Placed in available window',
    );
  }

  _TimeRange? _applyRoutineWindow({
    required DateTime start,
    required DateTime end,
    required Routine routine,
  }) {
    var constrainedStart = start;
    var constrainedEnd = end;
    if (routine.timeWindowStartMinuteOfDay != null) {
      final windowStart = composeDateAndMinute(
        start,
        routine.timeWindowStartMinuteOfDay!,
      );
      if (windowStart.isAfter(constrainedStart)) {
        constrainedStart = windowStart;
      }
    }
    if (routine.timeWindowEndMinuteOfDay != null) {
      final windowEnd = composeDateAndMinute(start, routine.timeWindowEndMinuteOfDay!);
      if (windowEnd.isBefore(constrainedEnd)) {
        constrainedEnd = windowEnd;
      }
    }
    if (!constrainedStart.isBefore(constrainedEnd)) {
      return null;
    }
    return _TimeRange(constrainedStart, constrainedEnd);
  }

  _TimeRange? _chooseBestFit({
    required List<_TimeRange> candidates,
    required List<_TimeRange> occupied,
    required int durationMinutes,
    required int? preferredStartMinuteOfDay,
    required DateTime date,
  }) {
    _ScoredRange? best;
    for (final candidate in candidates) {
      final freeSegments = _subtractOccupied(candidate, occupied);
      for (final segment in freeSegments) {
        if (segment.durationMinutes < durationMinutes) {
          continue;
        }
        final start = segment.start;
        final end = start.add(Duration(minutes: durationMinutes));
        final preferredStart = preferredStartMinuteOfDay == null
            ? null
            : composeDateAndMinute(date, preferredStartMinuteOfDay);
        final score = preferredStart == null
            ? start.millisecondsSinceEpoch
            : start.difference(preferredStart).inMinutes.abs();
        final candidateScore = _ScoredRange(
          start: start,
          end: end,
          score: score,
        );
        if (best == null ||
            candidateScore.score < best.score ||
            (candidateScore.score == best.score &&
                candidateScore.start.isBefore(best.start))) {
          best = candidateScore;
        }
      }
    }
    return best == null ? null : _TimeRange(best.start, best.end);
  }

  List<_TimeRange> _subtractOccupied(
    _TimeRange source,
    List<_TimeRange> occupied,
  ) {
    var segments = <_TimeRange>[source];
    for (final blocker in occupied) {
      final next = <_TimeRange>[];
      for (final segment in segments) {
        if (!blocker.overlaps(segment.start, segment.end)) {
          next.add(segment);
          continue;
        }
        if (segment.start.isBefore(blocker.start)) {
          next.add(_TimeRange(segment.start, blocker.start));
        }
        if (blocker.end.isBefore(segment.end)) {
          next.add(_TimeRange(blocker.end, segment.end));
        }
      }
      segments = next;
    }
    return segments;
  }
}

class _TimeRange {
  const _TimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get durationMinutes => end.difference(start).inMinutes;

  bool overlaps(DateTime otherStart, DateTime otherEnd) {
    return start.isBefore(otherEnd) && end.isAfter(otherStart);
  }
}

class _ScoredRange {
  const _ScoredRange({
    required this.start,
    required this.end,
    required this.score,
  });

  final DateTime start;
  final DateTime end;
  final int score;
}
