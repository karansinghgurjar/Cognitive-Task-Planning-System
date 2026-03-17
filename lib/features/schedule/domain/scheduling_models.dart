import '../../tasks/models/task.dart';
import '../models/planned_session.dart';

enum SchedulingFailureReason {
  insufficientTime,
  dependencyBlocked,
  dependencyCycle,
}

class TaskWorkUnit {
  const TaskWorkUnit({required this.task, required this.remainingMinutes});

  final Task task;
  final int remainingMinutes;
}

class SchedulingFailure {
  const SchedulingFailure({
    required this.taskId,
    required this.taskTitle,
    required this.scheduledMinutes,
    required this.unscheduledMinutes,
    this.reason = SchedulingFailureReason.insufficientTime,
    this.blockedByTaskIds = const [],
  });

  final String taskId;
  final String taskTitle;
  final int scheduledMinutes;
  final int unscheduledMinutes;
  final SchedulingFailureReason reason;
  final List<String> blockedByTaskIds;

  bool get isPartial => scheduledMinutes > 0;
}

class SchedulingResult {
  const SchedulingResult({
    required this.generatedSessions,
    required this.failures,
    required this.horizonStart,
    required this.horizonEnd,
  });

  final List<PlannedSession> generatedSessions;
  final List<SchedulingFailure> failures;
  final DateTime horizonStart;
  final DateTime horizonEnd;

  int get totalScheduledMinutes {
    return generatedSessions.fold<int>(
      0,
      (total, session) => total + session.plannedDurationMinutes,
    );
  }

  int get scheduledTaskCount {
    return generatedSessions.map((session) => session.taskId).toSet().length;
  }

  int get partiallyScheduledTaskCount {
    return failures.where((failure) => failure.isPartial).length;
  }

  int get unscheduledTaskCount {
    return failures.where((failure) => !failure.isPartial).length;
  }
}
