enum InsightType {
  overload,
  routineTiming,
  missedRoutine,
  recoveryPressure,
  goalRisk,
  consistencyDrop,
  unscheduledWork,
  positivePattern,
}

enum InsightSeverity { info, suggestion, warning, critical }

enum InsightActionType {
  snoozeInsight,
  dismissInsight,
  editRoutine,
  shiftRoutineTime,
  reduceRoutineDuration,
  pauseRoutine,
  openWeeklyPlanner,
  createRecoveryBlock,
  linkToGoal,
  openPlanner,
}

class InsightAction {
  const InsightAction({
    required this.id,
    required this.type,
    required this.label,
    this.routineId,
    this.goalId,
    this.occurrenceId,
    this.suggestedStartMinuteOfDay,
    this.suggestedDurationMinutes,
    this.requiresConfirmation = true,
    this.explanation,
  });

  final String id;
  final InsightActionType type;
  final String label;
  final String? routineId;
  final String? goalId;
  final String? occurrenceId;
  final int? suggestedStartMinuteOfDay;
  final int? suggestedDurationMinutes;
  final bool requiresConfirmation;
  final String? explanation;

  InsightAction copyWith({
    String? id,
    InsightActionType? type,
    String? label,
    String? routineId,
    String? goalId,
    String? occurrenceId,
    int? suggestedStartMinuteOfDay,
    int? suggestedDurationMinutes,
    bool? requiresConfirmation,
    String? explanation,
  }) {
    return InsightAction(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      routineId: routineId ?? this.routineId,
      goalId: goalId ?? this.goalId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      suggestedStartMinuteOfDay:
          suggestedStartMinuteOfDay ?? this.suggestedStartMinuteOfDay,
      suggestedDurationMinutes:
          suggestedDurationMinutes ?? this.suggestedDurationMinutes,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      explanation: explanation ?? this.explanation,
    );
  }
}

class PlanningInsight {
  const PlanningInsight({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.actions,
    required this.createdAt,
    required this.reason,
    this.relatedRoutineId,
    this.relatedGoalId,
    this.relatedOccurrenceId,
    this.evidence = const <String>[],
    this.dismissed = false,
    this.snoozedUntil,
  });

  final String id;
  final InsightType type;
  final InsightSeverity severity;
  final String title;
  final String message;
  final List<InsightAction> actions;
  final DateTime createdAt;
  final String reason;
  final String? relatedRoutineId;
  final String? relatedGoalId;
  final String? relatedOccurrenceId;
  final List<String> evidence;
  final bool dismissed;
  final DateTime? snoozedUntil;

  String get fatigueKey => [
    type.name,
    relatedRoutineId ?? '-',
    relatedGoalId ?? '-',
    relatedOccurrenceId ?? '-',
  ].join(':');

  PlanningInsight copyWith({
    String? id,
    InsightType? type,
    InsightSeverity? severity,
    String? title,
    String? message,
    List<InsightAction>? actions,
    DateTime? createdAt,
    String? reason,
    String? relatedRoutineId,
    String? relatedGoalId,
    String? relatedOccurrenceId,
    List<String>? evidence,
    bool? dismissed,
    DateTime? snoozedUntil,
  }) {
    return PlanningInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
      relatedRoutineId: relatedRoutineId ?? this.relatedRoutineId,
      relatedGoalId: relatedGoalId ?? this.relatedGoalId,
      relatedOccurrenceId: relatedOccurrenceId ?? this.relatedOccurrenceId,
      evidence: evidence ?? this.evidence,
      dismissed: dismissed ?? this.dismissed,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }
}

class WeeklyRoutineInsightSummary {
  const WeeklyRoutineInsightSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.completedRoutineCount,
    required this.missedRoutineCount,
    required this.recoveryLoad,
    required this.overloadedDayCount,
    required this.suggestedAdjustments,
    this.mostConsistentRoutineTitle,
    this.mostFragileRoutineTitle,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int completedRoutineCount;
  final int missedRoutineCount;
  final int recoveryLoad;
  final int overloadedDayCount;
  final List<String> suggestedAdjustments;
  final String? mostConsistentRoutineTitle;
  final String? mostFragileRoutineTitle;
}

extension InsightSeverityX on InsightSeverity {
  String get label {
    switch (this) {
      case InsightSeverity.info:
        return 'Info';
      case InsightSeverity.suggestion:
        return 'Suggestion';
      case InsightSeverity.warning:
        return 'Warning';
      case InsightSeverity.critical:
        return 'Critical';
    }
  }
}
