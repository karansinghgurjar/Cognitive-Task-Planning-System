import '../../goals/domain/dependency_resolution_service.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../schedule/domain/task_progress_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';
import 'feasibility_service.dart';
import 'recommendation_models.dart';
import 'workload_warning_service.dart';

class RecommendationEngineService {
  const RecommendationEngineService({
    this.dependencyResolutionService = const DependencyResolutionService(),
    this.taskProgressService = const TaskProgressService(),
    this.feasibilityService = const FeasibilityService(),
    this.workloadWarningService = const WorkloadWarningService(),
    this.defaultFocusMinutes = 60,
    this.minimumFocusMinutes = 25,
  });

  final DependencyResolutionService dependencyResolutionService;
  final TaskProgressService taskProgressService;
  final FeasibilityService feasibilityService;
  final WorkloadWarningService workloadWarningService;
  final int defaultFocusMinutes;
  final int minimumFocusMinutes;

  TaskRecommendation? recommendNextTask({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<TaskDependency> dependencies,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final activeTasks = tasks.where((task) => !task.isArchived).toList();
    final incompleteTasks = activeTasks.where((task) => !task.isCompleted).toList();
    if (incompleteTasks.isEmpty) {
      return null;
    }

    final dependencyResult = dependencyResolutionService
        .resolveSchedulableTasks(
          tasks: incompleteTasks,
          dependencies: dependencies,
          sessions: plannedSessions,
        );
    final schedulableTasks = dependencyResult.schedulableTasks;
    if (schedulableTasks.isEmpty) {
      return null;
    }

    final currentSession = _currentPlannedSession(
      plannedSessions: plannedSessions,
      now: now,
      taskIds: schedulableTasks.map((task) => task.id).toSet(),
    );
    if (currentSession != null) {
      final task = schedulableTasks.firstWhere(
        (item) => item.id == currentSession.taskId,
      );
      return _buildRecommendation(
        task: task,
        goals: goals,
        plannedSessions: plannedSessions,
        weeklyAvailability: weeklyAvailability,
        now: now,
        description:
            'This task already has an active focus block right now, so it should be your next action.',
        reasoning: 'Active planned session in progress',
        relatedPlannedSessionId: currentSession.id,
        suggestedDurationMinutes: _suggestDuration(
          task: task,
          nextBlock: recommendNextAvailableBlock(
            weeklyAvailability: weeklyAvailability,
            plannedSessions: plannedSessions,
            now: now,
            preferredDurationMinutes: currentSession.plannedDurationMinutes,
            relatedTaskId: task.id,
          ),
          plannedSession: currentSession,
          sessions: plannedSessions,
        ),
      );
    }

    final nextBlock = recommendNextAvailableBlock(
      weeklyAvailability: weeklyAvailability,
      plannedSessions: plannedSessions,
      now: now,
    );

    var bestScore = -1 << 30;
    Task? bestTask;
    String bestReasoning = '';
    String bestDescription = '';
    String? bestPlannedSessionId;

    for (final task in schedulableTasks) {
      final scoreDetails = _scoreTask(
        task: task,
        goals: goals,
        milestones: milestones,
        plannedSessions: plannedSessions,
        weeklyAvailability: weeklyAvailability,
        dependencyResult: dependencyResult,
        now: now,
        nextBlock: nextBlock,
        candidateTasks: schedulableTasks,
      );
      if (scoreDetails.score > bestScore) {
        bestScore = scoreDetails.score;
        bestTask = task;
        bestReasoning = scoreDetails.reasoning;
        bestDescription = scoreDetails.description;
        bestPlannedSessionId = scoreDetails.relatedPlannedSessionId;
      }
    }

    if (bestTask == null) {
      return null;
    }

    return _buildRecommendation(
      task: bestTask,
      goals: goals,
      plannedSessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
      description: bestDescription,
      reasoning: bestReasoning,
      relatedPlannedSessionId: bestPlannedSessionId,
      suggestedDurationMinutes: _suggestDuration(
        task: bestTask,
        nextBlock: recommendNextAvailableBlock(
          weeklyAvailability: weeklyAvailability,
          plannedSessions: plannedSessions,
          now: now,
          preferredDurationMinutes: taskProgressService
              .getRemainingMinutesForTask(bestTask, plannedSessions),
          relatedTaskId: bestTask.id,
        ),
        plannedSession: bestPlannedSessionId == null
            ? null
            : plannedSessions.firstWhere(
                (session) => session.id == bestPlannedSessionId,
              ),
        sessions: plannedSessions,
      ),
    );
  }

  List<WorkloadWarning> computeWorkloadWarnings({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final goalReports = computeGoalFeasibility(
      goals: goals,
      milestones: milestones,
      tasks: tasks,
      plannedSessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );

    return workloadWarningService.detectWarnings(
      tasks: tasks,
      goals: goals,
      goalReports: goalReports,
      sessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );
  }

  List<GoalFeasibilityReport> computeGoalFeasibility({
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<Task> tasks,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    return goals.map((goal) {
      return feasibilityService.evaluateGoalFeasibility(
        goal: goal,
        milestones: milestones.where((item) => item.goalId == goal.id).toList(),
        tasks: tasks,
        sessions: plannedSessions,
        weeklyAvailability: weeklyAvailability,
        now: now,
      );
    }).toList()..sort((left, right) {
      final riskCompare = right.riskLevel.index.compareTo(left.riskLevel.index);
      if (riskCompare != 0) {
        return riskCompare;
      }
      if (left.targetDate == null && right.targetDate != null) {
        return 1;
      }
      if (left.targetDate != null && right.targetDate == null) {
        return -1;
      }
      if (left.targetDate != null && right.targetDate != null) {
        return left.targetDate!.compareTo(right.targetDate!);
      }
      return left.goalTitle.compareTo(right.goalTitle);
    });
  }

  RecommendationSummary buildSummary({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<TaskDependency> dependencies,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final bestNextTask = recommendNextTask(
      tasks: tasks,
      goals: goals,
      milestones: milestones,
      dependencies: dependencies,
      plannedSessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );
    final nextStudyBlock = recommendNextAvailableBlock(
      weeklyAvailability: weeklyAvailability,
      plannedSessions: plannedSessions,
      now: now,
      preferredDurationMinutes:
          bestNextTask?.suggestedDurationMinutes ?? defaultFocusMinutes,
      relatedTaskId: bestNextTask?.taskId,
    );
    final goalReports = computeGoalFeasibility(
      goals: goals,
      milestones: milestones,
      tasks: tasks,
      plannedSessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );
    final warnings = workloadWarningService.detectWarnings(
      tasks: tasks,
      goals: goals,
      goalReports: goalReports,
      sessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );

    final suggestedActions = <String>[];
    if (bestNextTask != null) {
      suggestedActions.add(bestNextTask.suggestedActionText);
    }
    if (warnings.isNotEmpty) {
      suggestedActions.add(warnings.first.suggestedActionText);
    }
    if (goalReports.isNotEmpty) {
      suggestedActions.add(goalReports.first.suggestedActionText);
    }

    return RecommendationSummary(
      bestNextTask: bestNextTask,
      nextStudyBlock: nextStudyBlock,
      workloadWarnings: warnings,
      goalFeasibilityReports: goalReports,
      suggestedActions: suggestedActions.toSet().toList(),
    );
  }

  RecommendedStudyBlock? recommendNextAvailableBlock({
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<PlannedSession> plannedSessions,
    required DateTime now,
    int preferredDurationMinutes = 60,
    String? relatedTaskId,
  }) {
    final windows = feasibilityService.buildConcreteAvailabilityWindows(
      weeklyAvailability: weeklyAvailability,
      start: now,
      end: now.add(const Duration(days: 7)),
    );
    final blockedSessions = plannedSessions.where((session) {
      return !session.isCancelled &&
          !session.isMissed &&
          session.end.isAfter(now) &&
          session.start.isBefore(now.add(const Duration(days: 7)));
    }).toList();
    final freeRanges = feasibilityService.subtractBlockedSessions(
      windows,
      blockedSessions,
    );

    if (freeRanges.isEmpty) {
      return null;
    }

    AvailabilityDateTimeRange? fittingRange;
    for (final range in freeRanges) {
      if (range.durationMinutes >= preferredDurationMinutes &&
          range.durationMinutes >= minimumFocusMinutes) {
        fittingRange = range;
        break;
      }
    }
    fittingRange ??= freeRanges.firstWhere(
      (range) => range.durationMinutes >= minimumFocusMinutes,
      orElse: () => freeRanges.first,
    );

    if (!fittingRange.end.isAfter(fittingRange.start) ||
        fittingRange.durationMinutes < minimumFocusMinutes) {
      return null;
    }

    final suggestedEnd = fittingRange.start.add(
      Duration(
        minutes: fittingRange.durationMinutes >= preferredDurationMinutes
            ? preferredDurationMinutes
            : fittingRange.durationMinutes,
      ),
    );

    return RecommendedStudyBlock(
      start: fittingRange.start,
      end: suggestedEnd,
      title: 'Best next slot',
      description: _describeBlock(fittingRange.start, suggestedEnd, now),
      relatedTaskId: relatedTaskId,
    );
  }

  TaskRecommendation _buildRecommendation({
    required Task task,
    required List<LearningGoal> goals,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
    required String description,
    required String reasoning,
    required int suggestedDurationMinutes,
    String? relatedPlannedSessionId,
  }) {
    final remainingMinutes = taskProgressService.getRemainingMinutesForTask(
      task,
      plannedSessions,
    );
    final riskLevel = feasibilityService.riskLevelForTask(
      task: task,
      sessions: plannedSessions,
      weeklyAvailability: weeklyAvailability,
      now: now,
    );
    final goal = task.goalId == null
        ? null
        : goals
              .where((item) => item.id == task.goalId)
              .cast<LearningGoal?>()
              .firstOrNull;

    return TaskRecommendation(
      taskId: task.id,
      title: task.title,
      description: description,
      reasoning: reasoning,
      riskLevel: riskLevel,
      suggestedDurationMinutes: suggestedDurationMinutes,
      suggestedActionText:
          'Work on ${task.title} for $suggestedDurationMinutes minutes next.',
      relatedGoalId: goal?.id,
      relatedPlannedSessionId: relatedPlannedSessionId,
      confidence: _confidenceForRisk(riskLevel),
      estimatedRequiredMinutes: remainingMinutes,
      estimatedAvailableMinutes: task.dueDate == null
          ? null
          : feasibilityService.estimateAvailableMinutesUntil(
              DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
                23,
                59,
              ),
              weeklyAvailability: weeklyAvailability,
              sessions: plannedSessions,
              now: now,
            ),
    );
  }

  _TaskScore _scoreTask({
    required Task task,
    required List<LearningGoal> goals,
    required List<GoalMilestone> milestones,
    required List<PlannedSession> plannedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DependencyResolutionResult dependencyResult,
    required DateTime now,
    required RecommendedStudyBlock? nextBlock,
    required List<Task> candidateTasks,
  }) {
    var score = 0;
    final reasons = <String>[];
    final remainingMinutes = taskProgressService.getRemainingMinutesForTask(
      task,
      plannedSessions,
    );
    final dueDate = task.dueDate;
    final goal = task.goalId == null
        ? null
        : goals
              .where((item) => item.id == task.goalId)
              .cast<LearningGoal?>()
              .firstOrNull;
    final nearestPlannedSession = _nearestPlannedSession(
      task.id,
      plannedSessions,
      now,
    );

    if (dueDate != null && dueDate.isBefore(now)) {
      score += 180;
      reasons.add('Overdue');
    } else if (dueDate != null) {
      final hoursUntilDue = dueDate.difference(now).inHours;
      if (hoursUntilDue <= 24) {
        score += 120;
        reasons.add('Due within 24h');
      } else if (hoursUntilDue <= 72) {
        score += 80;
        reasons.add('Due within 3 days');
      } else {
        score += 40;
        reasons.add('Has a deadline');
      }
    }

    score += (6 - task.priority) * 25;
    reasons.add('Priority ${task.priority}');

    if (nearestPlannedSession != null) {
      final minutesUntilSession = nearestPlannedSession.start
          .difference(now)
          .inMinutes;
      if (minutesUntilSession <= 120) {
        score += 50;
        reasons.add('Planned soon');
      } else if (minutesUntilSession <= 24 * 60) {
        score += 25;
        reasons.add('Already scheduled today');
      }
    }

    if (goal != null && goal.status == GoalStatus.active) {
      score += goal.priority <= 2 ? 20 : 10;
      reasons.add('Supports active goal');
    }

    if (nextBlock != null && remainingMinutes > nextBlock.durationMinutes) {
      final smallerUrgentExists = candidateTasks.any((candidate) {
        if (candidate.id == task.id) {
          return false;
        }
        final candidateRemaining = taskProgressService
            .getRemainingMinutesForTask(candidate, plannedSessions);
        final urgent =
            candidate.dueDate != null &&
            !candidate.dueDate!.isAfter(now.add(const Duration(days: 3)));
        return urgent && candidateRemaining <= nextBlock.durationMinutes;
      });
      if (smallerUrgentExists) {
        score -= 30;
        reasons.add('Large for next block');
      }
    }

    final description = _describeTaskChoice(
      task: task,
      reasons: reasons,
      remainingMinutes: remainingMinutes,
      milestones: milestones,
      goal: goal,
      dependencyResult: dependencyResult,
    );

    return _TaskScore(
      score: score,
      reasoning: reasons.join(', '),
      description: description,
      relatedPlannedSessionId: nearestPlannedSession?.id,
    );
  }

  PlannedSession? _currentPlannedSession({
    required List<PlannedSession> plannedSessions,
    required DateTime now,
    required Set<String> taskIds,
  }) {
    for (final session in plannedSessions) {
      final active =
          !session.isCancelled &&
          !session.isMissed &&
          !session.isCompleted &&
          !session.start.isAfter(now) &&
          session.end.isAfter(now) &&
          taskIds.contains(session.taskId);
      if (active) {
        return session;
      }
    }
    return null;
  }

  PlannedSession? _nearestPlannedSession(
    String taskId,
    List<PlannedSession> sessions,
    DateTime now,
  ) {
    final candidates = sessions.where((session) {
      return session.taskId == taskId &&
          !session.isCancelled &&
          !session.isMissed &&
          !session.isCompleted &&
          session.end.isAfter(now);
    }).toList()..sort((left, right) => left.start.compareTo(right.start));
    return candidates.isEmpty ? null : candidates.first;
  }

  int _suggestDuration({
    required Task task,
    required RecommendedStudyBlock? nextBlock,
    required PlannedSession? plannedSession,
    required List<PlannedSession> sessions,
  }) {
    final remainingMinutes = taskProgressService.getRemainingMinutesForTask(
      task,
      sessions,
    );
    final blockMinutes =
        plannedSession?.plannedDurationMinutes ?? nextBlock?.durationMinutes;
    if (blockMinutes == null) {
      return remainingMinutes < defaultFocusMinutes
          ? remainingMinutes
          : defaultFocusMinutes;
    }
    final target = remainingMinutes < defaultFocusMinutes
        ? remainingMinutes
        : defaultFocusMinutes;
    final bounded = blockMinutes < target ? blockMinutes : target;
    return bounded < minimumFocusMinutes &&
            remainingMinutes >= minimumFocusMinutes
        ? minimumFocusMinutes
        : bounded;
  }

  String _describeTaskChoice({
    required Task task,
    required List<String> reasons,
    required int remainingMinutes,
    required List<GoalMilestone> milestones,
    required LearningGoal? goal,
    required DependencyResolutionResult dependencyResult,
  }) {
    final milestone = task.milestoneId == null
        ? null
        : milestones
              .where((item) => item.id == task.milestoneId)
              .cast<GoalMilestone?>()
              .firstOrNull;
    final contextParts = <String>[];
    if (goal != null) {
      contextParts.add('goal: ${goal.title}');
    }
    if (milestone != null) {
      contextParts.add('milestone: ${milestone.title}');
    }
    final blockerInfo = dependencyResult.blockedByTaskIds[task.id];
    if (blockerInfo != null && blockerInfo.isNotEmpty) {
      contextParts.add('blocked by ${blockerInfo.join(', ')}');
    }

    final suffix = contextParts.isEmpty ? '' : ' (${contextParts.join(' | ')})';
    return '${task.title} stands out because ${reasons.join(', ').toLowerCase()}. It still needs $remainingMinutes minutes$suffix.';
  }

  String _describeBlock(DateTime start, DateTime end, DateTime now) {
    final isToday =
        start.year == now.year &&
        start.month == now.month &&
        start.day == now.day;
    final dayLabel = isToday
        ? 'Today'
        : '${_weekdayLabel(start.weekday)}, ${start.month}/${start.day}';
    final timeLabel =
        '${_two(start.hour)}:${_two(start.minute)}-${_two(end.hour)}:${_two(end.minute)}';
    return '$dayLabel, $timeLabel';
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  double _confidenceForRisk(DeadlineRiskLevel level) {
    switch (level) {
      case DeadlineRiskLevel.low:
        return 0.6;
      case DeadlineRiskLevel.medium:
        return 0.72;
      case DeadlineRiskLevel.high:
        return 0.84;
      case DeadlineRiskLevel.critical:
        return 0.95;
    }
  }
}

class _TaskScore {
  const _TaskScore({
    required this.score,
    required this.reasoning,
    required this.description,
    required this.relatedPlannedSessionId,
  });

  final int score;
  final String reasoning;
  final String description;
  final String? relatedPlannedSessionId;
}

extension<E> on Iterable<E> {
  E? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}


