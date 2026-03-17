import 'analytics_service.dart';
import 'analytics_models.dart';
import '../../goals/models/learning_goal.dart';
import '../../recommendations/domain/recommendation_models.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';

class BurnoutInsightService {
  const BurnoutInsightService({
    this.analyticsService = const AnalyticsService(),
  });

  final AnalyticsService analyticsService;

  BurnoutRiskReport evaluate({
    required List<Task> tasks,
    required List<LearningGoal> goals,
    required List<PlannedSession> sessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
  }) {
    final reasons = <String>[];
    var score = 0;

    final currentWeek = analyticsService.computeWeeklyStats(
      sessions: sessions,
      now: now,
    );
    final previousWeekStart = analyticsService
        .startOfWeek(now)
        .subtract(const Duration(days: 7));
    final previousWeekStats = analyticsService.computeRangeStats(
      range: AnalyticsDateRange(
        start: previousWeekStart,
        end: previousWeekStart.add(const Duration(days: 7)),
        label: 'Previous Week',
      ),
      sessions: sessions,
    );

    final recentMissedSessions = sessions.where((session) {
      return session.isMissed &&
          !session.start.isBefore(now.subtract(const Duration(days: 7)));
    }).length;
    final recentCancelledSessions = sessions.where((session) {
      return session.isCancelled &&
          !session.start.isBefore(now.subtract(const Duration(days: 7)));
    }).length;

    if (currentWeek.plannedMinutes >= 300 && currentWeek.completionRate < 0.6) {
      score += 2;
      reasons.add(
        'This week is heavily loaded, but only ${(currentWeek.completionRate * 100).round()}% of planned time has been completed.',
      );
    }

    if (recentMissedSessions >= 3) {
      score += 2;
      reasons.add(
        'You have missed $recentMissedSessions sessions in the last 7 days.',
      );
    }

    if (recentCancelledSessions >= 2) {
      score += 1;
      reasons.add('Recent cancellations are increasing schedule churn.');
    }

    final hasRestDay = _hasRestDay(weeklyAvailability);
    if (!hasRestDay) {
      score += 1;
      reasons.add(
        'Your timetable has no clear low-load day with at least 3 free hours.',
      );
    }

    final weekOverWeekIncrease =
        currentWeek.plannedMinutes - previousWeekStats.plannedMinutes;
    if (weekOverWeekIncrease >= 180 &&
        currentWeek.plannedMinutes > previousWeekStats.plannedMinutes * 1.4) {
      score += 1;
      reasons.add(
        'Scheduled load jumped by ${_formatHours(weekOverWeekIncrease)} compared with last week.',
      );
    }

    final overdueHighPriorityTasks = tasks.where((task) {
      return !task.isCompleted &&
          task.priority <= 2 &&
          task.dueDate != null &&
          DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
            23,
            59,
          ).isBefore(now);
    }).length;
    final overdueGoals = goals.where((goal) {
      return goal.status == GoalStatus.active &&
          goal.targetDate != null &&
          DateTime(
            goal.targetDate!.year,
            goal.targetDate!.month,
            goal.targetDate!.day,
            23,
            59,
          ).isBefore(now);
    }).length;

    if (overdueHighPriorityTasks + overdueGoals >= 2) {
      score += 2;
      reasons.add(
        'Multiple overdue priorities are competing for limited time.',
      );
    }

    final severity = _severityForScore(score);
    final suggestedAction = _buildSuggestedAction(
      severity: severity,
      recentMissedSessions: recentMissedSessions,
      weekOverWeekIncrease: weekOverWeekIncrease,
      hasRestDay: hasRestDay,
    );

    return BurnoutRiskReport(
      severity: severity,
      reasons: reasons.isEmpty
          ? const [
              'Current workload looks sustainable based on recent behavior.',
            ]
          : reasons,
      suggestedAction: suggestedAction,
      recentMissedSessions: recentMissedSessions,
      recentCancelledSessions: recentCancelledSessions,
      hasRestDay: hasRestDay,
      weekOverWeekPlannedIncreaseMinutes: weekOverWeekIncrease,
    );
  }

  bool _hasRestDay(Map<int, List<AvailabilityWindow>> weeklyAvailability) {
    for (final weekday in List<int>.generate(7, (index) => index + 1)) {
      final totalFreeMinutes =
          (weeklyAvailability[weekday] ?? const <AvailabilityWindow>[])
              .fold<int>(0, (sum, window) {
                final startMinutes = window.startHour * 60 + window.startMinute;
                final endMinutes = window.endHour * 60 + window.endMinute;
                return sum + (endMinutes - startMinutes);
              });
      if (totalFreeMinutes >= 180) {
        return true;
      }
    }
    return false;
  }

  DeadlineRiskLevel _severityForScore(int score) {
    if (score >= 5) {
      return DeadlineRiskLevel.critical;
    }
    if (score >= 3) {
      return DeadlineRiskLevel.high;
    }
    if (score >= 1) {
      return DeadlineRiskLevel.medium;
    }
    return DeadlineRiskLevel.low;
  }

  String _buildSuggestedAction({
    required DeadlineRiskLevel severity,
    required int recentMissedSessions,
    required int weekOverWeekIncrease,
    required bool hasRestDay,
  }) {
    if (severity == DeadlineRiskLevel.low) {
      return 'Keep the current pace and protect your next recovery block.';
    }
    if (recentMissedSessions >= 3) {
      return 'Recover missed sessions selectively and cut low-value work before adding new tasks.';
    }
    if (!hasRestDay) {
      return 'Create at least one lighter day in the timetable to reduce sustained load.';
    }
    if (weekOverWeekIncrease >= 180) {
      return 'Reduce planned load for next week or spread work across a longer horizon.';
    }
    return 'Trim schedule load and prioritise only the most urgent sessions for the next few days.';
  }

  String _formatHours(int minutes) {
    return '${(minutes / 60).toStringAsFixed(1)}h';
  }
}
