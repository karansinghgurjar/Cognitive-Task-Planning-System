import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/schedule/domain/missed_session_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';

void main() {
  const service = MissedSessionService();
  final now = DateTime(2026, 3, 16, 12, 0);

  group('MissedSessionService', () {
    test('marks past pending sessions as missed', () {
      final sessions = [
        _session(
          id: 'pending',
          start: DateTime(2026, 3, 16, 9, 0),
          end: DateTime(2026, 3, 16, 10, 0),
          status: PlannedSessionStatus.pending,
        ),
      ];

      final missed = service.detectMissedSessions(sessions, now);

      expect(missed, hasLength(1));
      expect(missed.single.status, PlannedSessionStatus.missed);
    });

    test('marks stale in-progress sessions as missed', () {
      final sessions = [
        _session(
          id: 'running',
          start: DateTime(2026, 3, 16, 9, 0),
          end: DateTime(2026, 3, 16, 10, 0),
          status: PlannedSessionStatus.inProgress,
        ),
      ];

      final missed = service.detectMissedSessions(sessions, now);

      expect(missed, hasLength(1));
      expect(missed.single.status, PlannedSessionStatus.missed);
    });

    test('never marks completed sessions as missed', () {
      final sessions = [
        _session(
          id: 'done',
          start: DateTime(2026, 3, 16, 9, 0),
          end: DateTime(2026, 3, 16, 10, 0),
          status: PlannedSessionStatus.completed,
          completed: true,
        ),
      ];

      final missed = service.detectMissedSessions(sessions, now);

      expect(missed, isEmpty);
    });

    test('keeps cancelled sessions cancelled', () {
      final sessions = [
        _session(
          id: 'cancelled',
          start: DateTime(2026, 3, 16, 9, 0),
          end: DateTime(2026, 3, 16, 10, 0),
          status: PlannedSessionStatus.cancelled,
        ),
      ];

      final missed = service.detectMissedSessions(sessions, now);

      expect(missed, isEmpty);
    });
  });
}

PlannedSession _session({
  required String id,
  required DateTime start,
  required DateTime end,
  required PlannedSessionStatus status,
  bool completed = false,
}) {
  return PlannedSession(
    id: id,
    taskId: 'task-1',
    start: start,
    end: end,
    status: status,
    completed: completed,
  );
}
