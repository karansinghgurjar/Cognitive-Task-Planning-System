import 'package:isar/isar.dart';

import '../../sync/data/sync_mutation_recorder.dart';
import '../../sync/domain/sync_models.dart';
import '../domain/session_progress_service.dart';
import '../models/planned_session.dart';

class PlannedSessionRepository implements SessionProgressSessionStore {
  PlannedSessionRepository(
    this._isar, {
    SyncMutationRecorder syncMutationRecorder = const NoopSyncMutationRecorder(),
  }) : _syncMutationRecorder = syncMutationRecorder;

  final Isar _isar;
  final SyncMutationRecorder _syncMutationRecorder;

  @override
  Future<List<PlannedSession>> getAllSessions() async {
    final sessions = await _isar.plannedSessions.where().findAll();
    sessions.sort(_compareSessions);
    return sessions;
  }

  Stream<List<PlannedSession>> watchAllSessions() {
    return _isar.plannedSessions.watchLazy(fireImmediately: true).asyncMap((_) {
      return getAllSessions();
    });
  }

  Future<PlannedSession?> getSessionById(String id) {
    return _isar.plannedSessions.filter().idEqualTo(id).findFirst();
  }

  Future<List<PlannedSession>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await _isar.plannedSessions
        .filter()
        .startLessThan(end)
        .and()
        .endGreaterThan(start)
        .findAll();
    sessions.sort(_compareSessions);
    return sessions;
  }

  Future<void> addSession(PlannedSession session) async {
    await _isar.writeTxn(() async {
      await _isar.plannedSessions.put(session);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.plannedSession,
      entityId: session.id,
      entity: session,
      operationType: SyncOperationType.create,
    );
  }

  Future<void> addSessions(List<PlannedSession> sessions) async {
    await _isar.writeTxn(() async {
      await _isar.plannedSessions.putAll(sessions);
    });
    for (final session in sessions) {
      await _syncMutationRecorder.recordUpsert(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
        entity: session,
        operationType: SyncOperationType.create,
      );
    }
  }

  @override
  Future<void> updateSession(PlannedSession session) async {
    await _isar.writeTxn(() async {
      await _isar.plannedSessions.put(session);
    });
    await _syncMutationRecorder.recordUpsert(
      entityType: SyncEntityType.plannedSession,
      entityId: session.id,
      entity: session,
      operationType: SyncOperationType.update,
    );
  }

  Future<void> updateSessions(List<PlannedSession> sessions) async {
    await _isar.writeTxn(() async {
      await _isar.plannedSessions.putAll(sessions);
    });
    for (final session in sessions) {
      await _syncMutationRecorder.recordUpsert(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
        entity: session,
        operationType: SyncOperationType.update,
      );
    }
  }

  Future<void> deleteSession(String id) async {
    final session = await _isar.plannedSessions
        .filter()
        .idEqualTo(id)
        .findFirst();
    if (session == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.plannedSessions.delete(session.isarId);
    });
    await _syncMutationRecorder.recordDelete(
      entityType: SyncEntityType.plannedSession,
      entityId: id,
    );
  }

  Future<void> deleteSessionsByTaskId(String taskId) async {
    final sessions = await _isar.plannedSessions
        .filter()
        .taskIdEqualTo(taskId)
        .findAll();
    if (sessions.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.plannedSessions.deleteAll(
        sessions.map((session) => session.isarId).toList(),
      );
    });
    for (final session in sessions) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
      );
    }
  }

  Future<void> deleteSessionsInRange(DateTime start, DateTime end) async {
    final sessions = await getSessionsInRange(start, end);
    if (sessions.isEmpty) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.plannedSessions.deleteAll(
        sessions.map((session) => session.isarId).toList(),
      );
    });
    for (final session in sessions) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
      );
    }
  }

  Future<void> replaceFutureSessionsInRange({
    required DateTime start,
    required DateTime end,
    required List<PlannedSession> newSessions,
    bool keepCompleted = true,
    String? activeSessionId,
  }) async {
    final existingSessions = await getSessionsInRange(start, end);

    final sessionsToDelete = existingSessions.where((session) {
      if (keepCompleted && session.isCompleted) {
        return false;
      }
      if (activeSessionId != null && session.id == activeSessionId) {
        return false;
      }
      return session.status == PlannedSessionStatus.pending ||
          session.status == PlannedSessionStatus.missed;
    }).toList();

    await _isar.writeTxn(() async {
      if (sessionsToDelete.isNotEmpty) {
        await _isar.plannedSessions.deleteAll(
          sessionsToDelete.map((session) => session.isarId).toList(),
        );
      }
      if (newSessions.isNotEmpty) {
        await _isar.plannedSessions.putAll(newSessions);
      }
    });
    for (final session in sessionsToDelete) {
      await _syncMutationRecorder.recordDelete(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
      );
    }
    for (final session in newSessions) {
      await _syncMutationRecorder.recordUpsert(
        entityType: SyncEntityType.plannedSession,
        entityId: session.id,
        entity: session,
        operationType: SyncOperationType.update,
      );
    }
  }

  int _compareSessions(PlannedSession left, PlannedSession right) {
    return left.start.compareTo(right.start);
  }
}
