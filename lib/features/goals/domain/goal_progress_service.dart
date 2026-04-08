import '../../schedule/domain/task_progress_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../models/goal_milestone.dart';
import '../models/learning_goal.dart';

class GoalProgress {
  const GoalProgress({
    required this.totalMilestones,
    required this.completedMilestones,
    required this.totalLinkedTasks,
    required this.completedLinkedTasks,
    required this.totalPlannedMinutes,
    required this.totalCompletedMinutes,
    required this.percentComplete,
    this.completedRoutineOccurrences = 0,
  });

  final int totalMilestones;
  final int completedMilestones;
  final int totalLinkedTasks;
  final int completedLinkedTasks;
  final int totalPlannedMinutes;
  final int totalCompletedMinutes;
  final double percentComplete;
  final int completedRoutineOccurrences;
}

class GoalProgressService {
  const GoalProgressService({
    this.taskProgressService = const TaskProgressService(),
  });

  final TaskProgressService taskProgressService;

  GoalProgress computeGoalProgress({
    required LearningGoal goal,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
    int routineCompletedMinutes = 0,
    int completedRoutineOccurrences = 0,
  }) {
    final linkedTasks = tasks.where((task) => task.goalId == goal.id).toList();
    final completedLinkedTasks = linkedTasks.where((task) {
      return task.isCompleted ||
          taskProgressService.isTaskSatisfied(task, sessions);
    }).length;

    final totalCompletedMinutes = linkedTasks.fold<int>(0, (sum, task) {
      return sum +
          taskProgressService.getCompletedMinutesForTask(task, sessions);
    });

    final estimatedTaskMinutes = linkedTasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedDurationMinutes,
    );
    final milestoneMinutes = milestones.fold<int>(
      0,
      (sum, milestone) => sum + milestone.estimatedMinutes,
    );
    final totalPlannedMinutes = estimatedTaskMinutes > 0
        ? estimatedTaskMinutes
        : goal.estimatedTotalMinutes ?? milestoneMinutes;

    final totalMilestones = milestones.length;
    final completedMilestones = milestones
        .where((item) => item.isCompleted)
        .length;

    final combinedCompletedMinutes = totalCompletedMinutes + routineCompletedMinutes;

    final percentComplete = _computePercentComplete(
      goal: goal,
      totalPlannedMinutes: totalPlannedMinutes,
      totalCompletedMinutes: combinedCompletedMinutes,
      totalMilestones: totalMilestones,
      completedMilestones: completedMilestones,
      totalLinkedTasks: linkedTasks.length,
      completedLinkedTasks: completedLinkedTasks,
    );

    return GoalProgress(
      totalMilestones: totalMilestones,
      completedMilestones: completedMilestones,
      totalLinkedTasks: linkedTasks.length,
      completedLinkedTasks: completedLinkedTasks,
      totalPlannedMinutes: totalPlannedMinutes,
      totalCompletedMinutes:
          combinedCompletedMinutes > totalPlannedMinutes && totalPlannedMinutes > 0
          ? totalPlannedMinutes
          : combinedCompletedMinutes,
      percentComplete: percentComplete,
      completedRoutineOccurrences: completedRoutineOccurrences,
    );
  }

  double _computePercentComplete({
    required LearningGoal goal,
    required int totalPlannedMinutes,
    required int totalCompletedMinutes,
    required int totalMilestones,
    required int completedMilestones,
    required int totalLinkedTasks,
    required int completedLinkedTasks,
  }) {
    if (totalLinkedTasks > 0 && totalPlannedMinutes > 0) {
      final percent = totalCompletedMinutes / totalPlannedMinutes;
      return percent.clamp(0, 1).toDouble();
    }

    if (totalMilestones > 0) {
      return (completedMilestones / totalMilestones).clamp(0, 1).toDouble();
    }

    if (totalLinkedTasks > 0) {
      return (completedLinkedTasks / totalLinkedTasks).clamp(0, 1).toDouble();
    }

    return goal.status == GoalStatus.completed ? 1 : 0;
  }
}

