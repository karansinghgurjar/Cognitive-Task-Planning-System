import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/domain/routine_scheduling_service.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/timetable/models/timetable_slot.dart';

void main() {
  group('RoutineSchedulingService', () {
    final service = RoutineSchedulingService(idGenerator: () => 'occurrence-id');
    final now = DateTime(2026, 4, 7, 9);
    final allDayFreeSlots = List.generate(7, (index) {
      return TimetableSlot(
        id: 'slot-${index + 1}',
        weekday: index + 1,
        startHour: 0,
        startMinute: 0,
        endHour: 0,
        endMinute: 0,
        isBusy: false,
        label: 'Free',
      );
    });

    test('generates daily routines across the range', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Daily Revision',
            durationMinutes: 30,
            cadenceType: RoutineCadenceType.daily,
            preferredStartHour: 19,
            preferredStartMinute: 0,
            createdAt: now,
          ),
        ],
        timetableSlots: allDayFreeSlots,
        plannedSessions: const [],
        start: now,
        end: now.add(const Duration(days: 3)),
        now: now,
      );

      expect(result.generatedOccurrences, hasLength(4));
      expect(
        result.generatedOccurrences.map((item) => item.scheduledStart.day).toList(),
        [7, 8, 9, 10],
      );
    });

    test('filters custom weekday routines correctly', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Project Deep Work',
            durationMinutes: 60,
            cadenceType: RoutineCadenceType.customWeekdays,
            weekdays: const [DateTime.monday, DateTime.wednesday],
            preferredStartHour: 21,
            preferredStartMinute: 0,
            createdAt: DateTime(2026, 4, 6, 8),
          ),
        ],
        timetableSlots: allDayFreeSlots,
        plannedSessions: const [],
        start: DateTime(2026, 4, 6, 8),
        end: DateTime(2026, 4, 10, 23, 59),
        now: DateTime(2026, 4, 6, 8),
      );

      expect(result.generatedOccurrences, hasLength(2));
      expect(
        result.generatedOccurrences.map((item) => item.scheduledStart.weekday).toList(),
        [DateTime.monday, DateTime.wednesday],
      );
    });

    test('uses preferred time when it is conflict-free', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Meditation',
            durationMinutes: 15,
            cadenceType: RoutineCadenceType.daily,
            preferredStartHour: 6,
            preferredStartMinute: 30,
            createdAt: now,
          ),
        ],
        timetableSlots: allDayFreeSlots,
        plannedSessions: const [],
        start: DateTime(2026, 4, 8, 0),
        end: DateTime(2026, 4, 9, 0),
        now: now,
      );

      expect(result.generatedOccurrences.single.scheduledStart.hour, 6);
      expect(result.generatedOccurrences.single.scheduledStart.minute, 30);
    });

    test('skips conflicting preferred-time occurrences', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Weekly Review',
            durationMinutes: 30,
            cadenceType: RoutineCadenceType.weekly,
            weekdays: const [DateTime.tuesday],
            preferredStartHour: 20,
            preferredStartMinute: 0,
            isFlexible: false,
            createdAt: now,
          ),
        ],
        timetableSlots: [
          TimetableSlot(
            id: 'busy-1',
            weekday: DateTime.tuesday,
            startHour: 19,
            startMinute: 30,
            endHour: 21,
            endMinute: 0,
            isBusy: true,
            label: 'Busy',
          ),
        ],
        plannedSessions: const [],
        start: now,
        end: now.add(const Duration(days: 1)),
        now: now,
      );

      expect(result.generatedOccurrences, isEmpty);
      expect(result.skippedOccurrences.single.reason, RoutineSkipReason.conflictAtPreferredTime);
    });

    test('excludes inactive routines', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Inactive',
            isActive: false,
            durationMinutes: 30,
            cadenceType: RoutineCadenceType.daily,
            createdAt: now,
          ),
        ],
        timetableSlots: allDayFreeSlots,
        plannedSessions: const [],
        start: now,
        end: now.add(const Duration(days: 2)),
        now: now,
      );

      expect(result.generatedOccurrences, isEmpty);
    });

    test('excludes archived routines', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Archived',
            isArchived: true,
            durationMinutes: 30,
            cadenceType: RoutineCadenceType.daily,
            createdAt: now,
          ),
        ],
        timetableSlots: allDayFreeSlots,
        plannedSessions: const [],
        start: now,
        end: now.add(const Duration(days: 2)),
        now: now,
      );

      expect(result.generatedOccurrences, isEmpty);
    });

    test('places routines in the first available slot when no preferred time exists', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Gym',
            durationMinutes: 45,
            cadenceType: RoutineCadenceType.daily,
            createdAt: now,
          ),
        ],
        timetableSlots: [
          TimetableSlot(
            id: 'busy-1',
            weekday: DateTime.wednesday,
            startHour: 6,
            startMinute: 0,
            endHour: 8,
            endMinute: 0,
            isBusy: true,
            label: 'Busy',
          ),
        ],
        plannedSessions: const [],
        start: DateTime(2026, 4, 8, 0),
        end: DateTime(2026, 4, 9, 0),
        now: now,
      );

      expect(result.generatedOccurrences.single.scheduledStart.hour, 8);
      expect(result.generatedOccurrences.single.scheduledStart.minute, 0);
    });

    test('keeps flexible routines inside their preferred time window', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Reading',
            durationMinutes: 45,
            cadenceType: RoutineCadenceType.daily,
            preferredStartHour: 21,
            preferredStartMinute: 0,
            timeWindowStartMinute: 20 * 60,
            timeWindowEndMinute: 22 * 60,
            createdAt: now,
          ),
        ],
        timetableSlots: [
          TimetableSlot(
            id: 'busy-1',
            weekday: DateTime.wednesday,
            startHour: 20,
            startMinute: 0,
            endHour: 21,
            endMinute: 15,
            isBusy: true,
            label: 'Busy',
          ),
        ],
        plannedSessions: const [],
        start: DateTime(2026, 4, 8, 0),
        end: DateTime(2026, 4, 9, 0),
        now: now,
      );

      expect(result.generatedOccurrences.single.scheduledStart.hour, 21);
      expect(result.generatedOccurrences.single.scheduledStart.minute, 15);
    });

    test('skips flexible routines when no slot exists inside the time window', () {
      final result = service.generateOccurrences(
        routines: [
          Routine(
            id: 'routine-1',
            title: 'Project Work',
            durationMinutes: 60,
            cadenceType: RoutineCadenceType.daily,
            timeWindowStartMinute: 20 * 60,
            timeWindowEndMinute: 21 * 60,
            createdAt: now,
          ),
        ],
        timetableSlots: [
          TimetableSlot(
            id: 'busy-1',
            weekday: DateTime.wednesday,
            startHour: 20,
            startMinute: 0,
            endHour: 21,
            endMinute: 0,
            isBusy: true,
            label: 'Busy',
          ),
        ],
        plannedSessions: const [],
        start: DateTime(2026, 4, 8, 0),
        end: DateTime(2026, 4, 9, 0),
        now: now,
      );

      expect(result.generatedOccurrences, isEmpty);
      expect(
        result.skippedOccurrences.single.reason,
        RoutineSkipReason.noAvailableSlotInWindow,
      );
    });

    test('computes the next occurrence preview', () {
      final preview = service.nextOccurrencePreview(
        routine: Routine(
          id: 'routine-1',
          title: 'Evening Practice',
          durationMinutes: 45,
          cadenceType: RoutineCadenceType.daily,
          preferredStartHour: 19,
          preferredStartMinute: 0,
          createdAt: now,
        ),
        timetableSlots: allDayFreeSlots,
        plannedSessions: [
          PlannedSession(
            id: 'session-1',
            taskId: 'task-1',
            start: DateTime(2026, 4, 7, 18),
            end: DateTime(2026, 4, 7, 18, 30),
          ),
        ],
        now: now,
      );

      expect(preview, isNotNull);
      expect(preview!.scheduledStart.hour, 19);
      expect(preview.scheduledStart.day, 7);
    });
  });
}
