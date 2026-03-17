import '../models/planned_session.dart';

class SessionRecoveryItem {
  const SessionRecoveryItem({
    required this.originalSessionId,
    required this.taskId,
    required this.recoveredMinutes,
  });

  final String originalSessionId;
  final String taskId;
  final int recoveredMinutes;
}

class ReschedulingSummary {
  const ReschedulingSummary({
    required this.missedSessionCount,
    required this.regeneratedSessionCount,
    required this.totalRecoveredMinutes,
    required this.totalUnscheduledMinutes,
  });

  final int missedSessionCount;
  final int regeneratedSessionCount;
  final int totalRecoveredMinutes;
  final int totalUnscheduledMinutes;
}

class ReschedulingConflict {
  const ReschedulingConflict({
    required this.taskId,
    required this.unscheduledMinutes,
  });

  final String taskId;
  final int unscheduledMinutes;
}

class ReschedulingResult {
  const ReschedulingResult({
    required this.missedSessions,
    required this.rescheduledSessions,
    required this.droppedSessions,
    required this.affectedTaskIds,
    required this.totalRecoveredMinutes,
    required this.totalUnscheduledMinutes,
    required this.summary,
    required this.conflicts,
  });

  final List<PlannedSession> missedSessions;
  final List<PlannedSession> rescheduledSessions;
  final List<PlannedSession> droppedSessions;
  final Set<String> affectedTaskIds;
  final int totalRecoveredMinutes;
  final int totalUnscheduledMinutes;
  final ReschedulingSummary summary;
  final List<ReschedulingConflict> conflicts;
}
