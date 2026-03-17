import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/goals/models/learning_goal.dart';
import 'package:study_flow/features/recommendations/domain/feasibility_service.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('FeasibilityService', () {
    const service = FeasibilityService();
    final now = DateTime(2026, 3, 16, 8, 0);

    test('detects shortfall for infeasible goals', () {
      final report = service.evaluateGoalFeasibility(
        goal: LearningGoal(
          id: 'goal-1',
          title: 'Learn Flutter',
          goalType: GoalType.learning,
          targetDate: DateTime(2026, 3, 16),
          priority: 1,
          estimatedTotalMinutes: 240,
          createdAt: DateTime(2026, 3, 1),
        ),
        milestones: const [],
        tasks: const [],
        sessions: const [],
        weeklyAvailability: _weeklyAvailability({
          1: [
            const AvailabilityWindow(
              weekday: 1,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
          ],
        }),
        now: now,
      );

      expect(report.isFeasible, isFalse);
      expect(report.shortfallMinutes, 180);
      expect(report.riskLevel, DeadlineRiskLevel.critical);
    });

    test('treats null deadlines as not time-bound', () {
      final report = service.evaluateGoalFeasibility(
        goal: LearningGoal(
          id: 'goal-1',
          title: 'Prepare DSA',
          goalType: GoalType.examPrep,
          priority: 2,
          estimatedTotalMinutes: 180,
          createdAt: DateTime(2026, 3, 1),
        ),
        milestones: const [],
        tasks: const [],
        sessions: const [],
        weeklyAvailability: const {},
        now: now,
      );

      expect(report.isTimeBound, isFalse);
      expect(report.isFeasible, isTrue);
      expect(report.summary, contains('no target date'));
    });
  });
}

Map<int, List<AvailabilityWindow>> _weeklyAvailability(
  Map<int, List<AvailabilityWindow>> data,
) {
  return {
    for (var weekday = 1; weekday <= 7; weekday++)
      weekday: data[weekday] ?? const [],
  };
}
