import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_providers.dart';
import '../../goals/providers/goal_providers.dart';
import '../../knowledge/providers/knowledge_providers.dart';
import '../../review/providers/weekly_review_providers.dart';
import '../../routines/providers/routine_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../../timetable/providers/timetable_providers.dart';
import '../application/demo_data_service.dart';

final demoDataServiceProvider = FutureProvider<DemoDataService>((ref) async {
  return DemoDataService(
    isar: await ref.watch(isarInstanceProvider.future),
    goalRepository: await ref.watch(goalRepositoryProvider.future),
    taskRepository: await ref.watch(taskRepositoryProvider.future),
    routineRepository: await ref.watch(routineRepositoryProvider.future),
    knowledgeRepository: await ref.watch(knowledgeRepositoryProvider.future),
    sessionRepository: await ref.watch(plannedSessionRepositoryProvider.future),
    timetableRepository: await ref.watch(timetableRepositoryProvider.future),
    weeklyReviewRepository: await ref.watch(weeklyReviewRepositoryProvider.future),
    settingsRepository: await ref.watch(settingsRepositoryProvider.future),
  );
});

final hasDemoDataProvider = FutureProvider<bool>((ref) async {
  return (await ref.watch(demoDataServiceProvider.future)).containsSampleData();
});

final demoDataControllerProvider =
    AsyncNotifierProvider<DemoDataController, void>(DemoDataController.new);

class DemoDataController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<DemoDataSummary> loadSampleData() async {
    state = const AsyncLoading();
    try {
      final service = await ref.read(demoDataServiceProvider.future);
      final summary = await service.loadSampleData();
      _invalidateAppData();
      state = const AsyncData(null);
      return summary;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<int> clearSampleData() async {
    state = const AsyncLoading();
    try {
      final service = await ref.read(demoDataServiceProvider.future);
      final removed = await service.clearSampleData();
      _invalidateAppData();
      state = const AsyncData(null);
      return removed;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _invalidateAppData() {
    ref.invalidate(hasDemoDataProvider);
    ref.invalidate(watchTasksProvider);
    ref.invalidate(watchGoalsProvider);
    ref.invalidate(watchAllMilestonesProvider);
    ref.invalidate(watchAllRoutinesProvider);
    ref.invalidate(watchAllRoutineOccurrencesProvider);
    ref.invalidate(watchKnowledgeItemsProvider);
    ref.invalidate(watchAllSessionsProvider);
    ref.invalidate(watchTimetableSlotsProvider);
    ref.invalidate(watchPastWeeklyReviewsProvider);
    ref.invalidate(notificationPreferencesProvider);
  }
}
