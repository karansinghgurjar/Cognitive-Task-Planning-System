import '../../goals/models/learning_goal.dart';
import '../../schedule/domain/task_progress_service.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';
import 'feasibility_service.dart';
import 'recommendation_models.dart';

class WorkloadWarningService {
  const WorkloadWarningService({
    this.feasibilityService = const FeasibilityService(),
    this.taskProgressService = const TaskProgressService(),
  });

  final FeasibilityService feasibilityService;
  final TaskProgressService taskProgressService;

  List<WorkloadWarning> detectWarnings({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<GoalFeasibilityReport> goalReports,
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final warnings = <WorkloadWarning>[];
    final sevenDaysEnd = now.add(const Duration(days: 7));
    final urgentTasks = tasks.where((task) {
      if (task.isCompleted) {
        return false;
      }
      final dueDate = task.dueDate;
      return dueDate != null && !dueDate.isAfter(sevenDaysEnd);
    }).toList();

    final requiredMinutes = urgentTasks.fold<int>(0, (sum, task) {
      return sum +
          taskProgressService.getRemainingMinutesForTask(task, sessions);
    });
    final availableMinutes = feasibilityService.estimateAvailableMinutesUntil(
      DateTime(sevenDaysEnd.year, sevenDaysEnd.month, sevenDaysEnd.day, 23, 59),
      weeklyAvailability: weeklyAvailability,
      sessions: sessions,
      now: now,
    );

    if (requiredMinutes > availableMinutes && urgentTasks.isNotEmpty) {
      warnings.add(
        WorkloadWarning(
          title: 'Urgent workload exceeds free time',
          description:
              'You have ${_formatHours(availableMinutes)} free in the next 7 days but ${_formatHours(requiredMinutes)} of urgent work.',
          riskLevel: requiredMinutes > availableMinutes * 1.5
              ? DeadlineRiskLevel.critical
              : DeadlineRiskLevel.high,
          suggestedActionText:
              'Reduce scope, move lower-priority work, or add extra study time this week.',
          estimatedRequiredMinutes: requiredMinutes,
          estimatedAvailableMinutes: availableMinutes,
        ),
      );
    }

    final highPrioritySoon = tasks.where((task) {
      if (task.isCompleted || task.priority > 2 || task.dueDate == null) {
        return false;
      }
      return !task.dueDate!.isAfter(now.add(const Duration(days: 3)));
    }).toList();
    if (highPrioritySoon.length >= 3) {
      warnings.add(
        WorkloadWarning(
          title: 'Too many high-priority tasks are due soon',
          description:
              '${highPrioritySoon.length} high-priority tasks are due within the next 3 days.',
          riskLevel: highPrioritySoon.length >= 5
              ? DeadlineRiskLevel.critical
              : DeadlineRiskLevel.high,
          suggestedActionText:
              'Focus on the smallest urgent items first and delay lower-priority work.',
        ),
      );
    }

    for (final report in goalReports.where((report) => !report.isFeasible)) {
      warnings.add(
        WorkloadWarning(
          title: '${report.goalTitle} is at risk',
          description: report.summary,
          riskLevel: report.riskLevel,
          suggestedActionText: report.suggestedActionText,
          relatedGoalId: report.goalId,
          estimatedRequiredMinutes: report.remainingRequiredMinutes,
          estimatedAvailableMinutes: report.availableMinutesUntilTarget,
        ),
      );
    }

    final fragmentationRanges = feasibilityService
        .buildConcreteAvailabilityWindows(
          weeklyAvailability: weeklyAvailability,
          start: now,
          end: now.add(const Duration(days: 7)),
        );
    final blockedSessions = sessions.where((session) {
      return !session.isCancelled &&
          !session.isMissed &&
          session.end.isAfter(now) &&
          session.start.isBefore(now.add(const Duration(days: 7)));
    }).toList();
    final freeRanges = feasibilityService.subtractBlockedSessions(
      fragmentationRanges,
      blockedSessions,
    );
    final tinyRanges = freeRanges.where((range) {
      return range.durationMinutes >= 1 && range.durationMinutes < 25;
    }).length;
    if (tinyRanges >= 3) {
      warnings.add(
        WorkloadWarning(
          title: 'Your schedule is fragmented',
          description:
              'There are $tinyRanges tiny free windows under 25 minutes in the next 7 days.',
          riskLevel: tinyRanges >= 6
              ? DeadlineRiskLevel.high
              : DeadlineRiskLevel.medium,
          suggestedActionText:
              'Protect larger study blocks and avoid spreading sessions too thinly.',
        ),
      );
    }

    final missedSessions = sessions
        .where((session) => session.isMissed)
        .toList();
    if (missedSessions.length >= 2) {
      final missedMinutes = missedSessions.fold<int>(
        0,
        (sum, session) => sum + session.plannedDurationMinutes,
      );
      warnings.add(
        WorkloadWarning(
          title: 'Missed work is accumulating',
          description:
              '${missedSessions.length} missed sessions have created ${_formatHours(missedMinutes)} of backlog.',
          riskLevel: missedSessions.length >= 4
              ? DeadlineRiskLevel.high
              : DeadlineRiskLevel.medium,
          suggestedActionText:
              'Recover and reschedule soon before the backlog compounds.',
          estimatedRequiredMinutes: missedMinutes,
        ),
      );
    }

    warnings.sort(
      (left, right) => right.riskLevel.index.compareTo(left.riskLevel.index),
    );
    return warnings;
  }

  String _formatHours(int minutes) {
    return '${(minutes / 60).toStringAsFixed(1)}h';
  }
}
