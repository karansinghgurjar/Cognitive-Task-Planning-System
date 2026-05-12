import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/providers/goal_providers.dart';
import '../../routines/providers/routine_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../domain/insight_fatigue_service.dart';
import '../domain/planning_insight_action_router.dart';
import '../domain/planning_insight_models.dart';
import '../domain/planning_insight_service.dart';

final planningInsightServiceProvider = Provider<PlanningInsightService>((ref) {
  return const PlanningInsightService();
});

final insightFatigueServiceProvider = Provider<InsightFatigueService>((ref) {
  return const InsightFatigueService();
});

final planningInsightActionRouterProvider =
    Provider<PlanningInsightActionRouter>((ref) {
      return const PlanningInsightActionRouter();
    });

final insightSuppressionControllerProvider =
    StateNotifierProvider<
      InsightSuppressionController,
      InsightSuppressionState
    >((ref) {
      return InsightSuppressionController(
        ref.read(insightFatigueServiceProvider),
      );
    });

class InsightSuppressionController
    extends StateNotifier<InsightSuppressionState> {
  InsightSuppressionController(this._fatigueService)
    : super(const InsightSuppressionState());

  final InsightFatigueService _fatigueService;

  void dismiss(PlanningInsight insight) {
    state = _fatigueService.dismiss(state, insight, DateTime.now());
  }

  void snooze(PlanningInsight insight, Duration duration) {
    state = _fatigueService.snooze(
      state,
      insight,
      DateTime.now().add(duration),
    );
  }

  void disableTypeForEntity(PlanningInsight insight) {
    state = _fatigueService.disableTypeForEntity(state, insight);
  }
}

final rawPlanningInsightsProvider = Provider<AsyncValue<List<PlanningInsight>>>(
  (ref) {
    final routinesAsync = ref.watch(watchAllRoutinesProvider);
    final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);
    final tasksAsync = ref.watch(watchTasksProvider);
    final sessionsAsync = ref.watch(watchAllSessionsProvider);
    final goalsAsync = ref.watch(watchGoalsProvider);
    final timetableAsync = ref.watch(watchTimetableSlotsProvider);

    return switch ((
      routinesAsync,
      occurrencesAsync,
      tasksAsync,
      sessionsAsync,
      goalsAsync,
      timetableAsync,
    )) {
      (
        AsyncData(value: final routines),
        AsyncData(value: final occurrences),
        AsyncData(value: final tasks),
        AsyncData(value: final sessions),
        AsyncData(value: final goals),
        AsyncData(value: final timetableSlots),
      ) =>
        AsyncData(
          ref
              .read(planningInsightServiceProvider)
              .generateInsights(
                PlanningInsightContext(
                  routines: routines,
                  occurrences: occurrences,
                  tasks: tasks,
                  sessions: sessions,
                  goals: goals,
                  timetableSlots: timetableSlots,
                  now: DateTime.now(),
                ),
              ),
        ),
      (AsyncError(:final error, :final stackTrace), _, _, _, _, _) =>
        AsyncError(error, stackTrace),
      (_, AsyncError(:final error, :final stackTrace), _, _, _, _) =>
        AsyncError(error, stackTrace),
      (_, _, AsyncError(:final error, :final stackTrace), _, _, _) =>
        AsyncError(error, stackTrace),
      (_, _, _, AsyncError(:final error, :final stackTrace), _, _) =>
        AsyncError(error, stackTrace),
      (_, _, _, _, AsyncError(:final error, :final stackTrace), _) =>
        AsyncError(error, stackTrace),
      (_, _, _, _, _, AsyncError(:final error, :final stackTrace)) =>
        AsyncError(error, stackTrace),
      _ => const AsyncLoading(),
    };
  },
);

final planningInsightsProvider = Provider<AsyncValue<List<PlanningInsight>>>((
  ref,
) {
  final rawAsync = ref.watch(rawPlanningInsightsProvider);
  final suppression = ref.watch(insightSuppressionControllerProvider);
  return rawAsync.whenData((insights) {
    return ref
        .read(insightFatigueServiceProvider)
        .filterInsights(
          insights: insights,
          suppression: suppression,
          now: DateTime.now(),
        );
  });
});

final planningInsightsForRoutineProvider =
    Provider.family<AsyncValue<List<PlanningInsight>>, String>((
      ref,
      routineId,
    ) {
      return ref.watch(planningInsightsProvider).whenData((insights) {
        return insights
            .where((insight) => insight.relatedRoutineId == routineId)
            .toList();
      });
    });

final weeklyRoutineInsightSummaryProvider =
    Provider.family<AsyncValue<WeeklyRoutineInsightSummary>, DateTime>((
      ref,
      weekStart,
    ) {
      final routinesAsync = ref.watch(watchAllRoutinesProvider);
      final occurrencesAsync = ref.watch(watchAllRoutineOccurrencesProvider);
      final insightsAsync = ref.watch(planningInsightsProvider);

      return switch ((routinesAsync, occurrencesAsync, insightsAsync)) {
        (
          AsyncData(value: final routines),
          AsyncData(value: final occurrences),
          AsyncData(value: final insights),
        ) =>
          AsyncData(
            ref
                .read(planningInsightServiceProvider)
                .buildWeeklyRoutineSummary(
                  weekStart: weekStart,
                  routines: routines,
                  occurrences: occurrences,
                  insights: insights,
                  now: DateTime.now(),
                ),
          ),
        (AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });
