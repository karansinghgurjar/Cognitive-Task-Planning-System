import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/task_dependency.dart';
import 'package:study_flow/features/schedule/domain/schedule_generator_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('ScheduleGeneratorService', () {
    final now = DateTime(2026, 3, 16, 8, 0);

    test('schedules a single task fully inside one slot', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 50)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 12,
              endMinute: 0,
            ),
          ],
        }),
        existingSessions: const [],
        now: now,
      );

      expect(result.generatedSessions, hasLength(1));
      expect(result.generatedSessions.first.taskId, 'task-1');
      expect(result.generatedSessions.first.plannedDurationMinutes, 50);
      expect(result.failures, isEmpty);
    });

    test('splits one task across multiple windows', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 130)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
            const AvailabilityWindow(
              weekday: 1,
              startHour: 11,
              startMinute: 0,
              endHour: 12,
              endMinute: 10,
            ),
          ],
        }),
        existingSessions: const [],
        now: now,
      );

      expect(
        result.generatedSessions.map(
          (session) => session.plannedDurationMinutes,
        ),
        [60, 70],
      );
      expect(result.failures, isEmpty);
    });

    test('uses priority ordering across multiple tasks', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [
          _task('low', priority: 3, minutes: 60),
          _task('high', priority: 1, minutes: 60),
        ],
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
        existingSessions: const [],
        now: now,
      );

      expect(result.generatedSessions.map((session) => session.taskId), [
        'high',
        'low',
      ]);
    });

    test('existing planned sessions block free time', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 120)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 12,
              endMinute: 0,
            ),
          ],
        }),
        existingSessions: [
          PlannedSession(
            id: 'existing',
            taskId: 'other',
            start: DateTime(2026, 3, 16, 10, 0),
            end: DateTime(2026, 3, 16, 11, 0),
          ),
        ],
        now: now,
      );

      expect(
        result.generatedSessions.map(
          (session) => _rangeString(session.start, session.end),
        ),
        ['09:00-10:00', '11:00-12:00'],
      );
    });

    test('skips windows under 25 minutes', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 60)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 9,
              endMinute: 20,
            ),
            const AvailabilityWindow(
              weekday: 1,
              startHour: 10,
              startMinute: 0,
              endHour: 11,
              endMinute: 0,
            ),
          ],
        }),
        existingSessions: const [],
        now: now,
      );

      expect(result.generatedSessions, hasLength(1));
      expect(
        _rangeString(
          result.generatedSessions.first.start,
          result.generatedSessions.first.end,
        ),
        '10:00-11:00',
      );
    });

    test(
      'leaves leftover under 25 minutes unscheduled when it cannot merge',
      () {
        final service = ScheduleGeneratorService(idGenerator: _idGenerator());
        final result = service.generateNext7DaysSchedule(
          tasks: [_task('task-1', priority: 1, minutes: 130)],
          weeklyAvailability: _weeklyAvailability({
            1: [
              const AvailabilityWindow(
                weekday: 1,
                startHour: 9,
                startMinute: 0,
                endHour: 10,
                endMinute: 50,
              ),
            ],
          }),
          existingSessions: const [],
          now: now,
        );

        expect(
          result.generatedSessions.map(
            (session) => session.plannedDurationMinutes,
          ),
          [60, 50],
        );
        expect(result.failures, hasLength(1));
        expect(result.failures.first.unscheduledMinutes, 20);
      },
    );

    test('merges a tiny leftover when it fits in the same window', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 130)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 11,
              endMinute: 10,
            ),
          ],
        }),
        existingSessions: const [],
        now: now,
      );

      expect(
        result.generatedSessions.map(
          (session) => session.plannedDurationMinutes,
        ),
        [60, 70],
      );
      expect(result.failures, isEmpty);
    });

    test('returns partial scheduling when demand exceeds free time', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [_task('task-1', priority: 1, minutes: 180)],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
            const AvailabilityWindow(
              weekday: 1,
              startHour: 11,
              startMinute: 0,
              endHour: 12,
              endMinute: 0,
            ),
          ],
        }),
        existingSessions: const [],
        now: now,
      );

      expect(result.generatedSessions, hasLength(2));
      expect(result.totalScheduledMinutes, 120);
      expect(result.failures, hasLength(1));
      expect(result.failures.first.unscheduledMinutes, 60);
    });

    test('blocks dependent tasks until prerequisites are satisfied', () {
      final service = ScheduleGeneratorService(idGenerator: _idGenerator());
      final result = service.generateNext7DaysSchedule(
        tasks: [
          _task('task-a', priority: 1, minutes: 60),
          _task('task-b', priority: 1, minutes: 60),
        ],
        dependencies: [
          TaskDependency(
            id: 'dep-1',
            taskId: 'task-b',
            dependsOnTaskId: 'task-a',
            createdAt: DateTime(2026, 3, 16),
          ),
        ],
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
        existingSessions: const [],
        now: now,
      );

      expect(result.generatedSessions.map((session) => session.taskId), [
        'task-a',
      ]);
      expect(result.failures, hasLength(1));
      expect(result.failures.single.taskId, 'task-b');
    });
  });
}

Task _task(
  String id, {
  required int priority,
  required int minutes,
  DateTime? dueDate,
  DateTime? createdAt,
}) {
  return Task(
    id: id,
    title: 'Task $id',
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    dueDate: dueDate,
    priority: priority,
    createdAt: createdAt ?? DateTime(2026, 3, 1),
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

String Function() _idGenerator() {
  var counter = 0;
  return () {
    counter += 1;
    return 'session-$counter';
  };
}

String _rangeString(DateTime start, DateTime end) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(start.hour)}:${two(start.minute)}-${two(end.hour)}:${two(end.minute)}';
}
