import 'package:intl/intl.dart';

import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

String formatRoutineRepeatSummary(Routine routine) {
  final rule = routine.repeatRule;
  switch (rule.type) {
    case RoutineRepeatType.daily:
      return rule.interval == 1 ? 'Daily' : 'Every ${rule.interval} days';
    case RoutineRepeatType.weekdays:
      return 'Weekdays';
    case RoutineRepeatType.selectedWeekdays:
      return rule.weekdays.map(formatWeekdayShortLabel).join(', ');
    case RoutineRepeatType.weekly:
      final weekday = formatWeekdayShortLabel(routine.anchorDate.weekday);
      return rule.interval == 1
          ? 'Weekly on $weekday'
          : 'Every ${rule.interval} weeks on $weekday';
    case RoutineRepeatType.monthly:
      final day = rule.dayOfMonth ?? routine.anchorDate.day;
      return rule.interval == 1
          ? 'Monthly on day $day'
          : 'Every ${rule.interval} months on day $day';
  }
}

String formatRoutineTimingSummary(Routine routine) {
  final pieces = <String>[];
  final preferredStart = routine.preferredStartMinuteOfDay;
  final preferredDuration = routine.preferredDurationMinutes;

  if (preferredStart != null) {
    pieces.add(_formatMinuteOfDay(preferredStart));
  }
  if (preferredDuration != null) {
    pieces.add(formatDurationMinutes(preferredDuration));
  }
  if (routine.timeWindowStartMinuteOfDay != null &&
      routine.timeWindowEndMinuteOfDay != null) {
    pieces.add(
      'Window: ${_formatMinuteOfDay(routine.timeWindowStartMinuteOfDay!)}-'
      '${_formatMinuteOfDay(routine.timeWindowEndMinuteOfDay!)}',
    );
  }

  return pieces.isEmpty ? 'No timing preference' : pieces.join(' • ');
}

String formatOccurrenceTimingSummary(RoutineOccurrence occurrence) {
  final start = occurrence.scheduledStart;
  final end = occurrence.scheduledEnd;
  if (start != null && end != null) {
    return '${DateFormat.jm().format(start)}-${DateFormat.jm().format(end)}';
  }
  if (start != null) {
    return DateFormat.jm().format(start);
  }
  return 'Any time';
}

String formatOccurrenceScheduleContext(RoutineOccurrence occurrence) {
  final timing = formatOccurrenceTimingSummary(occurrence);
  final duration = occurrence.durationMinutes;
  if (duration == null) {
    return timing;
  }
  return '$timing • ${formatDurationMinutes(duration)}';
}

String formatDurationMinutes(int minutes) {
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return hours == 1 ? '1h' : '${hours}h';
  }
  if (minutes > 60) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}h ${remaining}m';
  }
  return '${minutes}m';
}

String formatRoutineStatusLabel(RoutineOccurrenceStatus status) => status.label;

String formatWeekdayShortLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return 'Day';
  }
}

String formatWeekRangeLabel(DateTime startDate) {
  final endDate = startDate.add(const Duration(days: 6));
  final startFormat = DateFormat('MMM d');
  final endFormat = startDate.year == endDate.year
      ? DateFormat('MMM d')
      : DateFormat('MMM d, y');
  return '${startFormat.format(startDate)} - ${endFormat.format(endDate)}';
}

String _formatMinuteOfDay(int minuteOfDay) {
  final date = DateTime(2026, 1, 1, minuteOfDay ~/ 60, minuteOfDay % 60);
  return DateFormat.jm().format(date);
}
