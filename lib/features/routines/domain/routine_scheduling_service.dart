import '../../schedule/models/planned_session.dart';
import '../../timetable/models/timetable_slot.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';
import 'routine_date_utils.dart';
import 'routine_enums.dart';
import 'routine_generation_service.dart';

class RoutineSchedulingService {
  RoutineSchedulingService({RoutineGenerationService? generationService})
    : _generationService = generationService ?? RoutineGenerationService();

  final RoutineGenerationService _generationService;

  RoutineGenerationResult generateOccurrences({
    required List<Routine> routines,
    required List<TimetableSlot> timetableSlots,
    required List<PlannedSession> plannedSessions,
    List<RoutineOccurrence> existingOccurrences = const [],
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final normalizedStart = normalizeDate(start);
    final normalizedEnd = normalizeDate(end);
    if (normalizedStart.isAfter(normalizedEnd)) {
      return const RoutineGenerationResult();
    }

    final generated = <RoutineOccurrence>[];
    final skipped = <SkippedRoutineOccurrence>[];
    final existingByKey = {
      for (final occurrence in existingOccurrences) occurrence.occurrenceKey: occurrence,
    };

    for (final routine in routines.where((item) => item.generatesOccurrences)) {
      final dates = _generationService.computeOccurrenceDates(
        routine,
        startDate: normalizedStart,
        endDate: normalizedEnd,
      );
      for (final date in dates) {
        final key = buildOccurrenceKey(routine.id, date);
        final existing = existingByKey[key];
        if (existing != null) {
          generated.add(existing);
          continue;
        }

        final occurrence = _generationService.buildOccurrence(
          routine,
          date,
          generatedAt: now,
        );
        generated.add(occurrence);
      }

      if (dates.isEmpty) {
        skipped.add(
          SkippedRoutineOccurrence(
            routineId: routine.id,
            routineTitle: routine.title,
            date: normalizedStart,
            reason: RoutineSkipReason.noOccurrencesInRange,
          ),
        );
      }
    }

    generated.sort((left, right) {
      final dateCompare = left.occurrenceDate.compareTo(right.occurrenceDate);
      if (dateCompare != 0) {
        return dateCompare;
      }
      final leftStart = left.scheduledStart;
      final rightStart = right.scheduledStart;
      if (leftStart != null && rightStart != null) {
        return leftStart.compareTo(rightStart);
      }
      return left.id.compareTo(right.id);
    });

    return RoutineGenerationResult(
      generatedOccurrences: generated,
      skippedOccurrences: skipped,
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
      start: normalizeDate(now),
      end: normalizeDate(now.add(const Duration(days: 30))),
      now: now,
    );
    return result.generatedOccurrences.isEmpty
        ? null
        : result.generatedOccurrences.first;
  }

  RoutineOccurrence rescheduleOccurrence({
    required RoutineOccurrence occurrence,
    required DateTime newStart,
    String? notes,
    DateTime? now,
  }) {
    final updatedAt = now ?? DateTime.now();
    final duration = occurrence.durationMinutes;
    return occurrence.copyWith(
      occurrenceDate: normalizeDate(newStart),
      scheduledStart: newStart,
      scheduledEnd: duration == null
          ? null
          : newStart.add(Duration(minutes: duration)),
      status: RoutineOccurrenceStatus.pending,
      clearCompletedAt: true,
      clearSkippedAt: true,
      clearMissedAt: true,
      notes: notes,
      clearNotes: notes == null || notes.trim().isEmpty,
      updatedAt: updatedAt,
    );
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
  noOccurrencesInRange,
}
