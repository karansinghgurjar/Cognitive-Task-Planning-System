import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/review/domain/weekly_review_models.dart';
import 'package:study_flow/features/review/domain/weekly_review_recommendation_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  test('generateNextWeekRecommendations flags at-risk goals and repeated slips', () {
    const service = WeeklyReviewRecommendationService();
    final snapshot = WeeklyReviewSnapshot(
      weekStart: DateTime(2026, 4, 6),
      weekEnd: DateTime(2026, 4, 12),
      breakdown: const WeeklyCompletionBreakdown(
        totalPlannedMinutes: 240,
        totalCompletedMinutes: 60,
        completionRate: 0.25,
        completedSessionsCount: 1,
        missedSessionsCount: 3,
        cancelledSessionsCount: 0,
      ),
      goalReviews: const [
        WeeklyGoalReview(
          goalId: 'goal-1',
          goalTitle: 'Exam Prep',
          goalType: GoalType.examPrep,
          minutesSpent: 0,
          completedLinkedTasksThisWeek: 0,
          totalLinkedTasks: 2,
          targetRisk: DeadlineRiskLevel.high,
          statusSummary: 'No progress this week.',
        ),
      ],
      taskReviews: const [
        WeeklyTaskReview(
          taskId: 'task-1',
          taskTitle: 'Revise graphs',
          taskType: TaskType.study,
          plannedMinutes: 180,
          completedMinutes: 0,
          completedSessionsCount: 0,
          missedSessionsCount: 2,
          cancelledSessionsCount: 1,
          slipCount: 3,
          wasCompletedThisWeek: false,
          isOverdue: false,
          isArchived: false,
          statusSummary: 'Slipped repeatedly.',
        ),
      ],
      recommendations: const [],
      overdueTaskTitles: const [],
      repeatedSlipTaskTitles: const ['Revise graphs'],
      summaryText: 'Tough week.',
    );
    final sessions = [
      PlannedSession(
        id: 'session-1',
        taskId: 'task-1',
        start: DateTime(2026, 4, 7, 9),
        end: DateTime(2026, 4, 7, 11),
        status: PlannedSessionStatus.missed,
      ),
      PlannedSession(
        id: 'session-2',
        taskId: 'task-1',
        start: DateTime(2026, 4, 8, 9),
        end: DateTime(2026, 4, 8, 11),
        status: PlannedSessionStatus.completed,
        completed: true,
        actualMinutesFocused: 60,
      ),
    ];

    final recommendations = service.generateNextWeekRecommendations(
      snapshot: snapshot,
      weeklySessions: sessions,
    );

    expect(
      recommendations.any((item) => item.title.contains('Exam Prep')),
      isTrue,
    );
    expect(
      recommendations.any((item) => item.title.contains('Revise graphs')),
      isTrue,
    );
  });
}
