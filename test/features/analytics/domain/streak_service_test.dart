import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/streak_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';

void main() {
  group('StreakService', () {
    const service = StreakService();

    test('computes current and longest focus streak with gaps', () {
      final sessions = [
        _completedSession('a', DateTime(2026, 3, 10), 30),
        _completedSession('b', DateTime(2026, 3, 11), 30),
        _completedSession('c', DateTime(2026, 3, 12), 30),
        _completedSession('d', DateTime(2026, 3, 13), 30),
        _completedSession('e', DateTime(2026, 3, 15), 30),
      ];

      final current = service.computeCurrentStreak(
        sessions: sessions,
        now: DateTime(2026, 3, 16, 12),
      );
      final longest = service.computeLongestStreak(sessions: sessions);

      expect(current.length, 1);
      expect(current.isActive, false);
      expect(current.endDate, DateTime(2026, 3, 15));
      expect(longest.length, 4);
      expect(longest.startDate, DateTime(2026, 3, 10));
      expect(longest.endDate, DateTime(2026, 3, 13));
    });

    test('computes current daily completion streak', () {
      final sessions = [
        _completedSession('day1', DateTime(2026, 3, 14), 30, planned: 30),
        _completedSession('day2', DateTime(2026, 3, 15), 60, planned: 60),
        PlannedSession(
          id: 'day3-incomplete',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.pending,
        ),
      ];

      final streak = service.computeCurrentCompletionStreak(
        sessions: sessions,
        now: DateTime(2026, 3, 16, 18),
      );

      expect(streak.length, 2);
      expect(streak.isActive, false);
      expect(streak.startDate, DateTime(2026, 3, 14));
      expect(streak.endDate, DateTime(2026, 3, 15));
    });
  });
}

PlannedSession _completedSession(
  String id,
  DateTime day,
  int actualMinutes, {
  int? planned,
}) {
  final plannedMinutes = planned ?? actualMinutes;
  return PlannedSession(
    id: id,
    taskId: 'task-$id',
    start: DateTime(day.year, day.month, day.day, 9),
    end: DateTime(
      day.year,
      day.month,
      day.day,
      9,
    ).add(Duration(minutes: plannedMinutes)),
    status: PlannedSessionStatus.completed,
    completed: true,
    actualMinutesFocused: actualMinutes,
  );
}
