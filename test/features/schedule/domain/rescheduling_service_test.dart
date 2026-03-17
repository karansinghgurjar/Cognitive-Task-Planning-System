import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/schedule/domain/rescheduling_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  final now = DateTime(2026, 3, 16, 8, 0);

  group('ReschedulingService', () {
    test('prioritizes overdue tasks before non-overdue tasks', () {
      final service = ReschedulingService();
      final result = service.recoverAndReschedule(
        tasks: [
          _task('future', 1, 60, dueDate: DateTime(2026, 3, 20)),
          _task('overdue', 3, 60, dueDate: DateTime(2026, 3, 15)),
        ],
        sessions: const [],
        missedSessions: const [],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 11,
              endMinute: 0,
            ),
          ],
        }),
        now: now,
      );

      expect(result.rescheduledSessions.map((session) => session.taskId), [
        'overdue',
        'future',
      ]);
    });

    test('preserves completed sessions and active in-progress session', () {
      final service = ReschedulingService();
      final completedSession = _session(
        id: 'completed',
        taskId: 'task-a',
        start: DateTime(2026, 3, 16, 9, 0),
        end: DateTime(2026, 3, 16, 10, 0),
        status: PlannedSessionStatus.completed,
        completed: true,
      );
      final activeSession = _session(
        id: 'active',
        taskId: 'task-b',
        start: DateTime(2026, 3, 16, 10, 0),
        end: DateTime(2026, 3, 16, 11, 0),
        status: PlannedSessionStatus.inProgress,
      );
      final pendingSession = _session(
        id: 'pending',
        taskId: 'task-c',
        start: DateTime(2026, 3, 16, 11, 0),
        end: DateTime(2026, 3, 16, 12, 0),
        status: PlannedSessionStatus.pending,
      );

      final result = service.recoverAndReschedule(
        tasks: [_task('task-d', 1, 60)],
        sessions: [completedSession, activeSession, pendingSession],
        missedSessions: const [],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 13,
              endMinute: 0,
            ),
          ],
        }),
        now: now,
        activeSessionId: 'active',
      );

      expect(result.droppedSessions.map((session) => session.id), ['pending']);
      expect(
        result.rescheduledSessions.single.start,
        DateTime(2026, 3, 16, 11, 0),
      );
    });

    test('returns partial recovery when demand exceeds free time', () {
      final service = ReschedulingService();
      final result = service.recoverAndReschedule(
        tasks: [_task('task-a', 1, 180)],
        sessions: const [],
        missedSessions: [
          _session(
            id: 'missed-1',
            taskId: 'task-a',
            start: DateTime(2026, 3, 15, 9, 0),
            end: DateTime(2026, 3, 15, 10, 0),
            status: PlannedSessionStatus.missed,
          ),
        ],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
          ],
        }),
        now: now,
      );

      expect(result.summary.totalRecoveredMinutes, 60);
      expect(result.summary.totalUnscheduledMinutes, 120);
    });

    test(
      'does not reschedule tasks already satisfied by completed sessions',
      () {
        final service = ReschedulingService();
        final result = service.recoverAndReschedule(
          tasks: [_task('task-a', 1, 60)],
          sessions: [
            _session(
              id: 'done',
              taskId: 'task-a',
              start: DateTime(2026, 3, 16, 7, 0),
              end: DateTime(2026, 3, 16, 8, 0),
              status: PlannedSessionStatus.completed,
              completed: true,
            ),
          ],
          missedSessions: const [],
          weeklyAvailability: _weeklyAvailability({
            1: [
              const AvailabilityWindow(
                weekday: 1,
                startHour: 9,
                startMinute: 0,
                endHour: 10,
                endMinute: 0,
              ),
            ],
          }),
          now: now,
        );

        expect(result.rescheduledSessions, isEmpty);
      },
    );
  });
}

Task _task(String id, int priority, int minutes, {DateTime? dueDate}) {
  return Task(
    id: id,
    title: id,
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    priority: priority,
    dueDate: dueDate,
    createdAt: DateTime(2026, 3, 1),
  );
}

PlannedSession _session({
  required String id,
  required String taskId,
  required DateTime start,
  required DateTime end,
  required PlannedSessionStatus status,
  bool completed = false,
}) {
  return PlannedSession(
    id: id,
    taskId: taskId,
    start: start,
    end: end,
    status: status,
    completed: completed,
    actualMinutesFocused: completed ? end.difference(start).inMinutes : 0,
  );
}

Map<int, List<AvailabilityWindow>> _weeklyAvailability(
  Map<int, List<AvailabilityWindow>> data,
) {
  return {
    for (var weekday = 1; weekday <= 7; weekday++)
      weekday: data[weekday] ?? const [],
  };
}
