import '../../goals/models/task_dependency.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';
import '../models/planned_session.dart';
import 'rescheduling_models.dart';
import 'schedule_generator_service.dart';

class ReschedulingService {
  ReschedulingService({ScheduleGeneratorService? scheduleGeneratorService})
    : _scheduleGeneratorService =
          scheduleGeneratorService ?? ScheduleGeneratorService();

  final ScheduleGeneratorService _scheduleGeneratorService;

  ReschedulingResult recoverAndReschedule({
    required List<Task> tasks,
    required List<PlannedSession> sessions,
    required List<PlannedSession> missedSessions,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime now,
    List<TaskDependency> dependencies = const [],
    String? activeSessionId,
  }) {
    final horizonStart = now;
    final horizonEnd = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 7));

    final droppedSessions = sessions.where((session) {
      if (session.start.isBefore(horizonStart) ||
          !session.start.isBefore(horizonEnd)) {
        return false;
      }
      if (session.id == activeSessionId) {
        return false;
      }
      return session.isPending || session.isMissed;
    }).toList()..sort((left, right) => left.start.compareTo(right.start));

    final preservedSessions = sessions.where((session) {
      if (session.id == activeSessionId) {
        return true;
      }
      if (session.isCompleted || session.isCancelled) {
        return true;
      }
      if (session.isInProgress) {
        return true;
      }
      return !droppedSessions.any((dropped) => dropped.id == session.id);
    }).toList()..sort((left, right) => left.start.compareTo(right.start));

    final schedulingResult = _scheduleGeneratorService
        .generateNext7DaysSchedule(
          tasks: tasks,
          weeklyAvailability: weeklyAvailability,
          existingSessions: preservedSessions,
          now: now,
          dependencies: dependencies,
        );

    final affectedTaskIds = <String>{
      ...missedSessions.map((session) => session.taskId),
      ...schedulingResult.generatedSessions.map((session) => session.taskId),
    };

    final totalRecoveredMinutes = schedulingResult.generatedSessions.fold<int>(
      0,
      (sum, session) => sum + session.plannedDurationMinutes,
    );
    final totalUnscheduledMinutes = schedulingResult.failures.fold<int>(
      0,
      (sum, failure) => sum + failure.unscheduledMinutes,
    );

    return ReschedulingResult(
      missedSessions: missedSessions,
      rescheduledSessions: schedulingResult.generatedSessions,
      droppedSessions: droppedSessions,
      affectedTaskIds: affectedTaskIds,
      totalRecoveredMinutes: totalRecoveredMinutes,
      totalUnscheduledMinutes: totalUnscheduledMinutes,
      summary: ReschedulingSummary(
        missedSessionCount: missedSessions.length,
        regeneratedSessionCount: schedulingResult.generatedSessions.length,
        totalRecoveredMinutes: totalRecoveredMinutes,
        totalUnscheduledMinutes: totalUnscheduledMinutes,
      ),
      conflicts: schedulingResult.failures
          .map(
            (failure) => ReschedulingConflict(
              taskId: failure.taskId,
              unscheduledMinutes: failure.unscheduledMinutes,
            ),
          )
          .toList(),
    );
  }
}
