import '../../goals/models/learning_goal.dart';
import '../../tasks/models/task.dart';

enum LauncherEntityType { task, goal }

class LauncherEntityResult {
  const LauncherEntityResult({
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.subtitle,
    required this.score,
  });

  final LauncherEntityType entityType;
  final String entityId;
  final String title;
  final String subtitle;
  final int score;
}

class EntityLauncherService {
  const EntityLauncherService();

  List<LauncherEntityResult> search({
    required String query,
    required List<Task> tasks,
    required List<LearningGoal> goals,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = <LauncherEntityResult>[];

    void addTask(Task task, int score) {
      results.add(
        LauncherEntityResult(
          entityType: LauncherEntityType.task,
          entityId: task.id,
          title: task.title.trim().isEmpty ? 'Untitled Task' : task.title,
          subtitle: task.isArchived ? 'Archived task' : task.type.label,
          score: score,
        ),
      );
    }

    void addGoal(LearningGoal goal, int score) {
      results.add(
        LauncherEntityResult(
          entityType: LauncherEntityType.goal,
          entityId: goal.id,
          title: goal.title.trim().isEmpty ? 'Untitled Goal' : goal.title,
          subtitle: goal.goalType.label,
          score: score,
        ),
      );
    }

    if (normalizedQuery.isEmpty) {
      final recentTasks = List<Task>.from(tasks)
        ..sort((left, right) {
          final leftDate = left.updatedAt ?? left.createdAt;
          final rightDate = right.updatedAt ?? right.createdAt;
          return rightDate.compareTo(leftDate);
        });
      final recentGoals = List<LearningGoal>.from(goals)
        ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
      for (final task in recentTasks.take(3)) {
        addTask(task, 100);
      }
      for (final goal in recentGoals.take(3)) {
        addGoal(goal, 95);
      }
    } else {
      for (final task in tasks) {
        final title = task.title.toLowerCase();
        if (title.startsWith(normalizedQuery)) {
          addTask(task, 300);
        } else if (title.contains(normalizedQuery)) {
          addTask(task, 180);
        }
      }
      for (final goal in goals) {
        final title = goal.title.toLowerCase();
        if (title.startsWith(normalizedQuery)) {
          addGoal(goal, 280);
        } else if (title.contains(normalizedQuery)) {
          addGoal(goal, 170);
        }
      }
    }

    results.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) {
        return byScore;
      }
      return left.title.compareTo(right.title);
    });
    return results.take(6).toList();
  }
}
