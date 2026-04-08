import 'package:uuid/uuid.dart';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineRecoverySuggestion {
  const RoutineRecoverySuggestion({
    required this.sourceOccurrence,
    required this.routine,
    required this.suggestedStart,
    required this.reason,
  });

  final RoutineOccurrence sourceOccurrence;
  final Routine routine;
  final DateTime suggestedStart;
  final String reason;
}

class RoutineRecoveryService {
  RoutineRecoveryService({
    this.gracePeriod = const Duration(minutes: 30),
    this.recoveryHorizon = const Duration(days: 2),
    String Function()? idGenerator,
  }) : _idGenerator = idGenerator ?? const Uuid().v4;

  final Duration gracePeriod;
  final Duration recoveryHorizon;
  final String Function() _idGenerator;

  List<RoutineOccurrence> detectMissedOccurrences({
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
  }) {
    return occurrences
        .where((occurrence) => _shouldMarkMissed(occurrence, now))
        .map(
          (occurrence) => occurrence.copyWith(
            status: RoutineOccurrenceStatus.missed,
            missedAt: now,
            clearCompletedAt: true,
            clearSkippedAt: true,
            updatedAt: now,
          ),
        )
        .toList();
  }

  List<RoutineRecoverySuggestion> buildRecoverySuggestions({
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required DateTime now,
  }) {
    final routineById = {for (final routine in routines) routine.id: routine};
    final existingRecoverySourceIds = occurrences
        .where((item) => item.recoveredFromOccurrenceId != null)
        .map((item) => item.recoveredFromOccurrenceId!)
        .toSet();

    final suggestions = <RoutineRecoverySuggestion>[];
    for (final occurrence in occurrences) {
      final routine = routineById[occurrence.routineId];
      if (routine == null ||
          routine.isArchived ||
          !routine.autoRescheduleMissed ||
          occurrence.effectiveStatusAt(now) != RoutineOccurrenceStatus.missed ||
          existingRecoverySourceIds.contains(occurrence.id)) {
        continue;
      }
      final suggestedStart = _suggestRecoveryStart(routine, occurrence, now);
      if (suggestedStart == null) {
        continue;
      }
      suggestions.add(
        RoutineRecoverySuggestion(
          sourceOccurrence: occurrence,
          routine: routine,
          suggestedStart: suggestedStart,
          reason: 'Missed ${routine.title}. Recover it within the next 2 days.',
        ),
      );
    }
    return suggestions;
  }

  RoutineOccurrence createRecoveryOccurrence(
    RoutineRecoverySuggestion suggestion, {
    required DateTime now,
  }) {
    final duration = suggestion.sourceOccurrence.durationMinutes ??
        suggestion.routine.preferredDurationMinutes;
    final start = suggestion.suggestedStart;
    return RoutineOccurrence(
      id: _idGenerator(),
      routineId: suggestion.routine.id,
      occurrenceDate: normalizeDate(start),
      scheduledStart: start,
      scheduledEnd: duration == null ? null : start.add(Duration(minutes: duration)),
      status: RoutineOccurrenceStatus.pending,
      createdAt: now,
      updatedAt: now,
      isRecoveryInstance: true,
      recoveredFromOccurrenceId: suggestion.sourceOccurrence.id,
      isAutoScheduled: true,
      schedulingNote: 'Recovery placement',
      notes: 'Recovery for missed routine block',
    );
  }

  bool _shouldMarkMissed(RoutineOccurrence occurrence, DateTime now) {
    if (occurrence.status != RoutineOccurrenceStatus.pending) {
      return false;
    }
    if (occurrence.scheduledEnd != null) {
      return now.isAfter(occurrence.scheduledEnd!.add(gracePeriod));
    }
    if (occurrence.scheduledStart != null) {
      return normalizeDate(occurrence.occurrenceDate).isBefore(normalizeDate(now));
    }
    return normalizeDate(occurrence.occurrenceDate).isBefore(normalizeDate(now));
  }

  DateTime? _suggestRecoveryStart(
    Routine routine,
    RoutineOccurrence occurrence,
    DateTime now,
  ) {
    final baseDate = normalizeDate(now);
    final latestDate = baseDate.add(recoveryHorizon);
    var candidate = baseDate;

    while (!candidate.isAfter(latestDate)) {
      if (!routine.isFlexible && routine.preferredStartMinuteOfDay == null) {
        return null;
      }
      if (routine.preferredStartMinuteOfDay != null) {
        final start = composeDateAndMinute(candidate, routine.preferredStartMinuteOfDay!);
        if (start.isAfter(now)) {
          return start;
        }
      } else {
        final fallback = composeDateAndMinute(candidate, 18 * 60);
        if (fallback.isAfter(now)) {
          return fallback;
        }
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return null;
  }
}
