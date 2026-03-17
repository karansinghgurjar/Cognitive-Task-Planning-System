class FocusSessionState {
  const FocusSessionState({
    required this.plannedSessionId,
    required this.taskId,
    required this.taskTitle,
    required this.plannedStart,
    required this.plannedEnd,
    required this.plannedDurationMinutes,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
    required this.startedAt,
    required this.lastResumedAt,
  });

  final String plannedSessionId;
  final String taskId;
  final String taskTitle;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final int plannedDurationMinutes;
  final int remainingSeconds;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final DateTime? startedAt;
  final DateTime? lastResumedAt;

  Duration get remainingDuration => Duration(seconds: remainingSeconds);

  Duration get elapsedDuration => Duration(seconds: elapsedSeconds);

  double get completionPercentage {
    final totalSeconds = plannedDurationMinutes * 60;
    if (totalSeconds <= 0) {
      return 0;
    }
    return elapsedSeconds / totalSeconds;
  }

  FocusSessionState copyWith({
    String? plannedSessionId,
    String? taskId,
    String? taskTitle,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    int? plannedDurationMinutes,
    int? remainingSeconds,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? lastResumedAt,
    bool clearLastResumedAt = false,
  }) {
    return FocusSessionState(
      plannedSessionId: plannedSessionId ?? this.plannedSessionId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      plannedStart: plannedStart ?? this.plannedStart,
      plannedEnd: plannedEnd ?? this.plannedEnd,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      lastResumedAt: clearLastResumedAt
          ? null
          : lastResumedAt ?? this.lastResumedAt,
    );
  }
}
