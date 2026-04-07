import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/providers/goal_providers.dart';
import '../../notes/providers/notes_providers.dart';
import '../../quick_capture/providers/quick_capture_providers.dart';
import '../../review/providers/weekly_review_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/search_data_repository.dart';
import '../domain/global_search_service.dart';
import '../domain/search_models.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final searchDataRepositoryProvider = Provider<SearchDataRepository>((ref) {
  return const SearchDataRepository();
});

final globalSearchServiceProvider = Provider<GlobalSearchService>((ref) {
  return const GlobalSearchService();
});

final allNotesProvider = FutureProvider((ref) async {
  final repository = await ref.watch(notesRepositoryProvider.future);
  return repository.getAllNotes();
});

final allWeeklyReviewsProvider = FutureProvider((ref) async {
  final repository = await ref.watch(weeklyReviewRepositoryProvider.future);
  return repository.getAllReviews();
});

final searchDataProvider = Provider<AsyncValue<GlobalSearchData>>((ref) {
  final tasksAsync = ref.watch(watchTasksProvider);
  final goalsAsync = ref.watch(watchGoalsProvider);
  final notesAsync = ref.watch(allNotesProvider);
  final capturesAsync = ref.watch(watchAllCapturesProvider);
  final reviewsAsync = ref.watch(allWeeklyReviewsProvider);

  return switch ((tasksAsync, goalsAsync, notesAsync, capturesAsync, reviewsAsync)) {
    (
      AsyncData(value: final tasks),
      AsyncData(value: final goals),
      AsyncData(value: final notes),
      AsyncData(value: final captures),
      AsyncData(value: final reviews),
    ) =>
      AsyncData(
        ref.read(searchDataRepositoryProvider).buildSearchData(
              tasks: tasks,
              goals: goals,
              notes: notes,
              captures: captures,
              weeklyReviews: reviews,
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

final globalSearchResultsProvider = Provider<AsyncValue<List<GlobalSearchResult>>>(
  (ref) {
    final query = ref.watch(searchQueryProvider);
    return ref.watch(searchDataProvider).whenData((data) {
      return ref.read(globalSearchServiceProvider).search(data, query);
    });
  },
);

final groupedSearchResultsProvider = Provider<AsyncValue<List<SearchSection>>>((ref) {
  return ref.watch(globalSearchResultsProvider).whenData((results) {
    return ref.read(globalSearchServiceProvider).groupResults(results);
  });
});
