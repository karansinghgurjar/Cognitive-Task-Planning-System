import 'package:uuid/uuid.dart';

import '../../schedule/models/planned_session.dart';
import '../../timetable/domain/availability_service.dart';
import '../../timetable/models/timetable_slot.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineSchedulingService {
  RoutineSchedulingService({
    AvailabilityService availabilityService = const AvailabilityService(),
    String Function()? idGenerator,
  }) : _availabilityService = availabilityService,
       _idGenerator = idGenerator ?? const Uuid().v4;

  final AvailabilityService _availabilityService;
  final String Function() _idGenerator;

  RoutineGenerationResult generateOccurrences({
    required List<Routine> routines,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    List<RoutineOccurrence> existingOccurrences = const [],
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final normalizedStart = DateTime(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute,
    );
    final normalizedEnd = DateTime(
      end.year,
      end.month,
      end.day,
      end.hour,
      end.minute,
    );
    if (!normalizedStart.isBefore(normalizedEnd)) {
      return const RoutineGenerationResult();
    }

    final activeRoutines = routines
        .where((routine) => routine.generatesOccurrences)
        .toList()
      ..sort((left, right) {
        final priorityCompare = left.priority.compareTo(right.priority);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return left.createdAt.compareTo(right.createdAt);
      });

    final existingByRoutineAndDay = <String, RoutineOccurrence>{};
    for (final occurrence in existingOccurrences) {
      final key = _occurrenceKey(
        occurrence.routineId,
        DateTime(
          occurrence.scheduledStart.year,
          occurrence.scheduledStart.month,
          occurrence.scheduledStart.day,
        ),
      );
      existingByRoutineAndDay[key] = occurrence;
    }

    final blockedRanges = <_DateTimeRange>[
      ...plannedSessions
          .where((session) => !session.isCancelled && !session.isMissed)
          .where((session) => session.end.isAfter(normalizedStart))
          .map((session) => _DateTimeRange(session.start, session.end)),
      ...existingOccurrences
          .where((occurrence) {
            final effectiveStatus = occurrence.effectiveStatusAt(now);
            return effectiveStatus == RoutineOccurrenceStatus.completed ||
                effectiveStatus == RoutineOccurrenceStatus.pending;
          })
          .where((occurrence) => occurrence.scheduledEnd.isAfter(normalizedStart))
          .map(
            (occurrence) => _DateTimeRange(
              occurrence.scheduledStart,
              occurrence.scheduledEnd,
            ),
          ),
    ]..sort((left, right) => left.start.compareTo(right.start));

    final generatedOccurrences = <RoutineOccurrence>[];
    final skippedOccurrences = <SkippedRoutineOccurrence>[];

    final firstDate = DateTime(
      normalizedStart.year,
      normalizedStart.month,
      normalizedStart.day,
    );
    final lastMoment = normalizedEnd.subtract(const Duration(minutes: 1));
    final lastDate = DateTime(
      lastMoment.year,
      lastMoment.month,
      lastMoment.day,
    );

    for (final routine in activeRoutines) {
      for (
        var date = firstDate;
        !date.isAfter(lastDate);
        date = date.add(const Duration(days: 1))
      ) {
        if (!routine.occursOnDate(date)) {
          continue;
        }

        final existingKey = _occurrenceKey(routine.id, date);
        final existing = existingByRoutineAndDay[existingKey];
        if (existing != null &&
            existing.effectiveStatusAt(now) != RoutineOccurrenceStatus.missed) {
          generatedOccurrences.add(existing);
          continue;
        }

        final freeRanges = _freeRangesForDate(
          date: date,
          routine: routine,
          timetableSlots: timetableSlots,
          blockedRanges: blockedRanges,
          now: now,
        );

        final scheduledRange = _scheduleOccurrence(
          routine: routine,
          date: date,
          freeRanges: freeRanges,
          start: normalizedStart,
          end: normalizedEnd,
        );

        if (scheduledRange == null) {
          skippedOccurrences.add(
            SkippedRoutineOccurrence(
              routineId: routine.id,
              routineTitle: routine.title,
              date: date,
              reason: _skipReasonFor(routine),
            ),
          );
          continue;
        }

        final occurrence = (existing ?? _newOccurrence(routine.id, now)).copyWith(
          scheduledStart: scheduledRange.start,
          scheduledEnd: scheduledRange.end,
          status: RoutineOccurrenceStatus.pending,
          generatedFromRule: true,
          clearCompletedAt: true,
          updatedAt: now,
        );
        generatedOccurrences.add(occurrence);
        blockedRanges.add(
          _DateTimeRange(occurrence.scheduledStart, occurrence.scheduledEnd),
        );
        blockedRanges.sort((left, right) => left.start.compareTo(right.start));
      }
    }

    generatedOccurrences.sort(
      (left, right) => left.scheduledStart.compareTo(right.scheduledStart),
    );

    return RoutineGenerationResult(
      generatedOccurrences: generatedOccurrences,
      skippedOccurrences: skippedOccurrences,
    );
  }

  RoutineOccurrence? nextOccurrencePreview({
    required Routine routine,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    List<RoutineOccurrence> existingOccurrences = const [],
    required DateTime now,
  }) {
    final result = generateOccurrences(
      routines: [routine],
      timetableSlots: timetableSlots,
      plannedSessions: plannedSessions,
      existingOccurrences: existingOccurrences,
      start: now,
      end: now.add(const Duration(days: 30)),
      now: now,
    );
    if (result.generatedOccurrences.isEmpty) {
      return null;
    }
    return result.generatedOccurrences.first;
  }

  RoutineOccurrence rescheduleOccurrence({
    required RoutineOccurrence occurrence,
    required DateTime newStart,
    String? notes,
    DateTime? now,
  }) {
    final updatedAt = now ?? DateTime.now();
    return occurrence.copyWith(
      scheduledStart: newStart,
      scheduledEnd: newStart.add(Duration(minutes: occurrence.durationMinutes)),
      status: RoutineOccurrenceStatus.pending,
      generatedFromRule: false,
      clearCompletedAt: true,
      notes: notes,
      clearNotes: notes == null || notes.trim().isEmpty,
      updatedAt: updatedAt,
    );
  }

  List<_DateTimeRange> _freeRangesForDate({
    required DateTime date,
    required Routine routine,
    required List<TimetableSlot> timetableSlots,
    required List<_DateTimeRange> blockedRanges,
    required DateTime now,
  }) {
    final weekdayAvailability = _availabilityService.computeAvailabilityForDay(
      date.weekday,
      timetableSlots,
    );
    final concreteRanges = weekdayAvailability.map((window) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        window.startHour,
        window.startMinute,
      );
      final end = DateTime(
        date.year,
        date.month,
        date.day,
        window.endHour,
        window.endMinute,
      );
      final adjustedStart = _isSameDate(date, now) && start.isBefore(now)
          ? now
          : start;
      return _DateTimeRange(adjustedStart, end);
    }).where((range) => range.start.isBefore(range.end)).toList();

    final constrainedRanges = routine.hasTimeWindow
        ? concreteRanges
              .map((range) => _applyRoutineWindow(range, date, routine))
              .whereType<_DateTimeRange>()
              .toList()
        : concreteRanges;

    final freeRanges = <_DateTimeRange>[];
    for (final range in constrainedRanges) {
      var segments = <_DateTimeRange>[range];
      for (final blockedRange in blockedRanges) {
        if (!blockedRange.start.isBefore(range.end) ||
            !blockedRange.end.isAfter(range.start)) {
          continue;
        }
        final nextSegments = <_DateTimeRange>[];
        for (final segment in segments) {
          nextSegments.addAll(_subtractRange(segment, blockedRange));
        }
        segments = nextSegments;
        if (segments.isEmpty) {
          break;
        }
      }
      freeRanges.addAll(segments);
    }

    freeRanges.sort((left, right) => left.start.compareTo(right.start));
    return freeRanges;
  }

  _DateTimeRange? _applyRoutineWindow(
    _DateTimeRange range,
    DateTime date,
    Routine routine,
  ) {
    final windowStartMinute = routine.timeWindowStartMinute!;
    final windowEndMinute = routine.timeWindowEndMinute!;
    final windowStart = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(minutes: windowStartMinute));
    final windowEnd = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(minutes: windowEndMinute));
    final boundedStart = range.start.isAfter(windowStart) ? range.start : windowStart;
    final boundedEnd = range.end.isBefore(windowEnd) ? range.end : windowEnd;
    if (!boundedStart.isBefore(boundedEnd)) {
      return null;
    }
    return _DateTimeRange(boundedStart, boundedEnd);
  }

  _DateTimeRange? _scheduleOccurrence({
    required Routine routine,
    required DateTime date,
    required List<_DateTimeRange> freeRanges,
    required DateTime start,
    required DateTime end,
  }) {
    final preferred = routine.hasPreferredStartTime
        ? _scheduleAtPreferredTime(
            routine: routine,
            date: date,
            freeRanges: freeRanges,
            start: start,
            end: end,
          )
        : null;
    if (preferred != null || !routine.isFlexible) {
      return preferred;
    }
    return _scheduleAtFirstAvailableTime(
      routine: routine,
      freeRanges: freeRanges,
      start: start,
      end: end,
    );
  }

  _DateTimeRange? _scheduleAtPreferredTime({
    required Routine routine,
    required DateTime date,
    required List<_DateTimeRange> freeRanges,
    required DateTime start,
    required DateTime end,
  }) {
    final candidateStart = DateTime(
      date.year,
      date.month,
      date.day,
      routine.preferredStartHour!,
      routine.preferredStartMinute!,
    );
    final candidateEnd = candidateStart.add(
      Duration(minutes: routine.durationMinutes),
    );
    if (!candidateStart.isBefore(candidateEnd) ||
        candidateStart.isBefore(start) ||
        candidateEnd.isAfter(end)) {
      return null;
    }

    for (final range in freeRanges) {
      if ((candidateStart.isAtSameMomentAs(range.start) ||
              candidateStart.isAfter(range.start)) &&
          (candidateEnd.isAtSameMomentAs(range.end) ||
              candidateEnd.isBefore(range.end))) {
        return _DateTimeRange(candidateStart, candidateEnd);
      }
    }
    return null;
  }

  _DateTimeRange? _scheduleAtFirstAvailableTime({
    required Routine routine,
    required List<_DateTimeRange> freeRanges,
    required DateTime start,
    required DateTime end,
  }) {
    for (final range in freeRanges) {
      if (range.durationMinutes < routine.durationMinutes) {
        continue;
      }
      final candidateStart = range.start.isBefore(start) ? start : range.start;
      final candidateEnd = candidateStart.add(
        Duration(minutes: routine.durationMinutes),
      );
      if (!candidateEnd.isAfter(candidateStart) ||
          candidateEnd.isAfter(end) ||
          candidateEnd.isAfter(range.end)) {
        continue;
      }
      return _DateTimeRange(candidateStart, candidateEnd);
    }
    return null;
  }

  List<_DateTimeRange> _subtractRange(
    _DateTimeRange source,
    _DateTimeRange blocker,
  ) {
    final overlapStart = blocker.start.isAfter(source.start)
        ? blocker.start
        : source.start;
    final overlapEnd = blocker.end.isBefore(source.end)
        ? blocker.end
        : source.end;

    if (!overlapStart.isBefore(overlapEnd)) {
      return [source];
    }

    final segments = <_DateTimeRange>[];
    if (source.start.isBefore(overlapStart)) {
      segments.add(_DateTimeRange(source.start, overlapStart));
    }
    if (overlapEnd.isBefore(source.end)) {
      segments.add(_DateTimeRange(overlapEnd, source.end));
    }
    return segments;
  }

  RoutineOccurrence _newOccurrence(String routineId, DateTime now) {
    return RoutineOccurrence(
      id: _idGenerator(),
      routineId: routineId,
      scheduledStart: now,
      scheduledEnd: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  String _occurrenceKey(String routineId, DateTime date) {
    return '$routineId|${date.year}-${date.month}-${date.day}';
  }

  RoutineSkipReason _skipReasonFor(Routine routine) {
    if (!routine.isFlexible && routine.hasPreferredStartTime) {
      return RoutineSkipReason.conflictAtPreferredTime;
    }
    if (routine.hasTimeWindow) {
      return RoutineSkipReason.noAvailableSlotInWindow;
    }
    return RoutineSkipReason.noAvailableSlot;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class RoutineGenerationResult {
  const RoutineGenerationResult({
    this.generatedOccurrences = const [],
    this.skippedOccurrences = const [],
  });

  final List<RoutineOccurrence> generatedOccurrences;
  final List<SkippedRoutineOccurrence> skippedOccurrences;
}

class SkippedRoutineOccurrence {
  const SkippedRoutineOccurrence({
    required this.routineId,
    required this.routineTitle,
    required this.date,
    required this.reason,
  });

  final String routineId;
  final String routineTitle;
  final DateTime date;
  final RoutineSkipReason reason;
}

enum RoutineSkipReason {
  conflictAtPreferredTime,
  noAvailableSlot,
  noAvailableSlotInWindow,
}

class _DateTimeRange {
  const _DateTimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get durationMinutes => end.difference(start).inMinutes;
}
