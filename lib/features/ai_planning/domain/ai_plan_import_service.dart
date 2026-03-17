import 'package:uuid/uuid.dart';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../tasks/models/task.dart';
import 'ai_planning_models.dart';

abstract class AiPlanGoalStore {
  Future<LearningGoal?> getGoalById(String id);
  Future<void> addGoal(LearningGoal goal);
  Future<void> updateGoal(LearningGoal goal);
  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId);
  Future<void> addMilestone(GoalMilestone milestone);
  Future<void> updateMilestone(GoalMilestone milestone);
  Future<List<TaskDependency>> getAllDependencies();
  Future<void> addDependency(TaskDependency dependency);
}

abstract class AiPlanTaskStore {
  Future<List<Task>> getAllTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
}

class AiPlanImportService {
  AiPlanImportService({
    required AiPlanGoalStore goalRepository,
    required AiPlanTaskStore taskRepository,
    Uuid? uuid,
  }) : _goalRepository = goalRepository,
       _taskRepository = taskRepository,
       _uuid = uuid ?? const Uuid();

  final AiPlanGoalStore _goalRepository;
  final AiPlanTaskStore _taskRepository;
  final Uuid _uuid;

  Future<void> importApprovedPlan(
    AiPlanResult result,
    ImportOptions options,
  ) async {
    final allTasks = await _taskRepository.getAllTasks();
    final allDependencies = await _goalRepository.getAllDependencies();

    final goal = await _resolveGoal(result, options);
    final existingMilestones = await _goalRepository.getMilestonesForGoal(
      goal.id,
    );
    final goalTasks = allTasks.where((task) => task.goalId == goal.id).toList();

    final milestoneIdByDraftId = <String, String>{};
    final createdTasksByDraftId = <String, Task>{};

    for (final draft in result.milestones) {
      final existing = _findMilestoneByTitle(existingMilestones, draft.title);
      if (existing != null && options.skipExistingMilestones) {
        milestoneIdByDraftId[draft.id] = existing.id;
        continue;
      }

      final milestone = GoalMilestone(
        id: existing?.id ?? _uuid.v4(),
        goalId: goal.id,
        title: draft.title,
        description: draft.description,
        sequenceOrder: draft.sequenceOrder,
        estimatedMinutes: draft.estimatedMinutes,
        isCompleted: existing?.isCompleted ?? false,
        createdAt: existing?.createdAt ?? DateTime.now(),
        completedAt: existing?.completedAt,
      );

      if (existing == null) {
        await _goalRepository.addMilestone(milestone);
        existingMilestones.add(milestone);
      } else {
        await _goalRepository.updateMilestone(milestone);
      }
      milestoneIdByDraftId[draft.id] = milestone.id;
    }

    for (final draft in result.tasks) {
      final milestoneId = draft.milestoneDraftId == null
          ? null
          : milestoneIdByDraftId[draft.milestoneDraftId!];
      final existing = _findTask(
        goalTasks,
        draft.title,
        milestoneId: milestoneId,
      );
      if (existing != null && options.skipExistingTasks) {
        createdTasksByDraftId[draft.id] = existing;
        continue;
      }

      final task = Task(
        id: existing?.id ?? _uuid.v4(),
        title: draft.title,
        description: draft.description,
        type: draft.type,
        estimatedDurationMinutes: draft.estimatedMinutes,
        dueDate: draft.dueDate ?? result.goal.targetDate,
        priority: result.goal.priority,
        resourceUrl: null,
        resourceTag: 'AI plan',
        goalId: goal.id,
        milestoneId: milestoneId,
        isCompleted: existing?.isCompleted ?? false,
        createdAt: existing?.createdAt ?? DateTime.now(),
        completedAt: existing?.completedAt,
      );

      if (existing == null) {
        await _taskRepository.addTask(task);
        goalTasks.add(task);
      } else {
        await _taskRepository.updateTask(task);
      }
      createdTasksByDraftId[draft.id] = task;
    }

    if (!options.createDependencies) {
      return;
    }

    for (final draft in result.dependencies) {
      final task = createdTasksByDraftId[draft.taskDraftId];
      final dependency = createdTasksByDraftId[draft.dependsOnTaskDraftId];
      if (task == null || dependency == null || task.id == dependency.id) {
        continue;
      }
      final exists = allDependencies.any(
        (item) =>
            item.taskId == task.id && item.dependsOnTaskId == dependency.id,
      );
      if (exists) {
        continue;
      }
      await _goalRepository.addDependency(
        TaskDependency(
          id: _uuid.v4(),
          taskId: task.id,
          dependsOnTaskId: dependency.id,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<LearningGoal> _resolveGoal(
    AiPlanResult result,
    ImportOptions options,
  ) async {
    if (options.existingGoalId != null) {
      final existing = await _goalRepository.getGoalById(
        options.existingGoalId!,
      );
      if (existing != null) {
        final updated = existing.copyWith(
          description: existing.description ?? result.goal.description,
          goalType: result.goal.goalType,
          targetDate: result.goal.targetDate,
          clearTargetDate: result.goal.targetDate == null,
          priority: result.goal.priority,
          estimatedTotalMinutes: result.goal.estimatedTotalMinutes,
          clearEstimatedTotalMinutes: result.goal.estimatedTotalMinutes == null,
        );
        await _goalRepository.updateGoal(updated);
        return updated;
      }
    }

    final goal = LearningGoal(
      id: _uuid.v4(),
      title: result.goal.title,
      description: result.goal.description,
      goalType: result.goal.goalType,
      targetDate: result.goal.targetDate,
      priority: result.goal.priority,
      status: GoalStatus.active,
      estimatedTotalMinutes: result.goal.estimatedTotalMinutes,
      createdAt: DateTime.now(),
      completedAt: null,
    );
    await _goalRepository.addGoal(goal);
    return goal;
  }

  GoalMilestone? _findMilestoneByTitle(
    List<GoalMilestone> milestones,
    String title,
  ) {
    final normalizedTitle = _normalize(title);
    for (final milestone in milestones) {
      if (_normalize(milestone.title) == normalizedTitle) {
        return milestone;
      }
    }
    return null;
  }

  Task? _findTask(
    List<Task> tasks,
    String title, {
    required String? milestoneId,
  }) {
    final normalizedTitle = _normalize(title);
    for (final task in tasks) {
      if (_normalize(task.title) == normalizedTitle &&
          task.milestoneId == milestoneId) {
        return task;
      }
    }
    return null;
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
