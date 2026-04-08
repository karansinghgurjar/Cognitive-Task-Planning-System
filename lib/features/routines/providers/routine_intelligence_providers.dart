import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schedule/providers/schedule_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../application/routine_consistency_service.dart';
import '../application/routine_goal_link_service.dart';
import '../application/routine_recovery_service.dart';
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

final routineSchedulerIntegrationServiceProvider =
    Provider<RoutineSchedulerIntegrationService>((ref) {
      return const RoutineSchedulerIntegrationService();
    });

final routineGoalContributionServiceProvider =
    Provider<RoutineGoalLinkService>((ref) {
      return const RoutineGoalLinkService();
    });

final routineAnalyticsRangeProvider = StateProvider<RoutineAnalyticsRange>((ref) {
  return RoutineAnalyticsRange.last7Days;
});

final routineConsistencySummaryProvider =
    Provider.family<AsyncValue<RoutineConsistencySummary>, String>((ref, routineId) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);
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
      final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

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
      final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

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
      final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);

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
      final occurrences = await occurrenceRepository.getAllOccurrences();
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

  Future<void> runSchedulingIntegration() async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncLoading();
    try {
      final routines = await ref.read(watchAllRoutinesProvider.future);
      final occurrences = await ref.read(watchAllRoutineOccurrencesProvider.future);
      final sessions = await ref.read(watchAllSessionsProvider.future);
      final timetableSlots = await ref.read(watchTimetableSlotsProvider.future);
      final weeklyAvailability = ref
          .read(availabilityServiceProvider)
          .computeWeeklyAvailability(timetableSlots);
      final now = DateTime.now();
      final result = ref.read(routineSchedulerIntegrationServiceProvider).integrate(
            routines: routines,
            occurrences: occurrences,
            weeklyAvailability: weeklyAvailability,
            plannedSessions: sessions,
            startDate: now,
            endDate: now.add(const Duration(days: 7)),
            now: now,
          );
      final repository = await ref.read(routineOccurrenceRepositoryProvider.future);
      await repository.saveOccurrences(result.updatedOccurrences);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
