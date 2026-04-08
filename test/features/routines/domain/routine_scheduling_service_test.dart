import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/domain/routine_date_utils.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_generation_service.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/domain/routine_sync_service.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';

void main() {
  group('RoutineGenerationService', () {
    final anchor = DateTime(2026, 4, 8);
    final service = RoutineGenerationService(idGenerator: () => 'occurrence-id');

    Routine buildRoutine({
      required String id,
      required RoutineRepeatRule rule,
      int? startMinute = 18 * 60,
      int? duration = 60,
      bool isArchived = false,
      DateTime? anchorDate,
    }) {
      return Routine(
        id: id,
        title: 'Routine $id',
        createdAt: anchor,
        anchorDate: anchorDate ?? anchor,
        repeatRule: rule,
        preferredStartMinuteOfDay: startMinute,
        preferredDurationMinutes: duration,
        isArchived: isArchived,
      );
    }

    test('evaluates daily interval repeat deterministically', () {
      final routine = buildRoutine(
        id: 'daily',
        rule: RoutineRepeatRule(
          type: RoutineRepeatType.daily,
          interval: 2,
        ),
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 14),
      );

      expect(
        dates.map((date) => normalizeDate(date).day).toList(),
        [8, 10, 12, 14],
      );
    });

    test('evaluates weekdays repeat without weekends', () {
      final routine = buildRoutine(
        id: 'weekdays',
        rule: RoutineRepeatRule(type: RoutineRepeatType.weekdays),
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 14),
      );

      expect(dates.every((date) => date.weekday <= DateTime.friday), isTrue);
      expect(dates.map((date) => date.day).toList(), [8, 9, 10, 13, 14]);
    });

    test('evaluates selected weekdays repeat', () {
      final routine = buildRoutine(
        id: 'selected',
        rule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
        ),
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 17),
      );

      expect(dates.map((date) => date.weekday).toList(), [
        DateTime.wednesday,
        DateTime.friday,
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
      ]);
    });

    test('evaluates weekly interval using anchor weekday', () {
      final routine = buildRoutine(
        id: 'weekly',
        rule: RoutineRepeatRule(
          type: RoutineRepeatType.weekly,
          interval: 2,
        ),
        anchorDate: DateTime(2026, 4, 8),
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 5, 10),
      );

      expect(
        dates.map((date) => '${date.month}-${date.day}').toList(),
        ['4-8', '4-22', '5-6'],
      );
    });

    test('evaluates monthly repeat and skips invalid calendar dates', () {
      final routine = buildRoutine(
        id: 'monthly',
        rule: RoutineRepeatRule(
          type: RoutineRepeatType.monthly,
          dayOfMonth: 31,
        ),
        anchorDate: DateTime(2026, 1, 31),
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 1, 31),
        endDate: DateTime(2026, 5, 31),
      );

      expect(
        dates.map((date) => '${date.month}-${date.day}').toList(),
        ['1-31', '3-31', '5-31'],
      );
    });

    test('builds occurrence with materialized schedule when start and duration exist', () {
      final routine = buildRoutine(
        id: 'materialized',
        rule: RoutineRepeatRule(type: RoutineRepeatType.daily),
      );

      final occurrence = service.buildOccurrence(
        routine,
        DateTime(2026, 4, 10),
        generatedAt: DateTime(2026, 4, 8, 9),
      );

      expect(occurrence.occurrenceDate, DateTime(2026, 4, 10));
      expect(occurrence.scheduledStart, DateTime(2026, 4, 10, 18));
      expect(occurrence.scheduledEnd, DateTime(2026, 4, 10, 19));
      expect(occurrence.occurrenceKey, 'materialized|20260410');
    });

    test('builds occurrence without scheduled end when duration is absent', () {
      final routine = buildRoutine(
        id: 'partial',
        rule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        duration: null,
      );

      final occurrence = service.buildOccurrence(routine, DateTime(2026, 4, 10));

      expect(occurrence.scheduledStart, DateTime(2026, 4, 10, 18));
      expect(occurrence.scheduledEnd, isNull);
    });

    test('does not generate occurrences for archived routines', () {
      final routine = buildRoutine(
        id: 'archived',
        rule: RoutineRepeatRule(type: RoutineRepeatType.daily),
        isArchived: true,
      );

      final dates = service.computeOccurrenceDates(
        routine,
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 12),
      );

      expect(dates, isEmpty);
    });

    test('normalizes date utilities and builds stable occurrence key', () {
      expect(normalizeDate(DateTime(2026, 4, 8, 20, 15)), DateTime(2026, 4, 8));
      expect(daysBetween(DateTime(2026, 4, 8), DateTime(2026, 4, 10)), 2);
      expect(weeksBetween(DateTime(2026, 4, 8), DateTime(2026, 4, 22)), 2);
      expect(monthsBetween(DateTime(2026, 1, 8), DateTime(2026, 4, 8)), 3);
      expect(buildOccurrenceKey('routine-1', DateTime(2026, 4, 8)), 'routine-1|20260408');
      expect(tryCreateDate(2026, 2, 31), isNull);
    });
  });

  group('RoutineSyncService', () {
    test('creates only missing occurrences and preserves existing history', () async {
      final repository = _MemoryRoutinePersistence();
      final generation = RoutineGenerationService(idGenerator: repository.nextId);
      final syncService = RoutineSyncService(
        persistence: repository,
        generationService: generation,
      );

      final routine = Routine(
        id: 'routine-1',
        title: 'Workout',
        createdAt: DateTime(2026, 4, 8),
        anchorDate: DateTime(2026, 4, 8),
        repeatRule: RoutineRepeatRule(
          type: RoutineRepeatType.selectedWeekdays,
          weekdays: const [DateTime.wednesday, DateTime.friday],
        ),
        preferredStartMinuteOfDay: 18 * 60 + 30,
        preferredDurationMinutes: 60,
      );
      repository.routines.add(routine);
      repository.occurrences.add(
        RoutineOccurrence(
          id: 'existing',
          routineId: 'routine-1',
          occurrenceDate: DateTime(2026, 4, 8),
          scheduledStart: DateTime(2026, 4, 8, 18, 30),
          scheduledEnd: DateTime(2026, 4, 8, 19, 30),
          status: RoutineOccurrenceStatus.completed,
          createdAt: DateTime(2026, 4, 8, 19, 31),
          updatedAt: DateTime(2026, 4, 8, 19, 31),
          completedAt: DateTime(2026, 4, 8, 19, 31),
        ),
      );

      await syncService.syncAllRoutines(
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 12),
      );

      expect(repository.occurrences, hasLength(2));
      expect(
        repository.occurrences.where((item) => item.occurrenceDate == DateTime(2026, 4, 8)),
        hasLength(1),
      );
      expect(
        repository.occurrences.map((item) => item.occurrenceDate.day).toList()..sort(),
        [8, 10],
      );
    });

    test('single-routine sync ignores archived routines', () async {
      final repository = _MemoryRoutinePersistence();
      final syncService = RoutineSyncService(
        persistence: repository,
        generationService: RoutineGenerationService(idGenerator: repository.nextId),
      );

      repository.routines.add(
        Routine(
          id: 'routine-1',
          title: 'Archived',
          createdAt: DateTime(2026, 4, 8),
          anchorDate: DateTime(2026, 4, 8),
          repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
          isArchived: true,
        ),
      );

      await syncService.syncRoutine(
        'routine-1',
        startDate: DateTime(2026, 4, 8),
        endDate: DateTime(2026, 4, 10),
      );

      expect(repository.occurrences, isEmpty);
    });
  });
}

class _MemoryRoutinePersistence implements RoutinePersistence {
  final List<Routine> routines = [];
  final List<RoutineOccurrence> occurrences = [];
  var _counter = 0;

  String nextId() => 'generated-${_counter++}';

  @override
  Future<List<Routine>> getAllRoutines() async => List<Routine>.from(routines);

  @override
  Future<Routine?> getRoutineById(String id) async {
    for (final routine in routines) {
      if (routine.id == id) {
        return routine;
      }
    }
    return null;
  }

  @override
  Future<List<RoutineOccurrence>> getOccurrencesForRoutine(
    String routineId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return occurrences.where((item) {
      if (item.routineId != routineId) {
        return false;
      }
      if (startDate != null && item.occurrenceDate.isBefore(normalizeDate(startDate))) {
        return false;
      }
      if (endDate != null && item.occurrenceDate.isAfter(normalizeDate(endDate))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<RoutineOccurrence>> getOccurrencesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return occurrences.where((item) {
      return !item.occurrenceDate.isBefore(normalizeDate(startDate)) &&
          !item.occurrenceDate.isAfter(normalizeDate(endDate));
    }).toList();
  }

  @override
  Future<void> saveOccurrences(List<RoutineOccurrence> values) async {
    final byKey = {for (final item in occurrences) item.occurrenceKey: item};
    for (final value in values) {
      byKey[value.occurrenceKey] = value;
    }
    occurrences
      ..clear()
      ..addAll(byKey.values);
  }
}
