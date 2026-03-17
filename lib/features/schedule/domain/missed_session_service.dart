import '../models/planned_session.dart';

class MissedSessionService {
  const MissedSessionService();

  List<PlannedSession> detectMissedSessions(
    List<PlannedSession> sessions,
    DateTime now,
  ) {
    return sessions.where((session) => isSessionMissed(session, now)).map((
      session,
    ) {
      return session.copyWith(
        status: PlannedSessionStatus.missed,
        completed: false,
      );
    }).toList();
  }

  bool isSessionMissed(PlannedSession session, DateTime now) {
    if (session.isCompleted || session.isCancelled || session.isMissed) {
      return false;
    }

    if (session.isPending && session.end.isBefore(now)) {
      return true;
    }

    if (session.isInProgress && session.end.isBefore(now)) {
      return true;
    }

    return false;
  }
}
