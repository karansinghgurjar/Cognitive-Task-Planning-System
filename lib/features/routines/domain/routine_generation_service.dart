import 'package:uuid/uuid.dart';

import 'routine_date_utils.dart';
import 'routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineGenerationService {
  RoutineGenerationService({String Function()? idGenerator})
    : _idGenerator = idGenerator ?? const Uuid().v4;

  final String Function() _idGenerator;

  List<DateTime> computeOccurrenceDates(
    Routine routine, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final normalizedStart = normalizeDate(startDate);
    final normalizedEnd = normalizeDate(endDate);
    if (normalizedStart.isAfter(normalizedEnd) || routine.isArchived) {
      return const [];
    }

    final effectiveStart = normalizedStart.isBefore(routine.anchorDate)
        ? routine.anchorDate
        : normalizedStart;

    final dates = <DateTime>[];
    for (
      var cursor = effectiveStart;
      !cursor.isAfter(normalizedEnd);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      if (occursOnDate(routine, cursor)) {
        dates.add(cursor);
      }
    }
    return dates;
  }

  List<RoutineOccurrence> buildOccurrences(
    Routine routine,
    List<DateTime> dates, {
    DateTime? generatedAt,
  }) {
    final now = generatedAt ?? DateTime.now();
    return dates.map((date) => buildOccurrence(routine, date, generatedAt: now)).toList();
  }

  RoutineOccurrence buildOccurrence(
    Routine routine,
    DateTime date, {
    DateTime? generatedAt,
  }) {
    final normalizedDate = normalizeDate(date);
    final now = generatedAt ?? DateTime.now();
    final startMinute = routine.preferredStartMinuteOfDay;
    final duration = routine.preferredDurationMinutes;
    final scheduledStart = startMinute == null
        ? null
        : composeDateAndMinute(normalizedDate, startMinute);
    final scheduledEnd = startMinute != null && duration != null
        ? scheduledStart!.add(Duration(minutes: duration))
        : null;

    return RoutineOccurrence(
      id: _idGenerator(),
      routineId: routine.id,
      occurrenceDate: normalizedDate,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      status: RoutineOccurrenceStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
  }

  bool occursOnDate(Routine routine, DateTime date) {
    final normalizedDate = normalizeDate(date);
    if (normalizedDate.isBefore(routine.anchorDate) || routine.isArchived) {
      return false;
    }

    final rule = routine.repeatRule;
    switch (rule.type) {
      case RoutineRepeatType.daily:
        final delta = daysBetween(routine.anchorDate, normalizedDate);
        return delta >= 0 && delta % rule.interval == 0;
      case RoutineRepeatType.weekdays:
        return normalizedDate.weekday >= DateTime.monday &&
            normalizedDate.weekday <= DateTime.friday;
      case RoutineRepeatType.selectedWeekdays:
        return rule.weekdays.contains(normalizedDate.weekday);
      case RoutineRepeatType.weekly:
        final delta = weeksBetween(routine.anchorDate, normalizedDate);
        return normalizedDate.weekday == routine.anchorDate.weekday &&
            delta >= 0 &&
            delta % rule.interval == 0;
      case RoutineRepeatType.monthly:
        final delta = monthsBetween(routine.anchorDate, normalizedDate);
        final targetDay = rule.dayOfMonth ?? routine.anchorDate.day;
        return delta >= 0 &&
            delta % rule.interval == 0 &&
            normalizedDate.day == targetDay &&
            tryCreateDate(
                  normalizedDate.year,
                  normalizedDate.month,
                  targetDay,
                ) !=
                null;
    }
  }
}
