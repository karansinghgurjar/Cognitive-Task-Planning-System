import 'analytics_models.dart';
import '../domain/analytics_service.dart';
import '../../schedule/models/planned_session.dart';

class StreakService {
  const StreakService({
    this.analyticsService = const AnalyticsService(),
    this.minimumFocusMinutes = 25,
  });

  final AnalyticsService analyticsService;
  final int minimumFocusMinutes;

  StreakInfo computeCurrentStreak({
    required List<PlannedSession> sessions,
    required DateTime now,
  }) {
    final qualifyingDays = _qualifyingFocusDays(sessions);
    final today = _startOfDay(now);
    var cursor = qualifyingDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    if (!qualifyingDays.contains(cursor)) {
      return const StreakInfo(
        length: 0,
        startDate: null,
        endDate: null,
        isActive: false,
      );
    }

    var length = 0;
    final endDate = cursor;
    while (qualifyingDays.contains(cursor)) {
      length += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StreakInfo(
      length: length,
      startDate: cursor.add(const Duration(days: 1)),
      endDate: endDate,
      isActive: qualifyingDays.contains(today),
    );
  }

  StreakInfo computeLongestStreak({required List<PlannedSession> sessions}) {
    final days = _qualifyingFocusDays(sessions).toList()..sort();
    if (days.isEmpty) {
      return const StreakInfo(
        length: 0,
        startDate: null,
        endDate: null,
        isActive: false,
      );
    }

    var bestLength = 0;
    DateTime? bestStart;
    DateTime? bestEnd;
    var currentLength = 0;
    DateTime? currentStart;
    DateTime? previous;

    for (final day in days) {
      if (previous == null || day.difference(previous).inDays != 1) {
        currentLength = 1;
        currentStart = day;
      } else {
        currentLength += 1;
      }

      if (currentLength > bestLength) {
        bestLength = currentLength;
        bestStart = currentStart;
        bestEnd = day;
      }
      previous = day;
    }

    return StreakInfo(
      length: bestLength,
      startDate: bestStart,
      endDate: bestEnd,
      isActive: false,
    );
  }

  StreakInfo computeCurrentCompletionStreak({
    required List<PlannedSession> sessions,
    required DateTime now,
  }) {
    final completionDays = _qualifyingCompletionDays(sessions);
    final today = _startOfDay(now);
    var cursor = completionDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    if (!completionDays.contains(cursor)) {
      return const StreakInfo(
        length: 0,
        startDate: null,
        endDate: null,
        isActive: false,
      );
    }

    var length = 0;
    final endDate = cursor;
    while (completionDays.contains(cursor)) {
      length += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StreakInfo(
      length: length,
      startDate: cursor.add(const Duration(days: 1)),
      endDate: endDate,
      isActive: completionDays.contains(today),
    );
  }

  Set<DateTime> _qualifyingFocusDays(List<PlannedSession> sessions) {
    final completedMinutesByDay = <DateTime, int>{};
    for (final session in sessions.where((item) => item.isCompleted)) {
      final day = _startOfDay(session.start);
      completedMinutesByDay.update(
        day,
        (value) => value + analyticsService.completedMinutesForSession(session),
        ifAbsent: () => analyticsService.completedMinutesForSession(session),
      );
    }

    return completedMinutesByDay.entries
        .where((entry) => entry.value >= minimumFocusMinutes)
        .map((entry) => entry.key)
        .toSet();
  }

  Set<DateTime> _qualifyingCompletionDays(List<PlannedSession> sessions) {
    final plannedByDay = <DateTime, int>{};
    final completedByDay = <DateTime, int>{};

    for (final session in sessions) {
      final day = _startOfDay(session.start);
      plannedByDay.update(
        day,
        (value) => value + session.plannedDurationMinutes,
        ifAbsent: () => session.plannedDurationMinutes,
      );
      if (session.isCompleted) {
        completedByDay.update(
          day,
          (value) =>
              value + analyticsService.completedMinutesForSession(session),
          ifAbsent: () => analyticsService.completedMinutesForSession(session),
        );
      }
    }

    return plannedByDay.entries
        .where((entry) => entry.value > 0)
        .where((entry) => (completedByDay[entry.key] ?? 0) >= entry.value)
        .map((entry) => entry.key)
        .toSet();
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
