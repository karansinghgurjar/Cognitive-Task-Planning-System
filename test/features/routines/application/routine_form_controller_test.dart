import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/routines/application/routine_form_controller.dart';
import 'package:study_flow/features/routines/domain/routine_enums.dart';
import 'package:study_flow/features/routines/domain/routine_repeat_rule.dart';
import 'package:study_flow/features/routines/models/routine.dart';

import '../test_helpers.dart';

void main() {
  test('create mode initializes sane defaults', () {
    final controller = RoutineFormController(
      loadRepository: () async => FakeRoutineRepository(),
      deleteOccurrencesForRoutine: (_) async {},
      loadSyncService: () async => FakeRoutineSyncService(),
      nowProvider: () => DateTime(2026, 4, 9, 10),
    );

    expect(controller.state.mode, RoutineFormMode.create);
    expect(controller.state.interval, 1);
    expect(controller.state.repeatType, RoutineRepeatType.daily);
    expect(controller.state.isFlexible, isTrue);
    expect(controller.state.autoRescheduleMissed, isTrue);
  });

  test('edit mode loads existing routine', () {
    final routine = Routine(
      id: 'routine-1',
      title: 'Workout',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(
        type: RoutineRepeatType.selectedWeekdays,
        weekdays: [1, 3, 5],
      ),
      preferredDurationMinutes: 60,
      preferredStartMinuteOfDay: 18 * 60,
    );

    final controller = RoutineFormController(
      loadRepository: () async => FakeRoutineRepository(),
      deleteOccurrencesForRoutine: (_) async {},
      loadSyncService: () async => FakeRoutineSyncService(),
      nowProvider: () => DateTime(2026, 4, 9, 10),
      initialRoutine: routine,
    );

    expect(controller.state.mode, RoutineFormMode.edit);
    expect(controller.state.title, 'Workout');
    expect(controller.state.selectedWeekdays, {1, 3, 5});
    expect(controller.state.preferredDurationMinutes, 60);
  });

  test('validation catches empty title and missing weekdays', () {
    final controller = RoutineFormController(
      loadRepository: () async => FakeRoutineRepository(),
      deleteOccurrencesForRoutine: (_) async {},
      loadSyncService: () async => FakeRoutineSyncService(),
      nowProvider: () => DateTime(2026, 4, 9, 10),
    );

    controller.setRepeatType(RoutineRepeatType.selectedWeekdays);
    final errors = controller.validate();

    expect(errors['title'], isNotNull);
    expect(errors['selectedWeekdays'], isNotNull);
  });

  test('save builds and persists routine then triggers sync', () async {
    final repository = FakeRoutineRepository();
    final syncService = FakeRoutineSyncService();
    final controller = RoutineFormController(
      loadRepository: () async => repository,
      deleteOccurrencesForRoutine: (_) async {},
      loadSyncService: () async => syncService,
      nowProvider: () => DateTime(2026, 4, 9, 10),
      idGenerator: () => 'routine-1',
    );

    controller.setTitle('Deep Work');
    controller.setInterval(2);
    controller.setPreferredDurationMinutes(90);

    final saved = await controller.save();

    expect(saved, isNotNull);
    expect(saved!.title, 'Deep Work');
    expect(saved.repeatRule.interval, 2);
    expect(repository.getRoutineById('routine-1'), completion(isNotNull));
    expect(syncService.syncRoutineCalled, isTrue);
    expect(syncService.lastRoutineId, 'routine-1');
  });

  test('delete removes routine and cascades occurrence cleanup callback', () async {
    final repository = FakeRoutineRepository();
    var deletedRoutineId = '';
    final routine = Routine(
      id: 'routine-1',
      title: 'Reading',
      createdAt: DateTime(2026, 4, 1),
      anchorDate: DateTime(2026, 4, 1),
      repeatRule: RoutineRepeatRule(type: RoutineRepeatType.daily),
    );
    await repository.saveRoutine(routine);

    final controller = RoutineFormController(
      loadRepository: () async => repository,
      deleteOccurrencesForRoutine: (routineId) async {
        deletedRoutineId = routineId;
      },
      loadSyncService: () async => FakeRoutineSyncService(),
      nowProvider: () => DateTime(2026, 4, 9, 10),
      initialRoutine: routine,
    );

    await controller.delete();

    expect(await repository.getRoutineById('routine-1'), isNull);
    expect(deletedRoutineId, 'routine-1');
  });
}
