import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/schedule/domain/session_progress_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('SessionProgressService', () {
    test('manual completion stores rounded actual focused minutes', () async {
      final sessionStore = _FakeSessionStore();
      final taskStore = _FakeTaskStore(
        Task(
          id: 'task-1',
          title: 'Task 1',
          type: TaskType.study,
          estimatedDurationMinutes: 120,
          priority: 1,
          createdAt: DateTime(2026, 3, 1),
        ),
      );
      final service = SessionProgressService(
        sessionStore: sessionStore,
        taskStore: taskStore,
      );
      final session = _session(id: 'session-1', taskId: 'task-1', minutes: 60);
      sessionStore.sessions.add(session);

      await service.completeSession(session: session, elapsedSeconds: 5);

      expect(sessionStore.updated.single.actualMinutesFocused, 1);
      expect(sessionStore.updated.single.completed, isTrue);
      expect(
        sessionStore.updated.single.status,
        PlannedSessionStatus.completed,
      );
    });

    test(
      'task auto-completes when enough completed session minutes accumulate',
      () async {
        final sessionStore = _FakeSessionStore();
        final taskStore = _FakeTaskStore(
          Task(
            id: 'task-1',
            title: 'Task 1',
            type: TaskType.study,
            estimatedDurationMinutes: 90,
            priority: 1,
            createdAt: DateTime(2026, 3, 1),
          ),
        );
        final service = SessionProgressService(
          sessionStore: sessionStore,
          taskStore: taskStore,
        );

        sessionStore.sessions.add(
          _session(
            id: 'session-old',
            taskId: 'task-1',
            minutes: 30,
          ).copyWith(completed: true, actualMinutesFocused: 30),
        );
        final newSession = _session(
          id: 'session-new',
          taskId: 'task-1',
          minutes: 60,
        );
        sessionStore.sessions.add(newSession);

        await service.completeSession(
          session: newSession,
          elapsedSeconds: 3600,
          timerCompletedNormally: true,
        );

        expect(taskStore.completedTaskIds, ['task-1']);
      },
    );
  });
}

PlannedSession _session({
  required String id,
  required String taskId,
  required int minutes,
}) {
  return PlannedSession(
    id: id,
    taskId: taskId,
    start: DateTime(2026, 3, 16, 9, 0),
    end: DateTime(2026, 3, 16, 9, minutes),
  );
}

class _FakeSessionStore implements SessionProgressSessionStore {
  final List<PlannedSession> sessions = [];
  final List<PlannedSession> updated = [];

  @override
  Future<List<PlannedSession>> getAllSessions() async {
    return List<PlannedSession>.from(sessions);
  }

  @override
  Future<void> updateSession(PlannedSession session) async {
    updated.add(session);
    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
  }
}

class _FakeTaskStore implements SessionProgressTaskStore {
  _FakeTaskStore(this.task);

  final Task task;
  final List<String> completedTaskIds = [];

  @override
  Future<Task?> getTaskById(String id) async {
    if (task.id != id) {
      return null;
    }
    return task;
  }

  @override
  Future<void> markTaskCompleted(String id, DateTime completedAt) async {
    completedTaskIds.add(id);
  }
}
