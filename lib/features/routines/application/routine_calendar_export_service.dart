import 'dart:convert';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_group.dart';
import '../models/routine_occurrence.dart';

class RoutineExportBundle {
  const RoutineExportBundle({
    required this.fileName,
    required this.content,
  });

  final String fileName;
  final String content;
}

class RoutineCalendarExportService {
  const RoutineCalendarExportService();

  String generateRecurringRoutineIcs(
    List<Routine> routines, {
    String calendarName = 'CogniPlan Routines',
    DateTime? generatedAt,
  }) {
    final stamp = _formatUtc((generatedAt ?? DateTime.now()).toUtc());
    final ordered = List<Routine>.from(routines)
      ..sort((left, right) => left.title.compareTo(right.title));
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//CogniPlan//Routine Export//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      'X-WR-CALNAME:${_escape(calendarName)}',
      'X-WR-TIMEZONE:UTC',
    ];
    for (final routine in ordered) {
      final startMinute = routine.preferredStartMinuteOfDay;
      final durationMinutes = routine.preferredDurationMinutes ?? 30;
      if (startMinute == null) {
        continue;
      }
      final start = composeDateAndMinute(routine.anchorDate, startMinute);
      final end = start.add(Duration(minutes: durationMinutes));
      lines.addAll([
        'BEGIN:VEVENT',
        'UID:routine-${_safeId(routine.id)}@cogniplan.local',
        'DTSTAMP:$stamp',
        'DTSTART:${_formatUtc(start.toUtc())}',
        'DTEND:${_formatUtc(end.toUtc())}',
        'SUMMARY:${_escape(routine.title)}',
        'DESCRIPTION:${_escape(routine.description ?? 'Routine Block')}',
        'RRULE:${_buildRRule(routine)}',
        if ((routine.categoryId ?? '').trim().isNotEmpty)
          'CATEGORIES:${_escape(routine.categoryId!)}',
        'X-COGNIPLAN-ROUTINE-ID:${_escape(routine.id)}',
        'END:VEVENT',
      ]);
    }
    lines.add('END:VCALENDAR');
    return '${lines.expand(_foldLine).join('\r\n')}\r\n';
  }

  String generateOccurrenceRangeIcs(
    List<RoutineOccurrence> occurrences,
    Map<String, Routine> routineById, {
    String calendarName = 'CogniPlan Routine Plan',
    DateTime? generatedAt,
  }) {
    final stamp = _formatUtc((generatedAt ?? DateTime.now()).toUtc());
    final ordered = List<RoutineOccurrence>.from(occurrences)
      ..sort((left, right) {
        final dateCompare = left.occurrenceDate.compareTo(right.occurrenceDate);
        if (dateCompare != 0) {
          return dateCompare;
        }
        return left.id.compareTo(right.id);
      });
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//CogniPlan//Routine Export//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      'X-WR-CALNAME:${_escape(calendarName)}',
      'X-WR-TIMEZONE:UTC',
    ];
    for (final occurrence in ordered) {
      final routine = routineById[occurrence.routineId];
      final start = occurrence.scheduledStart;
      final end = occurrence.scheduledEnd;
      if (routine == null || start == null || end == null || !end.isAfter(start)) {
        continue;
      }
      lines.addAll([
        'BEGIN:VEVENT',
        'UID:routine-occurrence-${_safeId(occurrence.id)}@cogniplan.local',
        'DTSTAMP:$stamp',
        'DTSTART:${_formatUtc(start.toUtc())}',
        'DTEND:${_formatUtc(end.toUtc())}',
        'SUMMARY:${_escape(routine.title)}',
        'DESCRIPTION:${_escape(occurrence.notes ?? routine.description ?? 'Routine occurrence')}',
        'STATUS:${occurrence.status == RoutineOccurrenceStatus.skipped ? 'CANCELLED' : 'CONFIRMED'}',
        'X-COGNIPLAN-ROUTINE-ID:${_escape(routine.id)}',
        'X-COGNIPLAN-OCCURRENCE-ID:${_escape(occurrence.id)}',
        'END:VEVENT',
      ]);
    }
    lines.add('END:VCALENDAR');
    return '${lines.expand(_foldLine).join('\r\n')}\r\n';
  }

  RoutineExportBundle exportRoutineBundle({
    required List<Routine> routines,
    List<RoutineGroup> groups = const [],
    String fileName = 'routine_bundle.json',
  }) {
    final orderedRoutines = List<Routine>.from(routines)
      ..sort((left, right) => left.title.compareTo(right.title));
    final orderedGroups = List<RoutineGroup>.from(groups)
      ..sort((left, right) => left.name.compareTo(right.name));
    final payload = {
      'version': 1,
      'routines': orderedRoutines
          .map(
            (routine) => {
              'id': routine.id,
              'title': routine.title,
              'description': routine.description,
              'anchorDate': normalizeDate(routine.anchorDate).toIso8601String(),
              'preferredStartMinuteOfDay': routine.preferredStartMinuteOfDay,
              'preferredDurationMinutes': routine.preferredDurationMinutes,
              'timeWindowStartMinuteOfDay': routine.timeWindowStartMinuteOfDay,
              'timeWindowEndMinuteOfDay': routine.timeWindowEndMinuteOfDay,
              'isFlexible': routine.isFlexible,
              'autoRescheduleMissed': routine.autoRescheduleMissed,
              'countsTowardConsistency': routine.countsTowardConsistency,
              'linkedGoalId': routine.linkedGoalId,
              'linkedProjectId': routine.linkedProjectId,
              'sourceTemplateId': routine.sourceTemplateId,
              'categoryId': routine.categoryId,
              'tagIds': [...routine.tagIds]..sort(),
              'routineType': routine.routineType.name,
              'priority': routine.priority,
              'energyType': routine.energyType,
              'colorHex': routine.colorHex,
              'iconName': routine.iconName,
              'remindersEnabled': routine.remindersEnabled,
              'reminderLeadMinutes': routine.reminderLeadMinutes,
              'repeatRule': {
                'type': routine.repeatRule.type.name,
                'interval': routine.repeatRule.interval,
                'weekdays': [...routine.repeatRule.weekdays]..sort(),
                'dayOfMonth': routine.repeatRule.dayOfMonth,
              },
            },
          )
          .toList(),
      'groups': orderedGroups
          .map(
            (group) => {
              'id': group.id,
              'name': group.name,
              'description': group.description,
              'routineIds': [...group.routineIds]..sort(),
              'linkedGoalId': group.linkedGoalId,
              'linkedProjectId': group.linkedProjectId,
            },
          )
          .toList(),
    };
    return RoutineExportBundle(
      fileName: fileName,
      content: const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  String _buildRRule(Routine routine) {
    switch (routine.repeatRule.type) {
      case RoutineRepeatType.daily:
        return 'FREQ=DAILY;INTERVAL=${routine.repeatRule.interval}';
      case RoutineRepeatType.weekdays:
        return 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR';
      case RoutineRepeatType.selectedWeekdays:
        final days = routine.repeatRule.weekdays.map(_weekdayToken).join(',');
        return 'FREQ=WEEKLY;BYDAY=$days';
      case RoutineRepeatType.weekly:
        return 'FREQ=WEEKLY;INTERVAL=${routine.repeatRule.interval};BYDAY=${_weekdayToken(routine.anchorDate.weekday)}';
      case RoutineRepeatType.monthly:
        final day = routine.repeatRule.dayOfMonth ?? routine.anchorDate.day;
        return 'FREQ=MONTHLY;INTERVAL=${routine.repeatRule.interval};BYMONTHDAY=$day';
    }
  }

  String _weekdayToken(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        throw ArgumentError.value(weekday, 'weekday', 'Unsupported weekday.');
    }
  }

  String _formatUtc(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${value.year.toString().padLeft(4, '0')}'
        '${twoDigits(value.month)}'
        '${twoDigits(value.day)}'
        'T'
        '${twoDigits(value.hour)}'
        '${twoDigits(value.minute)}'
        '${twoDigits(value.second)}'
        'Z';
  }

  String _escape(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('\r\n', r'\n')
        .replaceAll('\n', r'\n')
        .replaceAll(',', r'\,')
        .replaceAll(';', r'\;');
  }

  String _safeId(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_').toLowerCase();
  }

  List<String> _foldLine(String line) {
    const maxLength = 73;
    if (line.length <= maxLength) {
      return [line];
    }
    final chunks = <String>[];
    var cursor = 0;
    while (cursor < line.length) {
      final end = cursor + maxLength < line.length
          ? cursor + maxLength
          : line.length;
      final chunk = line.substring(cursor, end);
      chunks.add(cursor == 0 ? chunk : ' $chunk');
      cursor = end;
    }
    return chunks;
  }
}
