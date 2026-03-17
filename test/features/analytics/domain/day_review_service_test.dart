import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/day_review_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('DayReviewService', () {
    const service = DayReviewService();

    test('summarizes completed work and missed sessions for the day', () {
      final tasks = [
        Task(
          id: 'task-1',
          title: 'Exam prep',
          type: TaskType.study,
          estimatedDurationMinutes: 120,
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
        Task(
          id: 'task-2',
          title: 'Project cleanup',
          type: TaskType.project,
          estimatedDurationMinutes: 90,
          priority: 3,
          createdAt: DateTime(2026, 3, 1),
        ),
      ];
      final sessions = [
        PlannedSession(
          id: 'done',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.completed,
          completed: true,
          actualMinutesFocused: 55,
        ),
        PlannedSession(
          id: 'missed',
          taskId: 'task-2',
          start: DateTime(2026, 3, 16, 12),
          end: DateTime(2026, 3, 16, 13),
          status: PlannedSessionStatus.missed,
        ),
      ];

      final summary = service.summarizeDay(
        day: DateTime(2026, 3, 16, 20),
        now: DateTime(2026, 3, 16, 20),
        sessions: sessions,
        tasks: tasks,
      );

      expect(summary.completedSessions, 1);
      expect(summary.missedSessions, 1);
      expect(summary.totalFocusedMinutes, 55);
      expect(summary.mostImportantCompletedTaskTitle, 'Exam prep');
      expect(
        summary.recommendedNextAction,
        contains('Recover missed sessions'),
      );
    });
  });
}
