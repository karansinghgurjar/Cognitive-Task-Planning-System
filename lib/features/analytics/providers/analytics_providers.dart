import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/providers/goal_providers.dart';
import '../../recommendations/providers/recommendation_providers.dart';
import '../../schedule/models/planned_session.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../domain/analytics_models.dart';
import '../domain/analytics_service.dart';
import '../domain/burnout_insight_service.dart';
import '../domain/day_review_service.dart';
import '../domain/goal_analytics_service.dart';
import '../domain/streak_service.dart';
import '../domain/time_allocation_service.dart';

final analyticsRangePresetProvider = StateProvider<AnalyticsRangePreset>((ref) {
  return AnalyticsRangePreset.last7Days;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(analyticsService: ref.read(analyticsServiceProvider));
});

final goalAnalyticsServiceProvider = Provider<GoalAnalyticsService>((ref) {
  return const GoalAnalyticsService();
});

final timeAllocationServiceProvider = Provider<TimeAllocationService>((ref) {
  return const TimeAllocationService();
});

final burnoutInsightServiceProvider = Provider<BurnoutInsightService>((ref) {
  return BurnoutInsightService(
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final dayReviewServiceProvider = Provider<DayReviewService>((ref) {
  return const DayReviewService();
});

class AnalyticsDashboardData {
  const AnalyticsDashboardData({
    required this.dailyStats,
    required this.weeklyStats,
    required this.rangeStats,
    required this.selectedRange,
    required this.streakSummary,
    required this.focusTrend,
    required this.taskTypeBreakdown,
    required this.goalTypeBreakdown,
    required this.goalBreakdown,
    required this.weekdayBreakdown,
    required this.goalAnalytics,
    required this.productivityInsights,
    required this.burnoutReport,
    required this.dayReview,
  });

  final DailyProductivityStats dailyStats;
  final WeeklyProductivityStats weeklyStats;
  final RangeProductivityStats rangeStats;
  final AnalyticsDateRange selectedRange;
  final StreakSummary streakSummary;
  final List<FocusTrendPoint> focusTrend;
  final TimeAllocationBreakdown taskTypeBreakdown;
  final TimeAllocationBreakdown goalTypeBreakdown;
  final TimeAllocationBreakdown goalBreakdown;
  final TimeAllocationBreakdown weekdayBreakdown;
  final List<GoalAnalytics> goalAnalytics;
  final List<ProductivityInsight> productivityInsights;
  final BurnoutRiskReport burnoutReport;
  final DayReviewSummary dayReview;
}

class _AnalyticsSourceData {
  const _AnalyticsSourceData({
    required this.tasks,
    required this.goals,
    required this.milestones,
    required this.sessions,
    required this.weeklyAvailability,
  });

  final List<Task> tasks;
  final List<LearningGoal> goals;
  final List<GoalMilestone> milestones;
  final List<PlannedSession> sessions;
  final Map<int, List<dynamic>> weeklyAvailability;
}

final _analyticsSourceProvider = Provider<AsyncValue<_AnalyticsSourceData>>((
  ref,
) {
  final tasksAsync = ref.watch(watchTasksProvider);
  final goalsAsync = ref.watch(watchGoalsProvider);
  final milestonesAsync = ref.watch(watchAllMilestonesProvider);
  final sessionsAsync = ref.watch(watchAllSessionsProvider);
  final availabilityAsync = ref.watch(weeklyAvailabilityProvider);

  return switch ((
    tasksAsync,
    goalsAsync,
    milestonesAsync,
    sessionsAsync,
    availabilityAsync,
  )) {
    (
      AsyncData(value: final tasks),
      AsyncData(value: final goals),
      AsyncData(value: final milestones),
      AsyncData(value: final sessions),
      AsyncData(value: final weeklyAvailability),
    ) =>
      AsyncData(
        _AnalyticsSourceData(
          tasks: tasks,
          goals: goals,
          milestones: milestones,
          sessions: sessions,
          weeklyAvailability: weeklyAvailability,
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

final selectedAnalyticsRangeProvider = Provider<AnalyticsDateRange>((ref) {
  final preset = ref.watch(analyticsRangePresetProvider);
  return ref
      .read(analyticsServiceProvider)
      .resolveRange(preset, DateTime.now());
});

final dailyStatsProvider = Provider<AsyncValue<DailyProductivityStats>>((ref) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(analyticsServiceProvider)
        .computeDailyStats(
          day: DateTime.now(),
          tasks: source.tasks,
          goals: source.goals,
          sessions: source.sessions,
        );
  });
});

final weeklyStatsProvider = Provider<AsyncValue<WeeklyProductivityStats>>((
  ref,
) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(analyticsServiceProvider)
        .computeWeeklyStats(sessions: source.sessions, now: DateTime.now());
  });
});

final selectedRangeStatsProvider = Provider<AsyncValue<RangeProductivityStats>>(
  (ref) {
    final range = ref.watch(selectedAnalyticsRangeProvider);
    return ref.watch(_analyticsSourceProvider).whenData((source) {
      return ref
          .read(analyticsServiceProvider)
          .computeRangeStats(range: range, sessions: source.sessions);
    });
  },
);

final focusTrendProvider = Provider<AsyncValue<List<FocusTrendPoint>>>((ref) {
  final preset = ref.watch(analyticsRangePresetProvider);
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(analyticsServiceProvider)
        .buildFocusTrend(
          sessions: source.sessions,
          preset: preset,
          now: DateTime.now(),
        );
  });
});

final streakSummaryProvider = Provider<AsyncValue<StreakSummary>>((ref) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    final service = ref.read(streakServiceProvider);
    return StreakSummary(
      currentFocusStreak: service.computeCurrentStreak(
        sessions: source.sessions,
        now: DateTime.now(),
      ),
      longestFocusStreak: service.computeLongestStreak(
        sessions: source.sessions,
      ),
      currentDailyCompletionStreak: service.computeCurrentCompletionStreak(
        sessions: source.sessions,
        now: DateTime.now(),
      ),
    );
  });
});

final goalAnalyticsProvider = Provider<AsyncValue<List<GoalAnalytics>>>((ref) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(goalAnalyticsServiceProvider)
        .computeGoalAnalytics(
          goals: source.goals,
          milestones: source.milestones,
          tasks: source.tasks,
          sessions: source.sessions,
          weeklyAvailability: source.weeklyAvailability.cast(),
          now: DateTime.now(),
        );
  });
});

final _selectedRangeSessionsProvider =
    Provider<AsyncValue<List<PlannedSession>>>((ref) {
      final preset = ref.watch(analyticsRangePresetProvider);
      return ref.watch(_analyticsSourceProvider).whenData((source) {
        return ref
            .read(analyticsServiceProvider)
            .filterSessionsForRange(
              sessions: source.sessions,
              preset: preset,
              now: DateTime.now(),
            );
      });
    });

final taskTypeAllocationProvider =
    Provider<AsyncValue<TimeAllocationBreakdown>>((ref) {
      final sessionsAsync = ref.watch(_selectedRangeSessionsProvider);
      final sourceAsync = ref.watch(_analyticsSourceProvider);
      return switch ((sessionsAsync, sourceAsync)) {
        (AsyncData(value: final sessions), AsyncData(value: final source)) =>
          AsyncData(
            ref
                .read(timeAllocationServiceProvider)
                .byTaskType(tasks: source.tasks, sessions: sessions),
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

final goalTypeAllocationProvider =
    Provider<AsyncValue<TimeAllocationBreakdown>>((ref) {
      final sessionsAsync = ref.watch(_selectedRangeSessionsProvider);
      final sourceAsync = ref.watch(_analyticsSourceProvider);
      return switch ((sessionsAsync, sourceAsync)) {
        (AsyncData(value: final sessions), AsyncData(value: final source)) =>
          AsyncData(
            ref
                .read(timeAllocationServiceProvider)
                .byGoalType(
                  goals: source.goals,
                  tasks: source.tasks,
                  sessions: sessions,
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

final goalAllocationProvider = Provider<AsyncValue<TimeAllocationBreakdown>>((
  ref,
) {
  final sessionsAsync = ref.watch(_selectedRangeSessionsProvider);
  final sourceAsync = ref.watch(_analyticsSourceProvider);
  return switch ((sessionsAsync, sourceAsync)) {
    (AsyncData(value: final sessions), AsyncData(value: final source)) =>
      AsyncData(
        ref
            .read(timeAllocationServiceProvider)
            .byGoal(
              goals: source.goals,
              tasks: source.tasks,
              sessions: sessions,
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

final weekdayAllocationProvider = Provider<AsyncValue<TimeAllocationBreakdown>>(
  (ref) {
    return ref.watch(_selectedRangeSessionsProvider).whenData((sessions) {
      return ref
          .read(timeAllocationServiceProvider)
          .byWeekday(sessions: sessions);
    });
  },
);

final burnoutReportProvider = Provider<AsyncValue<BurnoutRiskReport>>((ref) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(burnoutInsightServiceProvider)
        .evaluate(
          tasks: source.tasks,
          goals: source.goals,
          sessions: source.sessions,
          weeklyAvailability: source.weeklyAvailability.cast(),
          now: DateTime.now(),
        );
  });
});

final dayReviewProvider = Provider<AsyncValue<DayReviewSummary>>((ref) {
  return ref.watch(_analyticsSourceProvider).whenData((source) {
    return ref
        .read(dayReviewServiceProvider)
        .summarizeDay(
          day: DateTime.now(),
          now: DateTime.now(),
          sessions: source.sessions,
          tasks: source.tasks,
        );
  });
});

final productivityInsightsProvider =
    Provider<AsyncValue<List<ProductivityInsight>>>((ref) {
      final dailyAsync = ref.watch(dailyStatsProvider);
      final weeklyAsync = ref.watch(weeklyStatsProvider);
      final goalAnalyticsAsync = ref.watch(goalAnalyticsProvider);
      final burnoutAsync = ref.watch(burnoutReportProvider);
      final reviewAsync = ref.watch(dayReviewProvider);
      final streakAsync = ref.watch(streakSummaryProvider);

      return switch ((
        dailyAsync,
        weeklyAsync,
        goalAnalyticsAsync,
        burnoutAsync,
        reviewAsync,
        streakAsync,
      )) {
        (
          AsyncData(value: final daily),
          AsyncData(value: final weekly),
          AsyncData(value: final goalAnalytics),
          AsyncData(value: final burnout),
          AsyncData(value: final review),
          AsyncData(value: final streaks),
        ) =>
          AsyncData(
            ref
                .read(analyticsServiceProvider)
                .generateInsights(
                  todayStats: daily,
                  weeklyStats: weekly,
                  goalAnalytics: goalAnalytics,
                  burnoutReport: burnout,
                  dayReview: review,
                  streakSummary: streaks,
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

final analyticsDashboardDataProvider =
    Provider<AsyncValue<AnalyticsDashboardData>>((ref) {
      final dailyAsync = ref.watch(dailyStatsProvider);
      final weeklyAsync = ref.watch(weeklyStatsProvider);
      final rangeStatsAsync = ref.watch(selectedRangeStatsProvider);
      final streakAsync = ref.watch(streakSummaryProvider);
      final trendAsync = ref.watch(focusTrendProvider);
      final taskAllocationAsync = ref.watch(taskTypeAllocationProvider);
      final goalTypeAllocationAsync = ref.watch(goalTypeAllocationProvider);
      final goalAllocationAsync = ref.watch(goalAllocationProvider);
      final weekdayAllocationAsync = ref.watch(weekdayAllocationProvider);
      final goalAnalyticsAsync = ref.watch(goalAnalyticsProvider);
      final insightsAsync = ref.watch(productivityInsightsProvider);
      final burnoutAsync = ref.watch(burnoutReportProvider);
      final reviewAsync = ref.watch(dayReviewProvider);
      final selectedRange = ref.watch(selectedAnalyticsRangeProvider);

      return switch ((
        dailyAsync,
        weeklyAsync,
        rangeStatsAsync,
        streakAsync,
        trendAsync,
        taskAllocationAsync,
        goalTypeAllocationAsync,
        goalAllocationAsync,
        weekdayAllocationAsync,
        goalAnalyticsAsync,
        insightsAsync,
        burnoutAsync,
        reviewAsync,
      )) {
        (
          AsyncData(value: final daily),
          AsyncData(value: final weekly),
          AsyncData(value: final rangeStats),
          AsyncData(value: final streaks),
          AsyncData(value: final trend),
          AsyncData(value: final taskAllocation),
          AsyncData(value: final goalTypeAllocation),
          AsyncData(value: final goalAllocation),
          AsyncData(value: final weekdayAllocation),
          AsyncData(value: final goalAnalytics),
          AsyncData(value: final insights),
          AsyncData(value: final burnout),
          AsyncData(value: final review),
        ) =>
          AsyncData(
            AnalyticsDashboardData(
              dailyStats: daily,
              weeklyStats: weekly,
              rangeStats: rangeStats,
              selectedRange: selectedRange,
              streakSummary: streaks,
              focusTrend: trend,
              taskTypeBreakdown: taskAllocation,
              goalTypeBreakdown: goalTypeAllocation,
              goalBreakdown: goalAllocation,
              weekdayBreakdown: weekdayAllocation,
              goalAnalytics: goalAnalytics,
              productivityInsights: insights,
              burnoutReport: burnout,
              dayReview: review,
            ),
          ),
        (
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
          _,
        ) =>
          AsyncError(error, stackTrace),
        (
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          _,
          AsyncError(:final error, :final stackTrace),
        ) =>
          AsyncError(error, stackTrace),
        _ => const AsyncLoading(),
      };
    });
