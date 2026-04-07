import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/providers/goal_providers.dart';
import '../../schedule/models/planned_session.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/weekly_review_repository.dart';
import '../domain/weekly_review_models.dart';
import '../domain/weekly_review_recommendation_service.dart';
import '../domain/weekly_review_service.dart';
import '../models/weekly_review.dart';

final weeklyReviewRepositoryProvider = FutureProvider<WeeklyReviewRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return WeeklyReviewRepository(isar);
});

final weeklyReviewRecommendationServiceProvider =
    Provider<WeeklyReviewRecommendationService>((ref) {
      return const WeeklyReviewRecommendationService();
    });

final weeklyReviewServiceProvider = Provider<WeeklyReviewService>((ref) {
  return WeeklyReviewService(
    recommendationService: ref.read(
      weeklyReviewRecommendationServiceProvider,
    ),
  );
});

final selectedWeeklyReviewWeekProvider = StateProvider<DateTime>((ref) {
  final service = ref.read(weeklyReviewServiceProvider);
  return service.weekStartFor(DateTime.now());
});

class WeeklyReviewSourceData {
  const WeeklyReviewSourceData({
    required this.tasks,
    required this.goals,
    required this.sessions,
  });

  final List<Task> tasks;
  final List<LearningGoal> goals;
  final List<PlannedSession> sessions;
}

final _weeklyReviewSourceProvider =
    Provider<AsyncValue<WeeklyReviewSourceData>>((ref) {
      final tasksAsync = ref.watch(watchTasksProvider);
      final goalsAsync = ref.watch(watchGoalsProvider);
      final sessionsAsync = ref.watch(watchAllSessionsProvider);

      return switch ((tasksAsync, goalsAsync, sessionsAsync)) {
        (
          AsyncData(value: final tasks),
          AsyncData(value: final goals),
          AsyncData(value: final sessions),
        ) =>
          AsyncData(
            WeeklyReviewSourceData(
              tasks: tasks,
              goals: goals,
              sessions: sessions,
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

final selectedWeeklyReviewSnapshotProvider =
    Provider<AsyncValue<WeeklyReviewSnapshot>>((ref) {
      final weekStart = ref.watch(selectedWeeklyReviewWeekProvider);
      final service = ref.read(weeklyReviewServiceProvider);
      return ref.watch(_weeklyReviewSourceProvider).whenData((source) {
        final currentSnapshot = service.buildWeeklySnapshot(
          weekStart: weekStart,
          sessions: source.sessions,
          tasks: source.tasks,
          goals: source.goals,
        );
        final previousSnapshot = service.buildWeeklySnapshot(
          weekStart: weekStart.subtract(const Duration(days: 7)),
          sessions: source.sessions,
          tasks: source.tasks,
          goals: source.goals,
        );
        final trendComparison = service.buildTrendComparison(
          current: currentSnapshot,
          previous: previousSnapshot,
        );
        return service.buildWeeklySnapshot(
          weekStart: weekStart,
          sessions: source.sessions,
          tasks: source.tasks,
          goals: source.goals,
          trendComparison: trendComparison,
        );
      });
    });

final selectedWeeklyReviewRecordProvider = StreamProvider<WeeklyReview?>((
  ref,
) async* {
  final repository = await ref.watch(weeklyReviewRepositoryProvider.future);
  final weekStart = ref.watch(selectedWeeklyReviewWeekProvider);
  yield* repository.watchReviewForWeek(weekStart);
});

final watchPastWeeklyReviewsProvider = StreamProvider<List<WeeklyReview>>((
  ref,
) async* {
  final repository = await ref.watch(weeklyReviewRepositoryProvider.future);
  yield* repository.watchPastReviews();
});

final weeklyReviewActionControllerProvider =
    AsyncNotifierProvider<WeeklyReviewActionController, void>(
      WeeklyReviewActionController.new,
    );

class WeeklyReviewActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> saveReflection({
    required WeeklyReviewSnapshot snapshot,
    String? winsText,
    String? challengesText,
    String? nextWeekFocusText,
    bool? isLocked,
  }) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(weeklyReviewRepositoryProvider.future);
      final existing = await repository.getReviewForWeek(snapshot.weekStart);
      final now = DateTime.now();
      final review =
          existing?.copyWith(
            weekEnd: snapshot.weekEnd,
            updatedAt: now,
            summaryText: snapshot.summaryText,
            winsText: _normalizeText(winsText),
            challengesText: _normalizeText(challengesText),
            nextWeekFocusText: _normalizeText(nextWeekFocusText),
            isLocked: isLocked ?? existing.isLocked,
          ) ??
          WeeklyReview(
            id: _reviewId(snapshot.weekStart),
            weekStart: snapshot.weekStart,
            weekEnd: snapshot.weekEnd,
            createdAt: now,
            updatedAt: now,
            summaryText: snapshot.summaryText,
            winsText: _normalizeText(winsText),
            challengesText: _normalizeText(challengesText),
            nextWeekFocusText: _normalizeText(nextWeekFocusText),
            isLocked: isLocked ?? false,
          );
      await repository.saveReview(review);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  String _reviewId(DateTime weekStart) {
    final normalized = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return 'weekly-review-$year$month$day';
  }

  String? _normalizeText(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another weekly review action is already in progress.');
    }
  }
}
