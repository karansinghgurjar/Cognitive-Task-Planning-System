import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/isar_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../goals/data/goal_repository.dart';
import '../../goals/domain/dependency_resolution_service.dart';
import '../../routines/providers/routine_providers.dart';
import '../../routines/providers/routine_intelligence_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/domain/availability_service.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../data/planned_session_repository.dart';
import '../domain/schedule_generator_service.dart';
import '../domain/session_progress_service.dart';
import '../domain/scheduling_models.dart';
import '../domain/task_progress_service.dart';
import '../models/planned_session.dart';

final plannedSessionRepositoryProvider =
    FutureProvider<PlannedSessionRepository>((ref) async {
      final isar = await ref.watch(isarInstanceProvider.future);
      final syncMutationRecorder = await ref.watch(
        syncMutationRecorderProvider.future,
      );
      return PlannedSessionRepository(
        isar,
        syncMutationRecorder: syncMutationRecorder,
      );
    });

final sessionProgressSessionStoreProvider =
    FutureProvider<SessionProgressSessionStore>((ref) async {
      return ref.watch(plannedSessionRepositoryProvider.future);
    });

final watchAllSessionsProvider = StreamProvider<List<PlannedSession>>((
  ref,
) async* {
  final repository = await ref.watch(plannedSessionRepositoryProvider.future);
  yield* repository.watchAllSessions();
});

final watchUpcomingSessionsProvider = StreamProvider<List<PlannedSession>>((
  ref,
) async* {
  final now = DateTime.now();
  final repository = await ref.watch(plannedSessionRepositoryProvider.future);
  yield* repository.watchAllSessions().map((sessions) {
    return sessions
        .where(
          (session) =>
              session.end.isAfter(now) || session.end.isAtSameMomentAs(now),
        )
        .toList()
      ..sort((left, right) => left.start.compareTo(right.start));
  });
});

final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  return const AvailabilityService();
});

final scheduleGeneratorServiceProvider = Provider<ScheduleGeneratorService>((
  ref,
) {
  return ScheduleGeneratorService(
    dependencyResolutionService: const DependencyResolutionService(),
    taskProgressService: ref.read(taskProgressServiceProvider),
  );
});

final taskProgressServiceProvider = Provider<TaskProgressService>((ref) {
  return const TaskProgressService();
});

final sessionProgressServiceProvider = FutureProvider<SessionProgressService>((
  ref,
) async {
  final sessionRepository = await ref.watch(
    sessionProgressSessionStoreProvider.future,
  );
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  return SessionProgressService(
    sessionStore: sessionRepository,
    taskStore: taskRepository,
    taskProgressService: ref.read(taskProgressServiceProvider),
  );
});

final scheduleActionControllerProvider =
    AsyncNotifierProvider<ScheduleActionController, SchedulingResult?>(
      ScheduleActionController.new,
    );

class ScheduleActionController extends AsyncNotifier<SchedulingResult?> {
  @override
  SchedulingResult? build() {
    return null;
  }

  Future<SchedulingResult> generateNext7DaysSchedule() async {
    _ensureIdle();
    state = const AsyncLoading();

    try {
      final now = DateTime.now();
      final horizonStart = DateTime(now.year, now.month, now.day);
      final horizonEnd = horizonStart.add(const Duration(days: 7));

      final taskRepository = await ref.read(taskRepositoryProvider.future);
      final timetableRepository = await ref.read(
        timetableRepositoryProvider.future,
      );
      final goalRepository = GoalRepository(
        await ref.read(isarInstanceProvider.future),
      );
      final sessionRepository = await ref.read(
        plannedSessionRepositoryProvider.future,
      );
      final routineSyncService = await ref.read(routineSyncServiceProvider.future);
      final routineOccurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      final allRoutines = await ref.read(watchAllRoutinesProvider.future);

      final allTasks = await taskRepository.getAllTasks(includeArchived: false);
      final incompleteTasks = allTasks
          .where((task) => !task.isCompleted)
          .toList();
      final timetableSlots = await timetableRepository.getAllSlots();
      final weeklyAvailability = ref
          .read(availabilityServiceProvider)
          .computeWeeklyAvailability(timetableSlots);
      final dependencies = await goalRepository.getAllDependencies();

      final existingSessions = await sessionRepository.getSessionsInRange(
        horizonStart,
        horizonEnd,
      );

      final blockedSessions = existingSessions
          .where(
            (session) =>
                session.isCompleted ||
                session.isInProgress ||
                session.start.isBefore(now),
          )
          .toList();

      final result = ref
          .read(scheduleGeneratorServiceProvider)
          .generateNext7DaysSchedule(
            tasks: incompleteTasks,
            weeklyAvailability: weeklyAvailability,
            existingSessions: blockedSessions,
            now: now,
            dependencies: dependencies,
          );

      await sessionRepository.replaceFutureSessionsInRange(
        start: now,
        end: horizonEnd,
        newSessions: result.generatedSessions,
        keepCompleted: true,
      );

      await routineSyncService.syncAllRoutines(
        startDate: horizonStart,
        endDate: horizonEnd,
      );
      final pipelineResult = await ref.read(routinePlannerPipelineServiceProvider).run(
            routines: allRoutines,
            occurrenceRepository: routineOccurrenceRepository,
            weeklyAvailability: weeklyAvailability,
            plannedSessions: [...blockedSessions, ...result.generatedSessions],
            now: now,
          );
      ref.read(routinePlannerDiagnosticsProvider.notifier).state =
          pipelineResult.diagnostics;

      debugPrint(
        'Schedule generation: sessions=${result.generatedSessions.length} scheduledMinutes=${result.totalScheduledMinutes} failures=${result.failures.length}',
      );
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> markSessionCompleted(PlannedSession session) async {
    _ensureIdle();
    final previousResult = state.valueOrNull;
    state = const AsyncLoading();

    try {
      if (!session.isCompleted) {
        final progressService = await ref.read(
          sessionProgressServiceProvider.future,
        );
        await progressService.completeSession(
          session: session,
          elapsedSeconds: session.actualMinutesFocused > 0
              ? session.actualMinutesFocused * 60
              : session.plannedDurationMinutes * 60,
          timerCompletedNormally: true,
        );
      }

      state = AsyncData(previousResult);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another schedule action is already in progress.');
    }
  }
}
