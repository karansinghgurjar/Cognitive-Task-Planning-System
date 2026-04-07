import '../../recommendations/domain/recommendation_models.dart';
import '../../schedule/models/planned_session.dart';
import 'weekly_review_models.dart';

class WeeklyReviewRecommendationService {
  const WeeklyReviewRecommendationService();

  List<WeeklyRecommendation> generateNextWeekRecommendations({
    required WeeklyReviewSnapshot snapshot,
    required List<PlannedSession> weeklySessions,
  }) {
    final recommendations = <WeeklyRecommendation>[];

    final atRiskGoal = snapshot.goalReviews.where((goal) {
      return goal.targetRisk == DeadlineRiskLevel.high ||
          goal.targetRisk == DeadlineRiskLevel.critical;
    }).fold<WeeklyGoalReview?>(null, (current, candidate) {
      if (current == null) {
        return candidate;
      }
      return candidate.minutesSpent < current.minutesSpent ? candidate : current;
    });

    if (atRiskGoal != null) {
      recommendations.add(
        WeeklyRecommendation(
          title: 'Protect ${atRiskGoal.goalTitle} next week',
          description:
              '${atRiskGoal.goalTitle} is near its target date but only received ${atRiskGoal.minutesSpent} focused minutes this week.',
          suggestedAction:
              'Reserve an early-week session for this goal before lower-priority work expands.',
          riskLevel: atRiskGoal.targetRisk,
        ),
      );
    }

    final slippedTask = snapshot.taskReviews.where((task) {
      return task.slipCount >= 2;
    }).fold<WeeklyTaskReview?>(null, (current, candidate) {
      if (current == null) {
        return candidate;
      }
      return candidate.slipCount > current.slipCount ? candidate : current;
    });

    if (slippedTask != null) {
      final missedDurations = weeklySessions
          .where(
            (session) =>
                session.taskId == slippedTask.taskId &&
                (session.isMissed || session.isCancelled),
          )
          .map((session) => session.plannedDurationMinutes)
          .toList();
      final averageMissedDuration = missedDurations.isEmpty
          ? 0
          : missedDurations.reduce((left, right) => left + right) ~/
              missedDurations.length;

      recommendations.add(
        WeeklyRecommendation(
          title: 'Reduce friction for ${slippedTask.taskTitle}',
          description:
              '${slippedTask.taskTitle} slipped ${slippedTask.slipCount} times this week${averageMissedDuration > 0 ? ' across sessions averaging $averageMissedDuration minutes' : ''}.',
          suggestedAction: averageMissedDuration >= 90
              ? 'Break this work into shorter sessions next week.'
              : 'Schedule this task in a smaller protected block early in the week.',
          riskLevel: slippedTask.slipCount >= 3
              ? DeadlineRiskLevel.high
              : DeadlineRiskLevel.medium,
        ),
      );
    }

    if (snapshot.breakdown.missedSessionsCount >
        snapshot.breakdown.completedSessionsCount) {
      recommendations.add(
        WeeklyRecommendation(
          title: 'Reduce overload next week',
          description:
              'You missed ${snapshot.breakdown.missedSessionsCount} sessions and completed ${snapshot.breakdown.completedSessionsCount}.',
          suggestedAction:
              'Trim the number of planned sessions or shorten low-confidence blocks before regenerating the schedule.',
          riskLevel: DeadlineRiskLevel.high,
        ),
      );
    }

    final completedByWeekday = <int, int>{};
    for (final session in weeklySessions.where((session) => session.isCompleted)) {
      completedByWeekday.update(
        session.start.weekday,
        (value) => value + _effectiveCompletedMinutes(session),
        ifAbsent: () => _effectiveCompletedMinutes(session),
      );
    }
    if (completedByWeekday.isNotEmpty) {
      final bestWeekday = completedByWeekday.entries.reduce(
        (left, right) => left.value >= right.value ? left : right,
      );
      recommendations.add(
        WeeklyRecommendation(
          title: 'Lean on your strongest weekday',
          description:
              'You completed the most focused time on ${_weekdayLabel(bestWeekday.key)} this week.',
          suggestedAction:
              'Place your hardest or highest-priority sessions on ${_weekdayLabel(bestWeekday.key)} next week.',
          riskLevel: DeadlineRiskLevel.low,
        ),
      );
    }

    return recommendations.take(4).toList();
  }

  int _effectiveCompletedMinutes(PlannedSession session) {
    if (!session.isCompleted) {
      return 0;
    }
    return session.actualMinutesFocused > 0
        ? session.actualMinutesFocused
        : session.plannedDurationMinutes;
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'that day';
    }
  }
}
