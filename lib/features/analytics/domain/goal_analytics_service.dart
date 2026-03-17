import 'analytics_models.dart';
import '../../goals/domain/goal_progress_service.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/feasibility_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';

class GoalAnalyticsService {
  const GoalAnalyticsService({
    this.goalProgressService = const GoalProgressService(),
    this.feasibilityService = const FeasibilityService(),
    this.averageWindowDays = 28,
  });

  final GoalProgressService goalProgressService;
  final FeasibilityService feasibilityService;
  final int averageWindowDays;

  List<GoalAnalytics> computeGoalAnalytics({
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final milestonesByGoal = <String, List<GoalMilestone>>{};
    for (final milestone in milestones) {
      milestonesByGoal.putIfAbsent(milestone.goalId, () => []).add(milestone);
    }

    final tasksByGoal = <String, List<Task>>{};
    for (final task in tasks.where((item) => item.goalId != null)) {
      tasksByGoal.putIfAbsent(task.goalId!, () => []).add(task);
    }

    final trailingWindowStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: averageWindowDays - 1));

    final analytics =
        goals.map((goal) {
          final goalMilestones =
              milestonesByGoal[goal.id] ?? const <GoalMilestone>[];
          final linkedTasks = tasksByGoal[goal.id] ?? const <Task>[];
          final progress = goalProgressService.computeGoalProgress(
            goal: goal,
            milestones: goalMilestones,
            tasks: linkedTasks,
            sessions: sessions,
          );
          final risk = feasibilityService
              .evaluateGoalFeasibility(
                goal: goal,
                milestones: goalMilestones,
                tasks: tasks,
                sessions: sessions,
                weeklyAvailability: weeklyAvailability,
                now: now,
              )
              .riskLevel;

          final trailingMinutes = sessions
              .where((session) {
                return session.isCompleted &&
                    session.start.isAfter(
                      trailingWindowStart.subtract(
                        const Duration(milliseconds: 1),
                      ),
                    ) &&
                    linkedTasks.any((task) => task.id == session.taskId);
              })
              .fold<int>(0, (sum, session) {
                return sum +
                    (session.actualMinutesFocused > 0
                        ? session.actualMinutesFocused
                        : session.plannedDurationMinutes);
              });

          return GoalAnalytics(
            goalId: goal.id,
            goalTitle: goal.title,
            goalType: goal.goalType,
            totalLinkedTasks: progress.totalLinkedTasks,
            completedLinkedTasks: progress.completedLinkedTasks,
            totalPlannedMinutes: progress.totalPlannedMinutes,
            totalCompletedMinutes: progress.totalCompletedMinutes,
            percentComplete: progress.percentComplete,
            targetRisk: risk,
            averageMinutesPerWeekSpent:
                trailingMinutes / (averageWindowDays / 7),
          );
        }).toList()..sort((left, right) {
          final riskCompare = right.targetRisk.index.compareTo(
            left.targetRisk.index,
          );
          if (riskCompare != 0) {
            return riskCompare;
          }
          return left.goalTitle.compareTo(right.goalTitle);
        });

    return analytics;
  }
}
