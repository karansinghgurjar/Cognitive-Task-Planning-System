import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/burnout_insight_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('BurnoutInsightService', () {
    const service = BurnoutInsightService();

    test('flags sustained overload and missed work', () {
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Urgent prep',
          type: TaskType.study,
          estimatedDurationMinutes: 180,
          priority: 1,
          dueDate: DateTime(2026, 3, 15),
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final goals = [
        LearningGoal(
          id: 'goal-1',
          title: 'Exam Prep',
          goalType: GoalType.examPrep,
          targetDate: DateTime(2026, 3, 14),
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final sessions = [
        _session(
          'm1',
          DateTime(2026, 3, 16, 9),
          90,
          PlannedSessionStatus.missed,
        ),
        _session(
          'm2',
          DateTime(2026, 3, 17, 9),
          90,
          PlannedSessionStatus.missed,
        ),
        _session(
          'm3',
          DateTime(2026, 3, 18, 9),
          90,
          PlannedSessionStatus.missed,
        ),
        _session(
          'p1',
          DateTime(2026, 3, 19, 9),
          90,
          PlannedSessionStatus.pending,
        ),
        _session(
          'p2',
          DateTime(2026, 3, 20, 9),
          90,
          PlannedSessionStatus.pending,
        ),
        _session(
          'c1',
          DateTime(2026, 3, 21, 9),
          60,
          PlannedSessionStatus.cancelled,
        ),
      ];
      final availability = {
        for (var weekday = 1; weekday <= 7; weekday++)
          weekday: [
            AvailabilityWindow(
              weekday: weekday,
              startHour: 22,
              startMinute: 0,
              endHour: 23,
              endMinute: 0,
            ),
          ],
      };

      final report = service.evaluate(
        tasks: tasks,
        goals: goals,
        sessions: sessions,
        weeklyAvailability: availability,
        now: DateTime(2026, 3, 21, 12),
      );

      expect(
        report.severity == DeadlineRiskLevel.high ||
            report.severity == DeadlineRiskLevel.critical,
        isTrue,
      );
      expect(report.recentMissedSessions, 3);
      expect(report.hasRestDay, isFalse);
      expect(report.reasons, isNotEmpty);
    });
  });
}

PlannedSession _session(
  String id,
  DateTime start,
  int minutes,
  PlannedSessionStatus status,
) {
  return PlannedSession(
    id: id,
    taskId: 'task-1',
    start: start,
    end: start.add(Duration(minutes: minutes)),
    status: status,
    completed: status == PlannedSessionStatus.completed,
    actualMinutesFocused: status == PlannedSessionStatus.completed
        ? minutes
        : 0,
  );
}
