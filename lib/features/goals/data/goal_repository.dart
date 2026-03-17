import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../models/goal_milestone.dart';
import '../models/learning_goal.dart';
import '../models/task_dependency.dart';

class GoalRepository {
  GoalRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder = const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  Future<List<LearningGoal>> getAllGoals() async {
    final goals = await _isar.learningGoals.where().findAll();
    goals.sort(_compareGoals);
    return goals;
  }

  Stream<List<LearningGoal>> watchAllGoals() {
    return _isar.learningGoals.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllGoals();
    });
  }

  Future<LearningGoal?> getGoalById(String id) {
    return _isar.learningGoals.filter().idEqualTo(id).findFirst();
  }

  Future<void> addGoal(LearningGoal goal) async {
    await _isar.writeTxn(() async {
      await _isar.learningGoals.put(goal);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.learningGoal,
      entityId: goal.id,
      entity: goal,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> updateGoal(LearningGoal goal) async {
    await _isar.writeTxn(() async {
      await _isar.learningGoals.put(goal);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.learningGoal,
      entityId: goal.id,
      entity: goal,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteGoal(String id) async {
    final goal = await getGoalById(id);
    if (goal == null) {
      return;
    }
    final milestones = await _isar.goalMilestones
        .filter()
        .goalIdEqualTo(id)
        .findAll();

    await _isar.writeTxn(() async {
      if (milestones.isNotEmpty) {
        await _isar.goalMilestones.deleteAll(
          milestones.map((milestone) => milestone.isarId).toList(),
        );
      }
      await _isar.learningGoals.delete(goal.isarId);
    });
    for (final milestone in milestones) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.goalMilestone,
        entityId: milestone.id,
      );
    }
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.learningGoal,
      entityId: id,
    );
  }

  Future<List<GoalMilestone>> getAllMilestones() async {
    final milestones = await _isar.goalMilestones.where().findAll();
    milestones.sort(_compareMilestones);
    return milestones;
  }

  Stream<List<GoalMilestone>> watchAllMilestones() {
    return _isar.goalMilestones.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllMilestones();
    });
  }

  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId) async {
    final milestones = await _isar.goalMilestones
        .filter()
        .goalIdEqualTo(goalId)
        .findAll();
    milestones.sort(_compareMilestones);
    return milestones;
  }

  Stream<List<GoalMilestone>> watchMilestonesForGoal(String goalId) {
    return _isar.goalMilestones.watchLazy(fireImmediately: true).asyncMap((_) {
      return getMilestonesForGoal(goalId);
    });
  }

  Future<void> addMilestone(GoalMilestone milestone) async {
    await _isar.writeTxn(() async {
      await _isar.goalMilestones.put(milestone);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.goalMilestone,
      entityId: milestone.id,
      entity: milestone,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> updateMilestone(GoalMilestone milestone) async {
    await _isar.writeTxn(() async {
      await _isar.goalMilestones.put(milestone);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.goalMilestone,
      entityId: milestone.id,
      entity: milestone,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> deleteMilestone(String id) async {
    final milestone = await _isar.goalMilestones
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (milestone == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.goalMilestones.delete(milestone.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.goalMilestone,
      entityId: id,
    );
  }

  Future<List<TaskDependency>> getAllDependencies() async {
    final dependencies = await _isar.taskDependencys.where().findAll();
    dependencies.sort((left, right) {
      final taskCompare = left.taskId.compareTo(right.taskId);
      if (taskCompare != 0) {
        return taskCompare;
      }
      return left.dependsOnTaskId.compareTo(right.dependsOnTaskId);
    });
    return dependencies;
  }

  Stream<List<TaskDependency>> watchAllDependencies() {
    return _isar.taskDependencys.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllDependencies();
    });
  }

  Future<void> addDependency(TaskDependency dependency) async {
    await _isar.writeTxn(() async {
      await _isar.taskDependencys.put(dependency);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.taskDependency,
      entityId: dependency.id,
      entity: dependency,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> deleteDependency(String id) async {
    final dependency = await _isar.taskDependencys
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (dependency == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.taskDependencys.delete(dependency.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.taskDependency,
      entityId: id,
    );
  }

  Future<void> deleteDependenciesForTask(String taskId) async {
    final allDependencies = await _isar.taskDependencys.where().findAll();
    final dependencies = allDependencies.where((dependency) {
      return dependency.taskId == taskId || dependency.dependsOnTaskId == taskId;
    }).toList();
    if (dependencies.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.taskDependencys.deleteAll(
        dependencies.map((dependency) => dependency.isarId).toList(),
      );
    });
    for (final dependency in dependencies) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.taskDependency,
        entityId: dependency.id,
      );
    }
  }

  int _compareGoals(LearningGoal left, LearningGoal right) {
    final statusCompare = _goalStatusRank(
      left.status,
    ).compareTo(_goalStatusRank(right.status));
    if (statusCompare != 0) {
      return statusCompare;
    }

    final priorityCompare = left.priority.compareTo(right.priority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }

    final leftTargetDate = left.targetDate;
    final rightTargetDate = right.targetDate;
    if (leftTargetDate == null && rightTargetDate != null) {
      return 1;
    }
    if (leftTargetDate != null && rightTargetDate == null) {
      return -1;
    }
    if (leftTargetDate != null && rightTargetDate != null) {
      final targetCompare = leftTargetDate.compareTo(rightTargetDate);
      if (targetCompare != 0) {
        return targetCompare;
      }
    }

    return right.createdAt.compareTo(left.createdAt);
  }

  int _goalStatusRank(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 0;
      case GoalStatus.paused:
        return 1;
      case GoalStatus.completed:
        return 2;
      case GoalStatus.archived:
        return 3;
    }
  }

  int _compareMilestones(GoalMilestone left, GoalMilestone right) {
    final sequenceCompare = left.sequenceOrder.compareTo(right.sequenceOrder);
    if (sequenceCompare != 0) {
      return sequenceCompare;
    }
    return left.createdAt.compareTo(right.createdAt);
  }
}
