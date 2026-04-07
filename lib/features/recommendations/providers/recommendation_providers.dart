import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/models/learning_goal.dart';
import '../../goals/providers/goal_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/domain/availability_service.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../../routines/providers/routine_providers.dart';
import '../domain/feasibility_service.dart';
import '../domain/recommendation_engine_service.dart';
import '../domain/recommendation_models.dart';
import '../domain/workload_warning_service.dart';

final feasibilityServiceProvider = Provider<FeasibilityService>((ref) {
  return const FeasibilityService();
});

final workloadWarningServiceProvider = Provider<WorkloadWarningService>((ref) {
  return WorkloadWarningService(
    feasibilityService: ref.read(feasibilityServiceProvider),
  );
});

final recommendationEngineServiceProvider =
    Provider<RecommendationEngineService>((ref) {
      return RecommendationEngineService(
        dependencyResolutionService: ref.read(
          dependencyResolutionServiceProvider,
        ),
        taskProgressService: ref.read(taskProgressServiceProvider),
        feasibilityService: ref.read(feasibilityServiceProvider),
        workloadWarningService: ref.read(workloadWarningServiceProvider),
      );
    });

final weeklyAvailabilityProvider =
    Provider<AsyncValue<Map<int, List<AvailabilityWindow>>>>((ref) {
      final slotsAsync = ref.watch(watchTimetableSlotsProvider);
      return slotsAsync.whenData(
        (slots) => ref
            .read(availabilityServiceProvider)
            .computeWeeklyAvailability(slots),
      );
    });

final bestNextTaskRecommendationProvider =
    Provider<AsyncValue<TaskRecommendation?>>((ref) {
      final tasksAsync = ref.watch(watchActiveTasksProvider);
      final goalsAsync = ref.watch(watchGoalsProvider);
      final milestonesAsync = ref.watch(watchAllMilestonesProvider);
      final dependenciesAsync = ref.watch(watchDependenciesProvider);
      final sessionsAsync = ref.watch(watchAllSessionsProvider);
      final availabilityAsync = ref.watch(weeklyAvailabilityProvider);

      return switch ((
        tasksAsync,
        goalsAsync,
        milestonesAsync,
        dependenciesAsync,
        sessionsAsync,
        availabilityAsync,
      )) {
        (
          AsyncData(value: final tasks),
          AsyncData(value: final goals),
          AsyncData(value: final milestones),
          AsyncData(value: final dependencies),
          AsyncData(value: final sessions),
          AsyncData(value: final weeklyAvailability),
        ) =>
          AsyncData(
            ref
                .read(recommendationEngineServiceProvider)
                .recommendNextTask(
                  tasks: tasks,
                  goals: goals,
                  milestones: milestones,
                  dependencies: dependencies,
                  plannedSessions: sessions,
                  weeklyAvailability: weeklyAvailability,
                  now: DateTime.now(),
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
    });

final nextRecommendedStudyBlockProvider =
    Provider<AsyncValue<RecommendedStudyBlock?>>((ref) {
      final sessionsAsync = ref.watch(watchAllSessionsProvider);
      final availabilityAsync = ref.watch(weeklyAvailabilityProvider);
      final bestTaskAsync = ref.watch(bestNextTaskRecommendationProvider);

      return switch ((sessionsAsync, availabilityAsync, bestTaskAsync)) {
        (
          AsyncData(value: final sessions),
          AsyncData(value: final weeklyAvailability),
          AsyncData(value: final bestTask),
        ) =>
          AsyncData(
            ref
                .read(recommendationEngineServiceProvider)
                .recommendNextAvailableBlock(
                  weeklyAvailability: weeklyAvailability,
                  plannedSessions: sessions,
                  now: DateTime.now(),
                  preferredDurationMinutes:
                      bestTask?.suggestedDurationMinutes ?? 60,
                  relatedTaskId: bestTask?.taskId,
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

final goalFeasibilityReportsProvider =
    Provider<AsyncValue<List<GoalFeasibilityReport>>>((ref) {
      final goalsAsync = ref.watch(watchGoalsProvider);
      final milestonesAsync = ref.watch(watchAllMilestonesProvider);
      final tasksAsync = ref.watch(watchActiveTasksProvider);
      final sessionsAsync = ref.watch(watchAllSessionsProvider);
      final availabilityAsync = ref.watch(weeklyAvailabilityProvider);

      return switch ((
        goalsAsync,
        milestonesAsync,
        tasksAsync,
        sessionsAsync,
        availabilityAsync,
      )) {
        (
          AsyncData(value: final goals),
          AsyncData(value: final milestones),
          AsyncData(value: final tasks),
          AsyncData(value: final sessions),
          AsyncData(value: final weeklyAvailability),
        ) =>
          AsyncData(
            ref
                .read(recommendationEngineServiceProvider)
                .computeGoalFeasibility(
                  goals: goals,
                  milestones: milestones,
                  tasks: tasks,
                  plannedSessions: sessions,
                  weeklyAvailability: weeklyAvailability,
                  now: DateTime.now(),
                ),
          ),
        (AsyncError(:final error, :final stackTrace), _, _, _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace), _, _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, _, AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, _, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final workloadWarningsProvider = Provider<AsyncValue<List<WorkloadWarning>>>((
  ref,
) {
  final tasksAsync = ref.watch(watchActiveTasksProvider);
  final goalsAsync = ref.watch(watchGoalsProvider);
  final sessionsAsync = ref.watch(watchAllSessionsProvider);
  final availabilityAsync = ref.watch(weeklyAvailabilityProvider);
  final reportsAsync = ref.watch(goalFeasibilityReportsProvider);

  return switch ((
    tasksAsync,
    goalsAsync,
    sessionsAsync,
    availabilityAsync,
    reportsAsync,
  )) {
    (
      AsyncData(value: final tasks),
      AsyncData(value: final goals),
      AsyncData(value: final sessions),
      AsyncData(value: final weeklyAvailability),
      AsyncData(value: final reports),
    ) =>
      AsyncData(
        ref
            .read(workloadWarningServiceProvider)
            .detectWarnings(
              tasks: tasks,
              goals: goals,
              goalReports: reports,
              sessions: sessions,
              weeklyAvailability: weeklyAvailability,
              now: DateTime.now(),
            ),
      ),
    (AsyncError(:final error, :final stackTrace), _, _, _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, AsyncError(:final error, :final stackTrace), _, _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, _, AsyncError(:final error, :final stackTrace), _) => AsyncError(
      error,
      stackTrace,
    ),
    (_, _, _, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
});

final recommendationSummaryProvider =
    Provider<AsyncValue<RecommendationSummary>>((ref) {
      final tasksAsync = ref.watch(watchActiveTasksProvider);
      final goalsAsync = ref.watch(watchGoalsProvider);
      final milestonesAsync = ref.watch(watchAllMilestonesProvider);
      final dependenciesAsync = ref.watch(watchDependenciesProvider);
      final sessionsAsync = ref.watch(watchAllSessionsProvider);
      final availabilityAsync = ref.watch(weeklyAvailabilityProvider);
      final routineActionsAsync = ref.watch(routineRecommendationActionsProvider);

      return switch ((
        tasksAsync,
        goalsAsync,
        milestonesAsync,
        dependenciesAsync,
        sessionsAsync,
        availabilityAsync,
        routineActionsAsync,
      )) {
        (
          AsyncData(value: final tasks),
          AsyncData(value: final goals),
          AsyncData(value: final milestones),
          AsyncData(value: final dependencies),
          AsyncData(value: final sessions),
          AsyncData(value: final weeklyAvailability),
          AsyncData(value: final routineActions),
        ) =>
          AsyncData(
            () {
              final summary = ref
                  .read(recommendationEngineServiceProvider)
                  .buildSummary(
                    tasks: tasks,
                    goals: goals,
                    milestones: milestones,
                    dependencies: dependencies,
                    plannedSessions: sessions,
                    weeklyAvailability: weeklyAvailability,
                    now: DateTime.now(),
                  );
              return RecommendationSummary(
                bestNextTask: summary.bestNextTask,
                nextStudyBlock: summary.nextStudyBlock,
                workloadWarnings: summary.workloadWarnings,
                goalFeasibilityReports: summary.goalFeasibilityReports,
                suggestedActions: {
                  ...summary.suggestedActions,
                  ...routineActions,
                }.toList(),
              );
            }(),
          ),
        (AsyncError(:final error, :final stackTrace), _, _, _, _, _, _) =>
          AsyncError(error, stackTrace),
        (_, AsyncError(:final error, :final stackTrace), _, _, _, _, _) =>
          AsyncError(error, stackTrace),
        (_, _, AsyncError(:final error, :final stackTrace), _, _, _, _) =>
          AsyncError(error, stackTrace),
        (_, _, _, AsyncError(:final error, :final stackTrace), _, _, _) =>
          AsyncError(error, stackTrace),
        (_, _, _, _, AsyncError(:final error, :final stackTrace), _, _) =>
          AsyncError(error, stackTrace),
        (_, _, _, _, _, AsyncError(:final error, :final stackTrace), _) =>
          AsyncError(error, stackTrace),
        (_, _, _, _, _, _, AsyncError(:final error, :final stackTrace)) =>
          AsyncError(error, stackTrace),
        _ => const AsyncLoading(),
      };
    });

final goalFeasibilityReportProvider =
    Provider.family<AsyncValue<GoalFeasibilityReport?>, String>((ref, goalId) {
      return ref.watch(goalFeasibilityReportsProvider).whenData((reports) {
        for (final report in reports) {
          if (report.goalId == goalId) {
            return report;
          }
        }
        return null;
      });
    });

final goalsByIdProvider = Provider<AsyncValue<Map<String, LearningGoal>>>((
  ref,
) {
  return ref
      .watch(watchGoalsProvider)
      .whenData((goals) => {for (final goal in goals) goal.id: goal});
});
