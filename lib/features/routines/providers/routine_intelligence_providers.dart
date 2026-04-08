import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../application/routine_consistency_service.dart';
import '../application/routine_reconciliation_service.dart';
import '../application/routine_goal_link_service.dart';
import '../application/routine_planner_pipeline_service.dart';
import '../application/routine_recovery_service.dart';
import '../application/routine_reminder_service.dart';
import '../application/routine_scheduler_integration_service.dart';
import '../domain/routine_enums.dart';
import '../models/routine_occurrence.dart';
import 'routine_providers.dart';

final routineConsistencyServiceProvider = Provider<RoutineConsistencyService>((ref) {
  return const RoutineConsistencyService();
});

final routineRecoveryServiceProvider = Provider<RoutineRecoveryService>((ref) {
  return RoutineRecoveryService();
});

final routineReminderServiceProvider = Provider<RoutineReminderService>((ref) {
  return RoutineReminderService(
    notificationService: ref.read(notificationServiceProvider),
  );
});

final routineSchedulerIntegrationServiceProvider =
    Provider<RoutineSchedulerIntegrationService>((ref) {
      return const RoutineSchedulerIntegrationService();
    });

final routineGoalContributionServiceProvider =
    Provider<RoutineGoalLinkService>((ref) {
      return const RoutineGoalLinkService();
    });

final routineReconciliationServiceProvider =
    Provider<RoutineReconciliationService>((ref) {
      return RoutineReconciliationService();
    });

final routinePlannerPipelineServiceProvider =
    Provider<RoutinePlannerPipelineService>((ref) {
      return RoutinePlannerPipelineService(
        historyPolicyService: ref.read(routineHistoryPolicyServiceProvider),
        recoveryService: ref.read(routineRecoveryServiceProvider),
        schedulerIntegrationService: ref.read(
          routineSchedulerIntegrationServiceProvider,
        ),
        reminderService: ref.read(routineReminderServiceProvider),
        diagnosticsService: ref.read(routineDiagnosticsServiceProvider),
      );
    });

final routineAnalyticsRangeProvider = StateProvider<RoutineAnalyticsRange>((ref) {
  return RoutineAnalyticsRange.last7Days;
});

final routineConsistencySummaryProvider =
    Provider.family<AsyncValue<RoutineConsistencySummary>, String>((ref, routineId) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(recentHistoryRoutineOccurrencesProvider);
      final range = ref.watch(routineAnalyticsRangeProvider);

      return switch ((routinesAsync, occurrencesAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
        ) =>
          AsyncData(
            ref.read(routineConsistencyServiceProvider).summarize(
                  routine: routines.firstWhere((routine) => routine.id == routineId),
                  occurrences: occurrences
                      .where((occurrence) => occurrence.routineId == routineId)
                      .toList(),
                  now: DateTime.now(),
                  range: range,
                ),
          ),
        (AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final missedRoutineOccurrencesProvider =
    Provider<AsyncValue<List<RoutineOccurrenceItem>>>((ref) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(recentHistoryRoutineOccurrencesProvider);

      return switch ((routinesAsync, occurrencesAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
        ) =>
          AsyncData(
            buildRoutineOccurrenceItems(
              routines: routines,
              occurrences: occurrences
                  .where(
                    (occurrence) =>
                        occurrence.effectiveStatusAt(DateTime.now()) ==
                        RoutineOccurrenceStatus.missed,
                  )
                  .toList(),
              now: DateTime.now(),
              startDate: DateTime.now().subtract(const Duration(days: 7)),
              endDate: DateTime.now().add(const Duration(days: 2)),
            ),
          ),
        (AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final routineRecoverySuggestionsProvider =
    Provider<AsyncValue<List<RoutineRecoverySuggestion>>>((ref) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(planningHorizonRoutineOccurrencesProvider);

      return switch ((routinesAsync, occurrencesAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
        ) =>
          AsyncData(
            ref.read(routineRecoveryServiceProvider).buildRecoverySuggestions(
                  routines: routines,
                  occurrences: occurrences,
                  now: DateTime.now(),
                ),
          ),
        (AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final unscheduledFlexibleRoutineOccurrencesProvider =
    Provider<AsyncValue<List<RoutineOccurrenceItem>>>((ref) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(planningHorizonRoutineOccurrencesProvider);

      return switch ((routinesAsync, occurrencesAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
        ) =>
          AsyncData(
            buildRoutineOccurrenceItems(
              routines: routines,
              occurrences: occurrences
                  .where((occurrence) => occurrence.needsAttention)
                  .toList(),
              now: DateTime.now(),
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 7)),
            ).where((item) => item.routine?.isFlexible ?? false).toList(),
          ),
        (AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final routineIntelligenceControllerProvider =
    AsyncNotifierProvider<RoutineIntelligenceController, void>(
      RoutineIntelligenceController.new,
    );

class RoutineIntelligenceController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> refreshTodayIntelligence() async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final occurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      final window = ref.read(routineHistoryPolicyServiceProvider).activePlanningWindow();
      final occurrences = await occurrenceRepository.getOccurrencesInRange(
        window.startDate,
        window.endDate,
      );
      final missedUpdates = ref.read(routineRecoveryServiceProvider).detectMissedOccurrences(
            occurrences: occurrences,
            now: DateTime.now(),
          );
      await occurrenceRepository.saveOccurrences(missedUpdates);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> acceptRecoverySuggestion(RoutineRecoverySuggestion suggestion) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final occurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      final recovery = ref.read(routineRecoveryServiceProvider).createRecoveryOccurrence(
            suggestion,
            now: DateTime.now(),
          );
      await occurrenceRepository.saveOccurrences([recovery]);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> dismissRecoverySuggestion(String occurrenceId) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final occurrenceRepository = await ref.read(
        routineOccurrenceRepositoryProvider.future,
      );
      final occurrence = await occurrenceRepository.getOccurrenceById(occurrenceId);
      if (occurrence == null) {
        state = const AsyncData(null);
        return;
      }
      final updated = ref.read(routineRecoveryServiceProvider).dismissRecoverySuggestion(
            occurrence,
            now: DateTime.now(),
          );
      await occurrenceRepository.updateOccurrence(updated);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> runSchedulingIntegration() async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final routines = await ref.read(watchAllRoutinesProvider.future);
      final sessions = await ref.read(watchAllSessionsProvider.future);
      final timetableSlots = await ref.read(watchTimetableSlotsProvider.future);
      final weeklyAvailability = ref
          .read(availabilityServiceProvider)
          .computeWeeklyAvailability(timetableSlots);
      final now = DateTime.now();
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      final result = await ref.read(routinePlannerPipelineServiceProvider).run(
            routines: routines,
            occurrenceRepository: repository,
            weeklyAvailability: weeklyAvailability,
            plannedSessions: sessions,
            now: now,
          );
      ref.read(routinePlannerDiagnosticsProvider.notifier).state = result.diagnostics;
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> replanRoutineOccurrences(String routineId) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final routines = await ref.read(watchAllRoutinesProvider.future);
      final occurrences = await ref.read(planningHorizonRoutineOccurrencesProvider.future);
      final sessions = await ref.read(watchAllSessionsProvider.future);
      final timetableSlots = await ref.read(watchTimetableSlotsProvider.future);
      final weeklyAvailability = ref
          .read(availabilityServiceProvider)
          .computeWeeklyAvailability(timetableSlots);
      final now = DateTime.now();
      final horizonEnd = now.add(const Duration(days: 30));
      final reconciliationService = ref.read(routineReconciliationServiceProvider);
      final routineById = {for (final routine in routines) routine.id: routine};
      final resetOccurrences = occurrences.map((occurrence) {
        if (occurrence.routineId != routineId ||
            occurrence.status != RoutineOccurrenceStatus.pending ||
            occurrence.isManualOverride ||
            occurrence.occurrenceDate.isBefore(
              DateTime(now.year, now.month, now.day),
            ) ||
            occurrence.occurrenceDate.isAfter(DateTime(
              horizonEnd.year,
              horizonEnd.month,
              horizonEnd.day,
            ))) {
          return occurrence;
        }
        final routine = routineById[occurrence.routineId];
        if (routine == null) {
          return occurrence;
        }
        return reconciliationService.refreshOccurrenceSchedule(
          occurrence: occurrence,
          routine: routine,
          now: now,
        );
      }).toList();
      final result = ref.read(routineSchedulerIntegrationServiceProvider).integrate(
            routines: routines,
            occurrences: resetOccurrences,
            weeklyAvailability: weeklyAvailability,
            plannedSessions: sessions,
            startDate: now,
            endDate: horizonEnd,
            now: now,
          );
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.saveOccurrences(
        result.updatedOccurrences
            .where((occurrence) => occurrence.routineId == routineId)
            .toList(),
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
