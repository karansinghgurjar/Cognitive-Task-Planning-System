import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/application/routine_bulk_action_service.dart';
import 'package:study_flow/features/routines/application/routine_calendar_export_service.dart';
import 'package:study_flow/features/routines/application/routine_focus_bridge_service.dart';
import 'package:study_flow/features/routines/application/routine_group_service.dart';
import 'package:study_flow/features/routines/application/routine_orchestration_service.dart';
import 'package:study_flow/features/routines/application/routine_starter_pack_service.dart';
import 'package:study_flow/features/routines/application/routine_template_service.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';
import 'package:study_flow/features/routines/models/routine_group.dart';
import 'package:study_flow/features/routines/models/routine_occurrence.dart';
import 'package:study_flow/features/routines/models/routine_template.dart';

void main() {
  group('RoutineTemplateService', () {
    test('applying template creates fresh routines with anchor date and shift', () {
      final service = RoutineTemplateService(idGenerator: _incrementingIds());
      final template = RoutineTemplate(
        id: 'template-1',
        name: 'Evening Study System',
        createdAt: DateTime(2026, 4, 9),
        items: [
          RoutineTemplateItem(
            title: 'Reading',
            initialRepeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
            preferredStartMinuteOfDay: 20 * 60,
            preferredDurationMinutes: 60,
          ),
        ],
      );

      final routines = service.applyTemplate(
        template,
        options: RoutineTemplateApplyOptions(
          anchorDate: DateTime(2026, 4, 14),
          timeShiftMinutes: 30,
          goalId: 'goal-1',
          projectId: 'proj-study',
        ),
        now: DateTime(2026, 4, 9, 10),
      );

      expect(routines, hasLength(1));
      expect(routines.single.id, 'id-1');
      expect(routines.single.anchorDate, DateTime(2026, 4, 14));
      expect(routines.single.preferredStartMinuteOfDay, 20 * 60 + 30);
      expect(routines.single.linkedGoalId, 'goal-1');
      expect(routines.single.linkedProjectId, 'proj-study');
      expect(routines.single.sourceTemplateId, 'template-1');
    });

    test('saving routines as template keeps template independent', () {
      final service = RoutineTemplateService(idGenerator: _incrementingIds());
      final routine = _buildRoutine(title: 'Deep Work', startMinute: 540);

      final template = service.buildTemplateFromRoutines(
        name: 'Deep Work Template',
        routines: [routine],
      );
      final applied = service.applyTemplate(
        template,
        options: RoutineTemplateApplyOptions(anchorDate: DateTime(2026, 4, 9)),
      ).single;
      final edited = applied.copyWith(title: 'Edited Routine');

      expect(template.items.single.title, 'Deep Work');
      expect(edited.title, 'Edited Routine');
    });
  });

  group('RoutineStarterPackService', () {
    test('starter packs expose expected routines and metadata', () {
      final packs = const RoutineStarterPackService().getBuiltInPacks(
        now: DateTime(2026, 4, 9),
      );

      expect(packs, isNotEmpty);
      expect(packs.first.template.items, isNotEmpty);
      expect(packs.first.estimatedWeeklyMinutes, greaterThan(0));
    });
  });

  group('RoutineGroupService', () {
    test('groups can assign and filter routines', () {
      final service = const RoutineGroupService();
      final group = RoutineGroup(
        id: 'group-1',
        name: 'Study System',
        createdAt: DateTime(2026, 4, 9),
      );
      final routines = [
        _buildRoutine(id: 'r1', title: 'Reading'),
        _buildRoutine(id: 'r2', title: 'Revision'),
      ];

      final updated = service.assignRoutines(group, routines.map((routine) => routine.id));

      expect(updated.routineIds, ['r1', 'r2']);
      expect(service.filterRoutinesForGroup(updated, routines), hasLength(2));
    });
  });

  group('RoutineOrchestrationService', () {
    test('summaries surface scheduled, flexible debt, and recovery pressure', () {
      final service = const RoutineOrchestrationService();
      final now = DateTime(2026, 4, 9, 12);
      final routines = [
        _buildRoutine(id: 'r1', title: 'Fixed', isFlexible: false),
        _buildRoutine(id: 'r2', title: 'Flexible', isFlexible: true),
      ];
      final occurrences = [
        RoutineOccurrence(
          id: 'o1',
          routineId: 'r1',
          occurrenceDate: DateTime(2026, 4, 9),
          scheduledStart: DateTime(2026, 4, 9, 9),
          scheduledEnd: DateTime(2026, 4, 9, 10),
          createdAt: now,
        ),
        RoutineOccurrence(
          id: 'o2',
          routineId: 'r2',
          occurrenceDate: DateTime(2026, 4, 9),
          status: RoutineOccurrenceStatus.pending,
          needsAttention: true,
          createdAt: now,
        ),
        RoutineOccurrence(
          id: 'o3',
          routineId: 'r1',
          occurrenceDate: DateTime(2026, 4, 8),
          scheduledStart: DateTime(2026, 4, 8, 9),
          scheduledEnd: DateTime(2026, 4, 8, 10),
          createdAt: now,
        ),
      ];

      final daily = service.summarizeDaily(
        routines: routines,
        occurrences: occurrences,
        now: now,
      );

      expect(daily.scheduledRoutineCount, 1);
      expect(daily.flexibleNeedsPlacementCount, 1);
      expect(daily.consistencyCount, 2);
    });
  });

  group('RoutineCalendarExportService', () {
    test('recurring routine export contains RRULE and group bundle is deterministic', () {
      final service = const RoutineCalendarExportService();
      final routine = _buildRoutine(
        id: 'r1',
        title: 'Weekly Review',
        repeatRule: RoutineRepeatRule(type: RoutineRepeatType.weekly),
      );
      final ics = service.generateRecurringRoutineIcs(
        [routine],
        generatedAt: DateTime.utc(2026, 4, 9),
      );
      final bundle = service.exportRoutineBundle(
        routines: [routine],
        groups: [
          RoutineGroup(
            id: 'g1',
            name: 'Review System',
            routineIds: const ['r1'],
            createdAt: DateTime(2026, 4, 9),
          ),
        ],
      );

      expect(ics, contains('RRULE:FREQ=WEEKLY'));
      expect(bundle.content, contains('"routineIds": ['));
      expect(bundle.content, contains('"id": "r1"'));
    });

    test('occurrence range export skips unscheduled items and exports scheduled ones', () {
      final service = const RoutineCalendarExportService();
      final routine = _buildRoutine(id: 'r1', title: 'Deep Work');
      final scheduled = RoutineOccurrence(
        id: 'o1',
        routineId: 'r1',
        occurrenceDate: DateTime(2026, 4, 9),
        scheduledStart: DateTime(2026, 4, 9, 9),
        scheduledEnd: DateTime(2026, 4, 9, 10),
        createdAt: DateTime(2026, 4, 9),
      );
      final unscheduled = RoutineOccurrence(
        id: 'o2',
        routineId: 'r1',
        occurrenceDate: DateTime(2026, 4, 10),
        createdAt: DateTime(2026, 4, 9),
      );

      final ics = service.generateOccurrenceRangeIcs(
        [scheduled, unscheduled],
        {'r1': routine},
      );

      expect(ics, contains('X-COGNIPLAN-OCCURRENCE-ID:o1'));
      expect(ics, isNot(contains('o2')));
    });
  });

  group('RoutineBulkActionService', () {
    test('bulk archive, shift, and project link update routines safely', () {
      final service = const RoutineBulkActionService();
      final routines = [
        _buildRoutine(id: 'r1', title: 'One', startMinute: 600),
        _buildRoutine(id: 'r2', title: 'Two', startMinute: 660),
      ];

      final shifted = service.shiftPreferredTimes(routines, 30);
      final linked = service.linkProject(shifted, 'proj-1');
      final archived = service.archiveAll(linked, now: DateTime(2026, 4, 9));

      expect(archived.every((routine) => routine.isArchived), isTrue);
      expect(archived.first.preferredStartMinuteOfDay, 630);
      expect(archived.first.linkedProjectId, 'proj-1');
    });
  });

  group('RoutineFocusBridgeService', () {
    test('focus bridge creates explicit task and planned session without mutating occurrence', () {
      final service = RoutineFocusBridgeService(idGenerator: _incrementingIds());
      final routine = _buildRoutine(id: 'r1', title: 'Research Reading');
      final occurrence = RoutineOccurrence(
        id: 'o1',
        routineId: 'r1',
        occurrenceDate: DateTime(2026, 4, 9),
        scheduledStart: DateTime(2026, 4, 9, 19),
        scheduledEnd: DateTime(2026, 4, 9, 20),
        createdAt: DateTime(2026, 4, 9),
      );

      final result = service.createFocusArtifacts(
        routine: routine,
        occurrence: occurrence,
        now: DateTime(2026, 4, 9, 18),
      );

      expect(result.task.title, 'Research Reading');
      expect(result.session.taskId, result.task.id);
      expect(result.session.start, DateTime(2026, 4, 9, 19));
      expect(occurrence.status, RoutineOccurrenceStatus.pending);
    });
  });
}

Routine _buildRoutine({
  String id = 'routine-1',
  String title = 'Routine',
  bool isFlexible = true,
  int startMinute = 540,
  RoutineRepeatRule? repeatRule,
}) {
  return Routine(
    id: id,
    title: title,
    createdAt: DateTime(2026, 4, 9),
    anchorDate: DateTime(2026, 4, 9),
    repeatRule: repeatRule ?? RoutineRepeatRule(type: RoutineRepeatType.daily),
    preferredStartMinuteOfDay: startMinute,
    preferredDurationMinutes: 60,
    isFlexible: isFlexible,
  );
}

String Function() _incrementingIds() {
  var counter = 0;
  return () => 'id-${++counter}';
}
