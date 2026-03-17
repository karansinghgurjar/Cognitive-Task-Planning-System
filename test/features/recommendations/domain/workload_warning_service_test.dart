import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/recommendations/domain/recommendation_models.dart';
import 'package:study_flow/features/recommendations/domain/workload_warning_service.dart';
import 'package:study_flow/features/tasks/models/task.dart';
import 'package:study_flow/features/timetable/domain/availability_service.dart';

void main() {
  group('WorkloadWarningService', () {
    const service = WorkloadWarningService();
    final now = DateTime(2026, 3, 16, 8, 0);

    test('warns when urgent workload exceeds free time', () {
      final warnings = service.detectWarnings(
        tasks: [
          _task('task-1', 180, DateTime(2026, 3, 18)),
          _task('task-2', 180, DateTime(2026, 3, 19)),
        ],
        goals: const [],
        goalReports: const [],
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
          2: [
            const AvailabilityWindow(
              weekday: 2,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 0,
            ),
          ],
        }),
        now: now,
      );

      expect(warnings, isNotEmpty);
      expect(warnings.first.title, 'Urgent workload exceeds free time');
      expect(
        warnings.first.riskLevel == DeadlineRiskLevel.high ||
            warnings.first.riskLevel == DeadlineRiskLevel.critical,
        isTrue,
      );
    });
  });
}

Task _task(String id, int minutes, DateTime dueDate) {
  return Task(
    id: id,
    title: id,
    type: TaskType.study,
    estimatedDurationMinutes: minutes,
    dueDate: dueDate,
    priority: 1,
    createdAt: DateTime(2026, 3, 1),
  );
}

Map<int, List<AvailabilityWindow>> _weeklyAvailability(
  Map<int, List<AvailabilityWindow>> data,
) {
  return {
    for (var weekday = 1; weekday <= 7; weekday++)
      weekday: data[weekday] ?? const [],
  };
}
