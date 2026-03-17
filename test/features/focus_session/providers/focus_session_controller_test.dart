import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/focus_session/providers/focus_session_providers.dart';
import 'package:study_flow/features/schedule/domain/session_progress_service.dart';
import 'package:study_flow/features/schedule/models/planned_session.dart';
import 'package:study_flow/features/schedule/providers/schedule_providers.dart';
import 'package:study_flow/features/tasks/models/task.dart';

void main() {
  group('FocusSessionController', () {
    late DateTime now;
    late _FakeSessionStore sessionStore;
    late _FakeTaskStore taskStore;
    late ProviderContainer container;

    setUp(() {
      now = DateTime(2026, 3, 16, 9, 0);
      sessionStore = _FakeSessionStore();
      taskStore = _FakeTaskStore();

      container = ProviderContainer(
        overrides: [
          focusClockProvider.overrideWithValue(() => now),
          focusTickerFactoryProvider.overrideWithValue(
            (interval, onTick) => _FakeFocusTicker(onTick),
          ),
          sessionProgressSessionStoreProvider.overrideWith((ref) async {
            return sessionStore;
          }),
          sessionProgressServiceProvider.overrideWith(
            (ref) async => SessionProgressService(
              sessionStore: sessionStore,
              taskStore: taskStore,
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('start initializes correct duration', () async {
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      final session = _plannedSession(minutes: 30);

      await controller.startSession(session, 'Deep Work');

      final state = container.read(focusSessionControllerProvider);
      expect(state, isNotNull);
      expect(state!.plannedSessionId, session.id);
      expect(state.taskTitle, 'Deep Work');
      expect(state.remainingSeconds, 1800);
      expect(state.elapsedSeconds, 0);
      expect(state.isRunning, isTrue);
      expect(state.isPaused, isFalse);
    });

    test('pause stops countdown and resume continues it', () async {
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      await controller.startSession(_plannedSession(minutes: 10), 'Deep Work');

      now = now.add(const Duration(seconds: 10));
      await controller.tick();
      expect(
        container.read(focusSessionControllerProvider)!.elapsedSeconds,
        10,
      );

      controller.pauseSession();
      now = now.add(const Duration(seconds: 20));
      await controller.tick();
      expect(
        container.read(focusSessionControllerProvider)!.elapsedSeconds,
        10,
      );

      controller.resumeSession();
      now = now.add(const Duration(seconds: 15));
      await controller.tick();
      expect(
        container.read(focusSessionControllerProvider)!.elapsedSeconds,
        25,
      );
    });

    test('auto-complete triggers at zero', () async {
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      final session = _plannedSession(minutes: 1);
      sessionStore.sessions.add(session);

      await controller.startSession(session, 'Deep Work');
      now = now.add(const Duration(minutes: 1));
      await controller.tick();

      expect(container.read(focusSessionControllerProvider), isNull);
      expect(sessionStore.updatedSessions.last.completed, isTrue);
      expect(
        sessionStore.updatedSessions.last.status,
        PlannedSessionStatus.completed,
      );
      expect(sessionStore.updatedSessions.last.actualMinutesFocused, 1);
    });

    test('cancel marks the session cancelled without completing it', () async {
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      final session = _plannedSession(minutes: 20);
      sessionStore.sessions.add(session);

      await controller.startSession(session, 'Deep Work');
      await controller.cancelSession();

      expect(container.read(focusSessionControllerProvider), isNull);
      expect(
        sessionStore.updatedSessions.last.status,
        PlannedSessionStatus.cancelled,
      );
      expect(sessionStore.updatedSessions.last.completed, isFalse);
    });

    test('manual complete updates actual focused minutes', () async {
      final controller = container.read(
        focusSessionControllerProvider.notifier,
      );
      final session = _plannedSession(minutes: 25);
      sessionStore.sessions.add(session);

      await controller.startSession(session, 'Deep Work');
      now = now.add(const Duration(seconds: 95));
      await controller.tick();
      await controller.completeSession();

      expect(sessionStore.updatedSessions.last.actualMinutesFocused, 2);
    });

    test('duplicate completion is ignored while completion is in progress', () async {
      final delayedStore = _DelayedSessionStore();
      final delayedContainer = ProviderContainer(
        overrides: [
          focusClockProvider.overrideWithValue(() => now),
          focusTickerFactoryProvider.overrideWithValue(
            (interval, onTick) => _FakeFocusTicker(onTick),
          ),
          sessionProgressSessionStoreProvider.overrideWith((ref) async {
            return delayedStore;
          }),
          sessionProgressServiceProvider.overrideWith(
            (ref) async => SessionProgressService(
              sessionStore: delayedStore,
              taskStore: taskStore,
            ),
          ),
        ],
      );
      addTearDown(delayedContainer.dispose);

      final controller = delayedContainer.read(
        focusSessionControllerProvider.notifier,
      );
      final session = _plannedSession(minutes: 25);
      delayedStore.sessions.add(session);

      await controller.startSession(session, 'Deep Work');
      final first = controller.completeSession();
      final second = controller.completeSession();

      await Future<void>.delayed(Duration.zero);
      delayedStore.allowCompletion();
      await Future.wait([first, second]);

      expect(delayedStore.completedUpdateCount, 1);
      expect(delayedContainer.read(focusSessionControllerProvider), isNull);
    });
  });
}

PlannedSession _plannedSession({required int minutes}) {
  return PlannedSession(
    id: 'session-1',
    taskId: 'task-1',
    start: DateTime(2026, 3, 16, 9, 0),
    end: DateTime(2026, 3, 16, 9, minutes),
  );
}

class _FakeFocusTicker implements FocusTicker {
  _FakeFocusTicker(this.onTick);

  final void Function() onTick;
  bool cancelled = false;

  @override
  void cancel() {
    cancelled = true;
  }
}

class _FakeSessionStore implements SessionProgressSessionStore {
  final List<PlannedSession> sessions = [];
  final List<PlannedSession> updatedSessions = [];

  @override
  Future<List<PlannedSession>> getAllSessions() async {
    return List<PlannedSession>.from(sessions);
  }

  @override
  Future<void> updateSession(PlannedSession session) async {
    updatedSessions.add(session);
    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
  }
}

class _FakeTaskStore implements SessionProgressTaskStore {
  final Map<String, Task> tasks = {
    'task-1': Task(
      id: 'task-1',
      title: 'Task 1',
      type: TaskType.study,
      estimatedDurationMinutes: 120,
      priority: 1,
      createdAt: DateTime(2026, 3, 1),
    ),
  };
  final List<String> completedTaskIds = [];

  @override
  Future<Task?> getTaskById(String id) async {
    return tasks[id];
  }

  @override
  Future<void> markTaskCompleted(String id, DateTime completedAt) async {
    completedTaskIds.add(id);
  }
}

class _DelayedSessionStore extends _FakeSessionStore {
  final Completer<void> _completionGate = Completer<void>();
  int completedUpdateCount = 0;

  void allowCompletion() {
    if (!_completionGate.isCompleted) {
      _completionGate.complete();
    }
  }

  @override
  Future<void> updateSession(PlannedSession session) async {
    if (session.status == PlannedSessionStatus.completed) {
      completedUpdateCount += 1;
      await _completionGate.future;
    }
    await super.updateSession(session);
  }
}
