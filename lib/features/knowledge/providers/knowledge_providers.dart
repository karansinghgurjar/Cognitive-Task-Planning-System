import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_providers.dart';
import '../../focus_session/providers/focus_session_providers.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/providers/goal_providers.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../routines/providers/routine_providers.dart';
import '../../schedule/models/planned_session.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/knowledge_repository.dart';
import '../domain/knowledge_capture_service.dart';
import '../domain/knowledge_link_service.dart';
import '../domain/knowledge_search_service.dart';
import '../domain/revision_planning_service.dart';
import '../models/knowledge_item.dart';

final knowledgeUuidProvider = Provider<Uuid>((ref) => const Uuid());

final knowledgeRepositoryProvider = FutureProvider<KnowledgeRepository>((
  ref,
) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(
    syncMutationRecorderProvider.future,
  );
  return KnowledgeRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final knowledgeLinkServiceProvider = Provider<KnowledgeLinkService>((ref) {
  return const KnowledgeLinkService();
});

final revisionPlanningServiceProvider = Provider<RevisionPlanningService>((
  ref,
) {
  return const RevisionPlanningService();
});

final knowledgeSearchServiceProvider = Provider<KnowledgeSearchService>((ref) {
  return const KnowledgeSearchService();
});

final knowledgeCaptureServiceProvider = Provider<KnowledgeCaptureService>((
  ref,
) {
  return KnowledgeCaptureService(
    revisionPlanningService: ref.read(revisionPlanningServiceProvider),
  );
});

final watchKnowledgeItemsProvider = StreamProvider<List<KnowledgeItem>>((
  ref,
) async* {
  final repository = await ref.watch(knowledgeRepositoryProvider.future);
  yield* repository.watchAllItems();
});

final watchKnowledgeItemProvider =
    StreamProvider.family<KnowledgeItem?, String>((ref, id) async* {
      final repository = await ref.watch(knowledgeRepositoryProvider.future);
      yield* repository.watchById(id);
    });

final dueKnowledgeItemsProvider = Provider<AsyncValue<List<KnowledgeItem>>>((
  ref,
) {
  final itemsAsync = ref.watch(watchKnowledgeItemsProvider);
  final service = ref.watch(revisionPlanningServiceProvider);
  return itemsAsync.whenData((items) => service.dueItems(items));
});

class KnowledgeDashboardData {
  const KnowledgeDashboardData({
    required this.inbox,
    required this.dueReview,
    required this.recentlyUpdated,
    required this.activeResources,
    required this.linkedToCurrentGoals,
    required this.staleItems,
    required this.completedThisWeek,
  });

  final List<KnowledgeItem> inbox;
  final List<KnowledgeItem> dueReview;
  final List<KnowledgeItem> recentlyUpdated;
  final List<KnowledgeItem> activeResources;
  final List<KnowledgeItem> linkedToCurrentGoals;
  final List<KnowledgeItem> staleItems;
  final List<KnowledgeItem> completedThisWeek;
}

final knowledgeDashboardProvider = Provider<AsyncValue<KnowledgeDashboardData>>(
  (ref) {
    final itemsAsync = ref.watch(watchKnowledgeItemsProvider);
    final goalsAsync = ref.watch(watchGoalsProvider);
    final now = DateTime.now();
    return switch ((itemsAsync, goalsAsync)) {
      (AsyncData(value: final items), AsyncData(value: final goals)) => () {
        final activeGoalIds = goals
            .where((goal) => goal.status == GoalStatus.active)
            .map((goal) => goal.id)
            .toSet();
        final recentlyUpdated = [...items]
          ..sort(
            (left, right) => (right.updatedAt ?? right.createdAt).compareTo(
              left.updatedAt ?? left.createdAt,
            ),
          );
        final completedThisWeek = items.where((item) {
          if (item.status != KnowledgeStatus.completed) {
            return false;
          }
          final updated = item.updatedAt ?? item.createdAt;
          return updated.isAfter(now.subtract(const Duration(days: 7)));
        }).toList();
        return AsyncData(
          KnowledgeDashboardData(
            inbox: items
                .where((item) => item.status == KnowledgeStatus.inbox)
                .toList(),
            dueReview: ref
                .read(revisionPlanningServiceProvider)
                .dueItems(items, now: now),
            recentlyUpdated: recentlyUpdated.take(8).toList(),
            activeResources: items.where((item) {
              return item.status == KnowledgeStatus.active &&
                  item.type != KnowledgeItemType.note;
            }).toList(),
            linkedToCurrentGoals: items.where((item) {
              return item.links.any(
                (link) =>
                    link.entityType == LinkedEntityType.goal &&
                    activeGoalIds.contains(link.entityId),
              );
            }).toList(),
            staleItems: items.where((item) => item.hasStaleLinks).toList(),
            completedThisWeek: completedThisWeek,
          ),
        );
      }(),
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
  },
);

final knowledgeSearchQueryProvider = StateProvider<KnowledgeSearchQuery>((ref) {
  return const KnowledgeSearchQuery();
});

final filteredKnowledgeItemsProvider =
    Provider<AsyncValue<List<KnowledgeItem>>>((ref) {
      final itemsAsync = ref.watch(watchKnowledgeItemsProvider);
      final query = ref.watch(knowledgeSearchQueryProvider);
      final service = ref.watch(knowledgeSearchServiceProvider);
      return itemsAsync.whenData(
        (items) => service.filter(items, query: query),
      );
    });

final knowledgeActionControllerProvider =
    AsyncNotifierProvider<KnowledgeActionController, void>(
      KnowledgeActionController.new,
    );

class KnowledgeActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addItem(KnowledgeItem item) =>
      _run((repository) => repository.addItem(item));

  Future<void> updateItem(KnowledgeItem item) =>
      _run((repository) => repository.updateItem(item));

  Future<void> deleteItem(String id) =>
      _run((repository) => repository.deleteItem(id));

  Future<void> markStatus(KnowledgeItem item, KnowledgeStatus status) {
    return _run((repository) async {
      await repository.updateItem(
        item.copyWith(status: status, updatedAt: DateTime.now()),
      );
    });
  }

  Future<void> scheduleReview(KnowledgeItem item, DateTime dueReviewAt) {
    return _run((repository) async {
      await repository.updateItem(
        item.copyWith(
          dueReviewAt: dueReviewAt,
          status: KnowledgeStatus.reviewing,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> recordReview(KnowledgeItem item, ReviewDifficulty difficulty) {
    return _run((repository) async {
      final updated = ref
          .read(revisionPlanningServiceProvider)
          .recordReview(item, difficulty);
      await repository.updateItem(updated);
    });
  }

  Future<void> linkItem(KnowledgeItem item, EntityLink link) {
    return _run((repository) async {
      final updated = ref
          .read(knowledgeLinkServiceProvider)
          .linkItem(item, link);
      await repository.updateItem(updated);
    });
  }

  Future<void> unlinkItem(KnowledgeItem item, EntityLink link) {
    return _run((repository) async {
      final updated = ref
          .read(knowledgeLinkServiceProvider)
          .unlinkItem(
            item,
            entityId: link.entityId,
            entityType: link.entityType,
          );
      await repository.updateItem(updated);
    });
  }

  Future<Task> createTaskFromItem(KnowledgeItem item) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final captureService = ref.read(knowledgeCaptureServiceProvider);
      final draft = captureService.buildFollowUpTask(item);
      final task = Task(
        id: ref.read(knowledgeUuidProvider).v4(),
        title: draft.title,
        description: draft.description,
        type: TaskType.reading,
        estimatedDurationMinutes: item.reviewIntervalDays != null ? 30 : 45,
        priority: 2,
        createdAt: DateTime.now(),
      );
      final repository = await ref.read(taskRepositoryProvider.future);
      await repository.addTask(task);
      state = const AsyncData(null);
      return task;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> createFocusSessionQuickNote({
    required String title,
    required String content,
  }) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final focus = ref.read(focusSessionControllerProvider);
      if (focus == null) {
        throw StateError('No active focus session is running.');
      }
      final repository = await ref.read(knowledgeRepositoryProvider.future);
      final note = ref
          .read(knowledgeCaptureServiceProvider)
          .buildFocusSessionNote(
            id: ref.read(knowledgeUuidProvider).v4(),
            title: title,
            content: content,
            createdAt: DateTime.now(),
            focusSessionId: focus.plannedSessionId,
            taskId: focus.taskId,
          );
      await repository.addItem(note);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> refreshStaleLinks() async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(knowledgeRepositoryProvider.future);
      final items = await repository.getAllItems();
      final tasks = (ref.read(watchTasksProvider).valueOrNull ?? const <Task>[])
          .map((item) => item.id)
          .toSet();
      final goals =
          (ref.read(watchGoalsProvider).valueOrNull ?? const <LearningGoal>[])
              .map((item) => item.id)
              .toSet();
      final routines =
          (ref.read(watchAllRoutinesProvider).valueOrNull ?? const <Routine>[])
              .map((item) => item.id)
              .toSet();
      final occurrences =
          (ref.read(watchAllRoutineOccurrencesProvider).valueOrNull ??
                  const <RoutineOccurrence>[])
              .map((item) => item.id)
              .toSet();
      final sessions =
          (ref.read(watchAllSessionsProvider).valueOrNull ??
                  const <PlannedSession>[])
              .map((item) => item.id)
              .toSet();
      final milestones =
          (ref.read(watchAllMilestonesProvider).valueOrNull ?? const [])
              .map((item) => item.id)
              .toSet();
      for (final item in items) {
        final updated = ref
            .read(knowledgeLinkServiceProvider)
            .reconcileStaleLinks(
              item,
              entityExists: (entityType, entityId) {
                switch (entityType) {
                  case LinkedEntityType.goal:
                    return goals.contains(entityId);
                  case LinkedEntityType.project:
                    return true;
                  case LinkedEntityType.task:
                    return tasks.contains(entityId);
                  case LinkedEntityType.routine:
                    return routines.contains(entityId);
                  case LinkedEntityType.routineOccurrence:
                    return occurrences.contains(entityId);
                  case LinkedEntityType.focusSession:
                    return sessions.contains(entityId);
                  case LinkedEntityType.milestone:
                    return milestones.contains(entityId);
                }
              },
            );
        await repository.updateItem(updated);
      }
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _run(
    Future<void> Function(KnowledgeRepository repository) action,
  ) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(knowledgeRepositoryProvider.future);
      await action(repository);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another knowledge action is already in progress.');
    }
  }
}
