import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/isar_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/models/task.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/goal_repository.dart';
import '../domain/dependency_resolution_service.dart';
import '../domain/goal_progress_service.dart';
import '../domain/goal_task_generation_service.dart';
import '../models/goal_milestone.dart';
import '../models/learning_goal.dart';
import '../models/task_dependency.dart';

final goalRepositoryProvider = FutureProvider<GoalRepository>((ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  final syncMutationRecorder = await ref.watch(syncMutationRecorderProvider.future);
  return GoalRepository(isar, syncMutationRecorder: syncMutationRecorder);
});

final watchGoalsProvider = StreamProvider<List<LearningGoal>>((ref) async* {
  final repository = await ref.watch(goalRepositoryProvider.future);
  yield* repository.watchAllGoals();
});

final watchAllMilestonesProvider = StreamProvider<List<GoalMilestone>>((
  ref,
) async* {
  final repository = await ref.watch(goalRepositoryProvider.future);
  yield* repository.watchAllMilestones();
});

final watchMilestonesForGoalProvider =
    StreamProvider.family<List<GoalMilestone>, String>((ref, goalId) async* {
      final repository = await ref.watch(goalRepositoryProvider.future);
      yield* repository.watchMilestonesForGoal(goalId);
    });

final watchDependenciesProvider = StreamProvider<List<TaskDependency>>((
  ref,
) async* {
  final repository = await ref.watch(goalRepositoryProvider.future);
  yield* repository.watchAllDependencies();
});

final goalTaskGenerationServiceProvider = Provider<GoalTaskGenerationService>((
  ref,
) {
  final uuid = const Uuid();
  return GoalTaskGenerationService(idGenerator: uuid.v4);
});

final goalProgressServiceProvider = Provider<GoalProgressService>((ref) {
  return const GoalProgressService();
});

final dependencyResolutionServiceProvider =
    Provider<DependencyResolutionService>((ref) {
      return const DependencyResolutionService();
    });

final goalProgressByGoalProvider =
    Provider.family<AsyncValue<GoalProgress>, String>((ref, goalId) {
      final goalsAsync = ref.watch(watchGoalsProvider);
      final milestonesAsync = ref.watch(watchMilestonesForGoalProvider(goalId));
      final tasksAsync = ref.watch(watchTasksProvider);
      final sessionsAsync = ref.watch(watchAllSessionsProvider);

      return switch ((goalsAsync, milestonesAsync, tasksAsync, sessionsAsync)) {
        (
          AsyncData(value: final goals),
          AsyncData(value: final milestones),
          AsyncData(value: final tasks),
          AsyncData(value: final sessions),
        ) =>
          AsyncData(() {
            LearningGoal? goal;
            for (final candidate in goals) {
              if (candidate.id == goalId) {
                goal = candidate;
                break;
              }
            }
            if (goal == null) {
              return const GoalProgress(
                totalMilestones: 0,
                completedMilestones: 0,
                totalLinkedTasks: 0,
                completedLinkedTasks: 0,
                totalPlannedMinutes: 0,
                totalCompletedMinutes: 0,
                percentComplete: 0,
              );
            }
            return ref
                .read(goalProgressServiceProvider)
                .computeGoalProgress(
                  goal: goal,
                  milestones: milestones,
                  tasks: tasks,
                  sessions: sessions,
                );
          }()),
        (AsyncError(:final error, :final stackTrace), _, _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, AsyncError(:final error, :final stackTrace), _, _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, AsyncError(:final error, :final stackTrace), _) => AsyncError(
          error,
          stackTrace,
        ),
        (_, _, _, AsyncError(:final error, :final stackTrace)) => AsyncError(
          error,
          stackTrace,
        ),
        _ => const AsyncLoading(),
      };
    });

final linkedTasksForGoalProvider =
    Provider.family<AsyncValue<List<Task>>, String>((ref, goalId) {
      return ref.watch(watchTasksProvider).whenData((tasks) {
        return tasks.where((task) => task.goalId == goalId).toList()
          ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
      });
    });

final goalActionControllerProvider =
    AsyncNotifierProvider<GoalActionController, void>(GoalActionController.new);

class GoalActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> addGoal(LearningGoal goal) => _run((repository, _) {
    return repository.addGoal(goal);
  });

  Future<void> updateGoal(LearningGoal goal) => _run((repository, _) {
    return repository.updateGoal(goal);
  });

  Future<void> deleteGoal(String id) => _run((repository, _) {
    return repository.deleteGoal(id);
  });

  Future<void> addMilestone(GoalMilestone milestone) => _run((repository, _) {
    return repository.addMilestone(milestone);
  });

  Future<void> updateMilestone(GoalMilestone milestone) =>
      _run((repository, _) {
        return repository.updateMilestone(milestone);
      });

  Future<void> deleteMilestone(String id) => _run((repository, _) {
    return repository.deleteMilestone(id);
  });

  Future<void> toggleMilestoneCompleted(GoalMilestone milestone) {
    final updated = milestone.copyWith(
      isCompleted: !milestone.isCompleted,
      completedAt: !milestone.isCompleted ? DateTime.now() : null,
      clearCompletedAt: milestone.isCompleted,
    );
    return updateMilestone(updated);
  }

  Future<void> addDependency(TaskDependency dependency) =>
      _run((repository, _) {
        return repository.addDependency(dependency);
      });

  Future<void> deleteDependency(String id) => _run((repository, _) {
    return repository.deleteDependency(id);
  });

  Future<int> generateTasksForGoal(LearningGoal goal) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final goalRepository = await ref.read(goalRepositoryProvider.future);
      final taskRepository = await ref.read(taskRepositoryProvider.future);

      final milestones = await goalRepository.getMilestonesForGoal(goal.id);
      final existingTasks = await taskRepository.getAllTasks();
      final generatedTasks = ref
          .read(goalTaskGenerationServiceProvider)
          .generateTasksForGoal(goal, milestones);

      final existingMilestoneTaskIds = existingTasks
          .where((task) => task.goalId == goal.id)
          .map((task) => task.milestoneId)
          .whereType<String>()
          .toSet();
      final hasGoalLevelTask = existingTasks.any(
        (task) => task.goalId == goal.id && task.milestoneId == null,
      );

      final tasksToCreate = generatedTasks.where((task) {
        if (task.milestoneId != null) {
          return !existingMilestoneTaskIds.contains(task.milestoneId);
        }
        return !hasGoalLevelTask;
      }).toList();

      await taskRepository.addTasks(tasksToCreate);
      debugPrint(
        'Goal task generation: goal=${goal.id} created=${tasksToCreate.length} milestones=${milestones.length}',
      );
      state = const AsyncData(null);
      return tasksToCreate.length;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _ensureIdle() {
    if (state.isLoading) {
      throw StateError('Another goal action is already in progress.');
    }
  }

  Future<void> _run(
    Future<void> Function(
      GoalRepository repository,
      TaskRepository taskRepository,
    )
    action,
  ) async {
    _ensureIdle();
    state = const AsyncLoading();
    try {
      final repository = await ref.read(goalRepositoryProvider.future);
      final taskRepository = await ref.read(taskRepositoryProvider.future);
      await action(repository, taskRepository);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
