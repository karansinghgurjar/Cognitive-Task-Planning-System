import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/notifications/notification_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('NotificationService', () {
    test('builds 10-minute and start reminders for future sessions', () {
      final session = PlannedSession(
        id: 'session-1',
        taskId: 'task-1',
        start: DateTime(2026, 3, 16, 10, 0),
        end: DateTime(2026, 3, 16, 11, 0),
      );

      final requests = NotificationService.buildSessionReminderRequests(
        session,
        taskTitle: 'DSA Arrays',
        leadTimeMinutes: 10,
        now: DateTime(2026, 3, 16, 8, 0),
      );

      expect(requests, hasLength(2));
      expect(requests.first.title, 'Focus session starting soon');
      expect(requests.first.when, DateTime(2026, 3, 16, 9, 50));
      expect(requests.last.title, 'Start focus session now');
      expect(requests.last.when, DateTime(2026, 3, 16, 10, 0));
    });

    test('omits past lead reminder when session is too close', () {
      final session = PlannedSession(
        id: 'session-1',
        taskId: 'task-1',
        start: DateTime(2026, 3, 16, 10, 0),
        end: DateTime(2026, 3, 16, 11, 0),
      );

      final requests = NotificationService.buildSessionReminderRequests(
        session,
        taskTitle: 'DSA Arrays',
        leadTimeMinutes: 10,
        now: DateTime(2026, 3, 16, 9, 55),
      );

      expect(requests, hasLength(1));
      expect(requests.single.title, 'Start focus session now');
    });

    test('builds daily summary with session count and top priority task', () {
      final sessions = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-high',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
        ),
        PlannedSession(
          id: 'session-2',
          taskId: 'task-low',
          start: DateTime(2026, 3, 16, 11),
          end: DateTime(2026, 3, 16, 12, 30),
        ),
      ];
      final content = NotificationService.buildDailySummaryContent(
        sessions: sessions,
        taskById: {
          'task-high': Task(
            id: 'task-high',
            title: 'Exam Prep',
            type: TaskType.study,
            estimatedDurationMinutes: 60,
            priority: 1,
            createdAt: DateTime(2026, 3, 1),
          ),
          'task-low': Task(
            id: 'task-low',
            title: 'Project polish',
            type: TaskType.project,
            estimatedDurationMinutes: 90,
            priority: 4,
            createdAt: DateTime(2026, 3, 1),
          ),
        },
        day: DateTime(2026, 3, 16, 6),
      );

      expect(content.title, "Today's Study Plan");
      expect(content.body, contains('2 sessions planned today'));
      expect(content.body, contains('2h 30m'));
      expect(content.body, contains('Exam Prep'));
    });

    test('parses recover action from notification payload', () {
      final payload = NotificationService.encodePayload(
        const NotificationIntent(type: NotificationIntentType.missedSession),
      );

      final intent = NotificationService.parsePayload(
        payload,
        actionId: 'recover_schedule',
      );

      expect(intent, isNotNull);
      expect(intent!.type, NotificationIntentType.missedSession);
      expect(intent.action, NotificationIntentAction.recover);
    });

    test('returns null for malformed notification payload', () {
      final intent = NotificationService.parsePayload('{not-json');

      expect(intent, isNull);
    });
  });
}
