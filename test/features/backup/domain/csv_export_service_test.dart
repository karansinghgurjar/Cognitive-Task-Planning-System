import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/analytics/domain/analytics_models.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/backup/domain/csv_export_service.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('CsvExportService', () {
    const service = CsvExportService();

    test('exports tasks CSV with proper escaping', () {
      final csv = service.exportTasksCsv([
        Task(
          id: 'task-1',
          title: 'Read, review, and "ship"',
          type: TaskType.reading,
          estimatedDurationMinutes: 45,
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
      ]);

      expect(csv, contains('"Read, review, and ""ship"""'));
      expect(csv.split('\n').first, contains('id,title,description'));
    });

    test('exports analytics summary CSV with stable headers', () {
      final csv = service.exportAnalyticsSummaryCsv(
        CsvAnalyticsSnapshot(
          rangeLabel: 'Last 7 Days',
          plannedMinutes: 300,
          completedMinutes: 210,
          completionRate: 0.7,
          currentFocusStreak: 4,
          longestFocusStreak: 8,
          goalAnalytics: const [
            GoalAnalytics(
              goalId: 'goal-1',
              goalTitle: 'Flutter',
              goalType: GoalType.learning,
              totalLinkedTasks: 3,
              completedLinkedTasks: 1,
              totalPlannedMinutes: 300,
              totalCompletedMinutes: 120,
              percentComplete: 0.4,
              targetRisk: DeadlineRiskLevel.high,
              averageMinutesPerWeekSpent: 90,
            ),
          ],
          insights: const [
            ProductivityInsight(
              title: 'Stay focused',
              description: 'You are improving.',
              riskLevel: DeadlineRiskLevel.low,
              suggestedAction: 'Keep going.',
            ),
          ],
          burnoutRisk: DeadlineRiskLevel.medium,
        ),
      );

      expect(csv, contains('section,label,value'));
      expect(csv, contains('summary,range,Last 7 Days'));
      expect(csv, contains('goal,Flutter'));
      expect(csv, contains('insight,Stay focused'));
    });
  });
}
