import '../../tasks/models/task.dart';
import '../models/goal_milestone.dart';
import '../models/learning_goal.dart';

class GoalTaskGenerationService {
  GoalTaskGenerationService({
    String Function()? idGenerator,
    DateTime Function()? nowProvider,
  }) : _idGenerator = idGenerator,
       _nowProvider = nowProvider;

  final String Function()? _idGenerator;
  final DateTime Function()? _nowProvider;

  List<Task> generateTasksForGoal(
    LearningGoal goal,
    List<GoalMilestone> milestones,
  ) {
    final createdAt = (_nowProvider ?? DateTime.now).call();
    final sortedMilestones = [
      ...milestones,
    ]..sort((left, right) => left.sequenceOrder.compareTo(right.sequenceOrder));

    if (sortedMilestones.isEmpty) {
      if (goal.status == GoalStatus.completed) {
        return const [];
      }
      return [
        _buildTask(
          goal: goal,
          milestone: null,
          title: goal.title,
          description: goal.description,
          estimatedMinutes: goal.estimatedTotalMinutes ?? 60,
          createdAt: createdAt,
        ),
      ];
    }

    return sortedMilestones.where((milestone) => !milestone.isCompleted).map((
      milestone,
    ) {
      return _buildTask(
        goal: goal,
        milestone: milestone,
        title: '${goal.title}: ${milestone.title}',
        description: milestone.description ?? goal.description,
        estimatedMinutes: milestone.estimatedMinutes,
        createdAt: createdAt,
      );
    }).toList();
  }

  Task _buildTask({
    required LearningGoal goal,
    required GoalMilestone? milestone,
    required String title,
    required String? description,
    required int estimatedMinutes,
    required DateTime createdAt,
  }) {
    return Task(
      id: (_idGenerator ?? _defaultIdGenerator).call(),
      title: title,
      description: description,
      type: _mapGoalType(goal.goalType),
      estimatedDurationMinutes: estimatedMinutes,
      dueDate: goal.targetDate,
      priority: goal.priority,
      resourceTag: goal.goalType.label,
      goalId: goal.id,
      milestoneId: milestone?.id,
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
    );
  }

  TaskType _mapGoalType(GoalType goalType) {
    switch (goalType) {
      case GoalType.learning:
      case GoalType.examPrep:
        return TaskType.study;
      case GoalType.project:
        return TaskType.project;
      case GoalType.work:
        return TaskType.coding;
    }
  }

  String _defaultIdGenerator() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
