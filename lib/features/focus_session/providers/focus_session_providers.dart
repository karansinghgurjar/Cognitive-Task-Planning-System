import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schedule/models/planned_session.dart';
import '../../schedule/providers/schedule_providers.dart';
import '../domain/focus_session_state.dart';

typedef FocusClock = DateTime Function();
typedef FocusTickerFactory =
    FocusTicker Function(Duration interval, void Function() onTick);

abstract class FocusTicker {
  void cancel();
}

final focusClockProvider = Provider<FocusClock>((ref) {
  return DateTime.now;
});

final focusTickerFactoryProvider = Provider<FocusTickerFactory>((ref) {
  return (interval, onTick) => _TimerFocusTicker(interval, onTick);
});

final focusSessionControllerProvider =
    NotifierProvider<FocusSessionController, FocusSessionState?>(
      FocusSessionController.new,
    );

class FocusSessionController extends Notifier<FocusSessionState?> {
  FocusTicker? _ticker;
  DateTime? _lastTickAt;
  PlannedSession? _activeSession;
  bool _completionInProgress = false;
  bool _cancellationInProgress = false;

  @override
  FocusSessionState? build() {
    ref.onDispose(_disposeTicker);
    return null;
  }

  Future<void> startSession(PlannedSession session, String taskTitle) async {
    if (state != null || _completionInProgress || _cancellationInProgress) {
      throw StateError('A focus session is already active.');
    }
    if (session.isCompleted) {
      throw StateError('Completed sessions cannot be started.');
    }
    if (session.isCancelled || session.isMissed) {
      throw StateError('This session is no longer available to start.');
    }

    final sessionRepository = await ref.read(
      sessionProgressSessionStoreProvider.future,
    );
    final inProgressSession = session.copyWith(
      status: PlannedSessionStatus.inProgress,
      completed: false,
    );
    await sessionRepository.updateSession(inProgressSession);

    final now = ref.read(focusClockProvider)();
    final plannedDurationSeconds =
        inProgressSession.plannedDurationMinutes * 60;

    _activeSession = inProgressSession;
    _lastTickAt = now;
    state = FocusSessionState(
      plannedSessionId: inProgressSession.id,
      taskId: inProgressSession.taskId,
      taskTitle: taskTitle,
      plannedStart: inProgressSession.start,
      plannedEnd: inProgressSession.end,
      plannedDurationMinutes: inProgressSession.plannedDurationMinutes,
      remainingSeconds: plannedDurationSeconds,
      elapsedSeconds: 0,
      isRunning: true,
      isPaused: false,
      startedAt: now,
      lastResumedAt: now,
    );
    _startTicker();
  }

  void pauseSession() {
    final current = state;
    if (current == null || !current.isRunning) {
      return;
    }

    _applyElapsedTime(ref.read(focusClockProvider)());
    _disposeTicker();
    state = state?.copyWith(
      isRunning: false,
      isPaused: true,
      clearLastResumedAt: false,
    );
  }

  void resumeSession() {
    final current = state;
    if (current == null || !current.isPaused) {
      return;
    }

    final now = ref.read(focusClockProvider)();
    _lastTickAt = now;
    state = current.copyWith(
      isRunning: true,
      isPaused: false,
      lastResumedAt: now,
    );
    _startTicker();
  }

  Future<void> cancelSession() async {
    if (_completionInProgress || _cancellationInProgress) {
      return;
    }
    _cancellationInProgress = true;
    final activeSession = _activeSession;
    _disposeTicker();
    try {
      if (activeSession != null) {
        final sessionRepository = await ref.read(
          sessionProgressSessionStoreProvider.future,
        );
        // v1 rule: cancelling a started focus session marks the linked plan
        // entry as cancelled and does not credit focused minutes.
        await sessionRepository.updateSession(
          activeSession.copyWith(
            status: PlannedSessionStatus.cancelled,
            completed: false,
            actualMinutesFocused: 0,
          ),
        );
      }
      _activeSession = null;
      _lastTickAt = null;
      state = null;
    } finally {
      _cancellationInProgress = false;
    }
  }

  Future<void> tick() async {
    final current = state;
    if (current == null || !current.isRunning) {
      return;
    }

    final now = ref.read(focusClockProvider)();
    _applyElapsedTime(now);

    if ((state?.remainingSeconds ?? 0) <= 0) {
      await completeSession(timerCompletedNormally: true);
    }
  }

  Future<void> completeSession({bool timerCompletedNormally = false}) async {
    if (_completionInProgress || _cancellationInProgress) {
      return;
    }
    final currentState = state;
    final activeSession = _activeSession;
    if (currentState == null || activeSession == null) {
      return;
    }

    _completionInProgress = true;
    _disposeTicker();
    state = currentState.copyWith(isRunning: false, isPaused: false);
    try {
      final progressService = await ref.read(
        sessionProgressServiceProvider.future,
      );
      await progressService.completeSession(
        session: activeSession,
        elapsedSeconds: currentState.elapsedSeconds,
        timerCompletedNormally: timerCompletedNormally,
      );
      _activeSession = null;
      _lastTickAt = null;
      state = null;
    } finally {
      _completionInProgress = false;
    }
  }

  void _startTicker() {
    _disposeTicker();
    _ticker = ref.read(focusTickerFactoryProvider)(
      const Duration(seconds: 1),
      () {
        unawaited(tick());
      },
    );
  }

  void _applyElapsedTime(DateTime now) {
    final current = state;
    if (current == null || _lastTickAt == null) {
      return;
    }

    final deltaSeconds = now.difference(_lastTickAt!).inSeconds;
    if (deltaSeconds <= 0) {
      return;
    }

    final plannedSeconds = current.plannedDurationMinutes * 60;
    final nextElapsed = current.elapsedSeconds + deltaSeconds;
    final clampedElapsed = nextElapsed > plannedSeconds
        ? plannedSeconds
        : nextElapsed;
    final remaining = plannedSeconds - clampedElapsed;

    _lastTickAt = now;
    state = current.copyWith(
      elapsedSeconds: clampedElapsed,
      remainingSeconds: remaining < 0 ? 0 : remaining,
      isRunning: remaining > 0,
      isPaused: remaining <= 0 ? false : current.isPaused,
    );
  }

  void _disposeTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

class _TimerFocusTicker implements FocusTicker {
  _TimerFocusTicker(Duration interval, void Function() onTick)
    : _timer = Timer.periodic(interval, (_) => onTick());

  final Timer _timer;

  @override
  void cancel() {
    _timer.cancel();
  }
}
