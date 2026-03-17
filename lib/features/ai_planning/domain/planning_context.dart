import '../../goals/models/learning_goal.dart';
import '../../tasks/models/task.dart';

enum PlanningIntensityPreference { conservative, balanced, aggressive }

class PlanningContext {
  const PlanningContext({
    required this.availableWeeklyMinutes,
    required this.currentActiveGoalsCount,
    required this.recentAverageCompletedMinutesPerWeek,
    required this.preferredSessionLengthMinutes,
    required this.existingTasks,
    required this.existingGoals,
    required this.promptKeywords,
    required this.isRevisionHint,
    required this.isFromScratchHint,
    required this.isAdvancedHint,
    this.intensityPreference = PlanningIntensityPreference.balanced,
    this.taskTypeSpeedFactors = const {},
    this.longSessionMissRate = 0,
    this.recentMissedSessions = 0,
  });

  final int availableWeeklyMinutes;
  final int currentActiveGoalsCount;
  final int recentAverageCompletedMinutesPerWeek;
  final int preferredSessionLengthMinutes;
  final List<Task> existingTasks;
  final List<LearningGoal> existingGoals;
  final List<String> promptKeywords;
  final bool isRevisionHint;
  final bool isFromScratchHint;
  final bool isAdvancedHint;
  final PlanningIntensityPreference intensityPreference;
  final Map<TaskType, double> taskTypeSpeedFactors;
  final double longSessionMissRate;
  final int recentMissedSessions;
}
