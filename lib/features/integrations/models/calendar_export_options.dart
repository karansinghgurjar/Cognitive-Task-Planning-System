import '../../schedule/models/planned_session.dart';

enum CalendarExportRangePreset { next7Days, next30Days, custom }

class CalendarExportOptions {
  const CalendarExportOptions({
    required this.startDate,
    required this.endDate,
    this.includePendingSessions = true,
    this.includeCompletedSessions = false,
    this.includeMissedSessions = false,
    this.includeCancelledSessions = false,
    this.calendarName = 'CogniPlan Schedule',
    this.fileName,
    this.rangePreset = CalendarExportRangePreset.next7Days,
  });

  final DateTime startDate;
  final DateTime endDate;
  final bool includePendingSessions;
  final bool includeCompletedSessions;
  final bool includeMissedSessions;
  final bool includeCancelledSessions;
  final String calendarName;
  final String? fileName;
  final CalendarExportRangePreset rangePreset;

  factory CalendarExportOptions.next7Days({
    DateTime? now,
    bool includeCompletedSessions = false,
    bool includeMissedSessions = false,
    bool includeCancelledSessions = false,
    String calendarName = 'CogniPlan Schedule',
    String? fileName,
  }) {
    final current = now ?? DateTime.now();
    final start = DateTime(current.year, current.month, current.day);
    return CalendarExportOptions(
      startDate: start,
      endDate: start.add(const Duration(days: 6)),
      includeCompletedSessions: includeCompletedSessions,
      includeMissedSessions: includeMissedSessions,
      includeCancelledSessions: includeCancelledSessions,
      calendarName: calendarName,
      fileName: fileName,
      rangePreset: CalendarExportRangePreset.next7Days,
    );
  }

  factory CalendarExportOptions.next30Days({
    DateTime? now,
    bool includeCompletedSessions = false,
    bool includeMissedSessions = false,
    bool includeCancelledSessions = false,
    String calendarName = 'CogniPlan Schedule',
    String? fileName,
  }) {
    final current = now ?? DateTime.now();
    final start = DateTime(current.year, current.month, current.day);
    return CalendarExportOptions(
      startDate: start,
      endDate: start.add(const Duration(days: 29)),
      includeCompletedSessions: includeCompletedSessions,
      includeMissedSessions: includeMissedSessions,
      includeCancelledSessions: includeCancelledSessions,
      calendarName: calendarName,
      fileName: fileName,
      rangePreset: CalendarExportRangePreset.next30Days,
    );
  }

  CalendarExportOptions copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? includePendingSessions,
    bool? includeCompletedSessions,
    bool? includeMissedSessions,
    bool? includeCancelledSessions,
    String? calendarName,
    String? fileName,
    CalendarExportRangePreset? rangePreset,
  }) {
    return CalendarExportOptions(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includePendingSessions:
          includePendingSessions ?? this.includePendingSessions,
      includeCompletedSessions:
          includeCompletedSessions ?? this.includeCompletedSessions,
      includeMissedSessions:
          includeMissedSessions ?? this.includeMissedSessions,
      includeCancelledSessions:
          includeCancelledSessions ?? this.includeCancelledSessions,
      calendarName: calendarName ?? this.calendarName,
      fileName: fileName ?? this.fileName,
      rangePreset: rangePreset ?? this.rangePreset,
    );
  }

  DateTime get normalizedStart =>
      DateTime(startDate.year, startDate.month, startDate.day);

  DateTime get normalizedEndExclusive =>
      DateTime(endDate.year, endDate.month, endDate.day + 1);

  bool get hasAnyIncludedStatus =>
      includePendingSessions ||
      includeCompletedSessions ||
      includeMissedSessions ||
      includeCancelledSessions;

  bool containsSessionStatus(PlannedSession session) {
    if (session.isCancelled) {
      return includeCancelledSessions;
    }
    if (session.isMissed) {
      return includeMissedSessions;
    }
    if (session.isCompleted) {
      return includeCompletedSessions;
    }
    return includePendingSessions;
  }
}
