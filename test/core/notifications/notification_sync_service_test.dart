import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/notifications/notification_sync_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';

void main() {
  group('NotificationSyncService', () {
    test('identifies sessions that became missed', () {
      final previous = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.pending,
        ),
      ];
      final current = [
        PlannedSession(
          id: 'session-1',
          taskId: 'task-1',
          start: DateTime(2026, 3, 16, 9),
          end: DateTime(2026, 3, 16, 10),
          status: PlannedSessionStatus.missed,
        ),
        PlannedSession(
          id: 'session-2',
          taskId: 'task-2',
          start: DateTime(2026, 3, 16, 11),
          end: DateTime(2026, 3, 16, 12),
          status: PlannedSessionStatus.pending,
        ),
      ];

      final missed = NotificationSyncService.identifyNewlyMissedSessions(
        previousSessions: previous,
        currentSessions: current,
      );

      expect(missed.map((session) => session.id), ['session-1']);
    });
  });
}
