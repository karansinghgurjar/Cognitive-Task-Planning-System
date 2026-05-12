import '../../goals/models/learning_goal.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';
import 'planning_insight_models.dart';

class PlanningInsightContext {
  const PlanningInsightContext({
    required this.routines,
    required this.occurrences,
    required this.tasks,
    required this.sessions,
    required this.goals,
    required this.timetableSlots,
    required this.now,
  });

  final List<Routine> routines;
  final List<RoutineOccurrence> occurrences;
  final List<Task> tasks;
  final List<PlannedSession> sessions;
  final List<LearningGoal> goals;
  final List<TimetableSlot> timetableSlots;
  final DateTime now;
}

class PlanningInsightService {
  const PlanningInsightService({
    this.dailyPlannedMinutesWarning = 8 * 60,
    this.eveningPlannedMinutesWarning = 3 * 60,
    this.weeklyRoutineLoadWarning = 16 * 60,
    this.recoveryPressureWarning = 3,
    this.flexibleUnscheduledWarning = 2,
  });

  final int dailyPlannedMinutesWarning;
  final int eveningPlannedMinutesWarning;
  final int weeklyRoutineLoadWarning;
  final int recoveryPressureWarning;
  final int flexibleUnscheduledWarning;

  List<PlanningInsight> generateInsights(PlanningInsightContext context) {
    final insights = <PlanningInsight>[
      ..._buildOverloadInsights(context),
      ..._buildRecoveryPressureInsights(context),
      ..._buildUnscheduledFlexibleInsights(context),
      ..._buildRoutinePatternInsights(context),
      ..._buildGoalInsights(context),
    ];
    return dedupeInsights(insights)..sort(_sortInsights);
  }

  List<PlanningInsight> dedupeInsights(List<PlanningInsight> insights) {
    final byId = <String, PlanningInsight>{};
    for (final insight in insights) {
      final existing = byId[insight.id];
      if (existing == null ||
          _severityRank(insight.severity) > _severityRank(existing.severity)) {
        byId[insight.id] = insight;
      }
    }
    return byId.values.toList();
  }

  WeeklyRoutineInsightSummary buildWeeklyRoutineSummary({
    required DateTime weekStart,
    required List<Routine> routines,
    required List<RoutineOccurrence> occurrences,
    required List<PlanningInsight> insights,
    required DateTime now,
  }) {
    final start = _dateOnly(weekStart);
    final end = start.add(const Duration(days: 6));
    final routineById = {for (final routine in routines) routine.id: routine};
    final weekOccurrences = occurrences.where((occurrence) {
      final day = _dateOnly(occurrence.occurrenceDate);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();

    final completed = weekOccurrences
        .where(
          (occurrence) =>
              occurrence.effectiveStatusAt(now) ==
              RoutineOccurrenceStatus.completed,
        )
        .length;
    final missed = weekOccurrences
        .where(
          (occurrence) =>
              occurrence.effectiveStatusAt(now) ==
              RoutineOccurrenceStatus.missed,
        )
        .length;
    final recoveryLoad = weekOccurrences
        .where((occurrence) => occurrence.isRecoveryInstance)
        .length;
    final overloadedDayCount = insights
        .where((insight) => insight.type == InsightType.overload)
        .length;

    final scoreByRoutine = <String, _RoutineScore>{};
    for (final occurrence in weekOccurrences) {
      final score = scoreByRoutine.putIfAbsent(
        occurrence.routineId,
        () => _RoutineScore(routineId: occurrence.routineId),
      );
      final status = occurrence.effectiveStatusAt(now);
      if (status == RoutineOccurrenceStatus.completed) {
        score.completed += 1;
      } else if (status == RoutineOccurrenceStatus.missed ||
          status == RoutineOccurrenceStatus.skipped) {
        score.fragile += 1;
      }
    }

    _RoutineScore? mostConsistent;
    _RoutineScore? mostFragile;
    for (final score in scoreByRoutine.values) {
      if (score.completed > 0 &&
          (mostConsistent == null ||
              score.completed > mostConsistent.completed)) {
        mostConsistent = score;
      }
      if (score.fragile > 0 &&
          (mostFragile == null || score.fragile > mostFragile.fragile)) {
        mostFragile = score;
      }
    }

    final suggestedAdjustments = insights
        .where((insight) => insight.severity != InsightSeverity.info)
        .take(4)
        .map((insight) => insight.title)
        .toList();

    return WeeklyRoutineInsightSummary(
      weekStart: start,
      weekEnd: end,
      completedRoutineCount: completed,
      missedRoutineCount: missed,
      recoveryLoad: recoveryLoad,
      overloadedDayCount: overloadedDayCount,
      suggestedAdjustments: suggestedAdjustments,
      mostConsistentRoutineTitle: mostConsistent == null
          ? null
          : routineById[mostConsistent.routineId]?.title,
      mostFragileRoutineTitle: mostFragile == null
          ? null
          : routineById[mostFragile.routineId]?.title,
    );
  }

  List<PlanningInsight> _buildOverloadInsights(PlanningInsightContext context) {
    final now = context.now;
    final start = _dateOnly(now);
    final insights = <PlanningInsight>[];
    final daily = <DateTime, _LoadBucket>{};

    for (var index = 0; index < 7; index += 1) {
      final day = start.add(Duration(days: index));
      daily[day] = _LoadBucket(day: day);
    }

    for (final session in context.sessions) {
      final day = _dateOnly(session.start);
      final bucket = daily[day];
      if (bucket == null || session.isCancelled) {
        continue;
      }
      bucket.plannedMinutes += session.plannedDurationMinutes;
      bucket.eveningMinutes += _eveningOverlapMinutes(
        session.start,
        session.end,
      );
    }

    for (final occurrence in context.occurrences) {
      final day = _dateOnly(occurrence.occurrenceDate);
      final bucket = daily[day];
      if (bucket == null) {
        continue;
      }
      final status = occurrence.effectiveStatusAt(now);
      if (status != RoutineOccurrenceStatus.pending &&
          status != RoutineOccurrenceStatus.completed) {
        continue;
      }
      final minutes =
          occurrence.durationMinutes ??
          context.routines
              .where((routine) => routine.id == occurrence.routineId)
              .map((routine) => routine.preferredDurationMinutes ?? 0)
              .fold<int>(0, (left, right) => right > 0 ? right : left);
      bucket.plannedMinutes += minutes;
      if (occurrence.isRecoveryInstance) {
        bucket.recoveryBlocks += 1;
      }
      final startTime = occurrence.scheduledStart;
      final endTime = occurrence.scheduledEnd;
      if (startTime != null && endTime != null) {
        bucket.eveningMinutes += _eveningOverlapMinutes(startTime, endTime);
      }
    }

    for (final task in context.tasks) {
      final dueDate = task.dueDate;
      if (task.isCompleted || task.isArchived || dueDate == null) {
        continue;
      }
      final day = _dateOnly(dueDate);
      final bucket = daily[day];
      if (bucket != null) {
        bucket.plannedMinutes += task.estimatedDurationMinutes;
      }
    }

    for (final slot in context.timetableSlots.where((slot) => slot.isBusy)) {
      for (final bucket in daily.values.where(
        (bucket) => bucket.day.weekday == slot.weekday,
      )) {
        bucket.busyMinutes += (slot.endMinutesOfDay - slot.startMinutesOfDay)
            .clamp(0, 24 * 60);
      }
    }

    for (final bucket in daily.values) {
      final freeCapacity = (14 * 60 - bucket.busyMinutes).clamp(0, 14 * 60);
      if (bucket.plannedMinutes > dailyPlannedMinutesWarning ||
          bucket.plannedMinutes > freeCapacity) {
        insights.add(
          PlanningInsight(
            id: 'overload:${_ymd(bucket.day)}',
            type: InsightType.overload,
            severity: bucket.plannedMinutes > 10 * 60
                ? InsightSeverity.warning
                : InsightSeverity.suggestion,
            title: '${_weekday(bucket.day)} looks overloaded',
            message:
                '${_weekday(bucket.day)} has ${_formatMinutes(bucket.plannedMinutes)} planned against about ${_formatMinutes(freeCapacity)} free capacity.',
            reason:
                'Planned routine, task, and session minutes exceed the calm daily planning threshold.',
            createdAt: now,
            evidence: [
              'Planned minutes: ${bucket.plannedMinutes}',
              'Busy timetable minutes: ${bucket.busyMinutes}',
            ],
            actions: const [
              InsightAction(
                id: 'open-planner',
                type: InsightActionType.openPlanner,
                label: 'Open Planner',
                requiresConfirmation: false,
              ),
            ],
          ),
        );
      }
      if (bucket.eveningMinutes > eveningPlannedMinutesWarning) {
        insights.add(
          PlanningInsight(
            id: 'evening-overload:${_ymd(bucket.day)}',
            type: InsightType.overload,
            severity: InsightSeverity.suggestion,
            title: '${_weekday(bucket.day)} evening is crowded',
            message:
                '${_weekday(bucket.day)} has ${_formatMinutes(bucket.eveningMinutes)} planned after 6 PM. Move flexible work earlier if possible.',
            reason:
                'Evening load is above the deterministic threshold for sustainable planning.',
            createdAt: now,
            actions: const [
              InsightAction(
                id: 'open-planner',
                type: InsightActionType.openPlanner,
                label: 'Open Planner',
                requiresConfirmation: false,
              ),
            ],
          ),
        );
      }
    }

    final weeklyRoutineLoad = context.routines
        .where((routine) => routine.generatesOccurrences)
        .fold<int>(0, (total, routine) {
          return total +
              ((routine.preferredDurationMinutes ?? 0) *
                  _weeklyOccurrences(routine));
        });
    if (weeklyRoutineLoad > weeklyRoutineLoadWarning) {
      insights.add(
        PlanningInsight(
          id: 'weekly-routine-load:${_ymd(start)}',
          type: InsightType.overload,
          severity: InsightSeverity.suggestion,
          title: 'Routine template load is high',
          message:
              'Active routines add about ${_formatMinutes(weeklyRoutineLoad)} each week. Check whether templates created more load than you meant.',
          reason:
              'Recurring routine minutes exceed the weekly routine load threshold.',
          createdAt: now,
          actions: const [
            InsightAction(
              id: 'open-planner',
              type: InsightActionType.openPlanner,
              label: 'Review Routine Load',
              requiresConfirmation: false,
            ),
          ],
        ),
      );
    }
    return insights;
  }

  List<PlanningInsight> _buildRecoveryPressureInsights(
    PlanningInsightContext context,
  ) {
    final now = context.now;
    final today = _dateOnly(now);
    final end = today.add(const Duration(days: 7));
    final recovery = context.occurrences.where((occurrence) {
      final day = _dateOnly(occurrence.occurrenceDate);
      return occurrence.isRecoveryInstance &&
          !day.isBefore(today) &&
          !day.isAfter(end) &&
          occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
    }).toList();
    if (recovery.length < recoveryPressureWarning) {
      return const [];
    }
    return [
      PlanningInsight(
        id: 'recovery-pressure:${_ymd(today)}',
        type: InsightType.recoveryPressure,
        severity: InsightSeverity.suggestion,
        title: 'Recovery pressure is high this week',
        message:
            'There are ${recovery.length} recovery routine blocks in the next week. Prioritize the highest value ones and skip low-value recoveries.',
        reason:
            'Pending recovery instances reached the configured pressure threshold.',
        createdAt: now,
        actions: const [
          InsightAction(
            id: 'open-planner',
            type: InsightActionType.openPlanner,
            label: 'Open Planner',
            requiresConfirmation: false,
          ),
        ],
      ),
    ];
  }

  List<PlanningInsight> _buildUnscheduledFlexibleInsights(
    PlanningInsightContext context,
  ) {
    final now = context.now;
    final routineById = {
      for (final routine in context.routines) routine.id: routine,
    };
    final unscheduled = context.occurrences.where((occurrence) {
      final routine = routineById[occurrence.routineId];
      return routine != null &&
          routine.isFlexible &&
          occurrence.needsAttention &&
          occurrence.effectiveStatusAt(now) == RoutineOccurrenceStatus.pending;
    }).toList();
    if (unscheduled.length < flexibleUnscheduledWarning) {
      return const [];
    }
    return [
      PlanningInsight(
        id: 'unscheduled-flexible:${_ymd(_dateOnly(now))}',
        type: InsightType.unscheduledWork,
        severity: InsightSeverity.suggestion,
        title: 'Flexible routines need placement',
        message:
            '${unscheduled.length} flexible routine blocks do not have a good slot yet. Open the planner before the week fills up.',
        reason:
            'Flexible routine occurrences were marked as needing scheduling attention.',
        createdAt: now,
        actions: const [
          InsightAction(
            id: 'open-planner',
            type: InsightActionType.openPlanner,
            label: 'Open Planner',
            requiresConfirmation: false,
          ),
        ],
      ),
    ];
  }

  List<PlanningInsight> _buildRoutinePatternInsights(
    PlanningInsightContext context,
  ) {
    final now = context.now;
    final historyStart = _dateOnly(now).subtract(const Duration(days: 30));
    final insights = <PlanningInsight>[];
    for (final routine in context.routines.where(
      (routine) => routine.generatesOccurrences,
    )) {
      final history = context.occurrences.where((occurrence) {
        return occurrence.routineId == routine.id &&
            !occurrence.occurrenceDate.isBefore(historyStart) &&
            !occurrence.occurrenceDate.isAfter(now);
      }).toList();
      final completed = history.where((occurrence) {
        return occurrence.effectiveStatusAt(now) ==
            RoutineOccurrenceStatus.completed;
      }).length;
      final missed = history.where((occurrence) {
        return occurrence.effectiveStatusAt(now) ==
            RoutineOccurrenceStatus.missed;
      }).length;
      final skipped = history.where((occurrence) {
        return occurrence.effectiveStatusAt(now) ==
            RoutineOccurrenceStatus.skipped;
      }).length;
      final closed = completed + missed + skipped;
      if (closed < 3) {
        continue;
      }
      final completionRate = completed / closed;
      if (missed + skipped >= 3 && completionRate < 0.6) {
        final reduceTo = ((routine.preferredDurationMinutes ?? 30) * 0.75)
            .round()
            .clamp(10, 180);
        insights.add(
          PlanningInsight(
            id: 'missed-routine:${routine.id}:${_ym(now)}',
            type: InsightType.missedRoutine,
            severity: InsightSeverity.suggestion,
            title: '${routine.title} is slipping',
            message:
                '${routine.title} was missed or skipped ${missed + skipped} times in the last 30 days. Try a smaller block or a better time.',
            reason:
                'The routine has repeated misses/skips and a completion rate below 60 percent.',
            createdAt: now,
            relatedRoutineId: routine.id,
            evidence: [
              'Completed: $completed',
              'Missed: $missed',
              'Skipped: $skipped',
            ],
            actions: [
              InsightAction(
                id: 'reduce-duration',
                type: InsightActionType.reduceRoutineDuration,
                label: 'Reduce Duration',
                routineId: routine.id,
                suggestedDurationMinutes: reduceTo,
                explanation:
                    'This opens the routine editor with a suggested smaller duration. Nothing changes until you save.',
              ),
              InsightAction(
                id: 'edit-routine',
                type: InsightActionType.editRoutine,
                label: 'Edit Routine',
                routineId: routine.id,
              ),
            ],
          ),
        );
      }

      final preferredStart = routine.preferredStartMinuteOfDay;
      if (preferredStart != null && missed >= 2 && completionRate < 0.5) {
        final suggested = _suggestEarlierMinute(preferredStart);
        insights.add(
          PlanningInsight(
            id: 'routine-timing:${routine.id}:${_ym(now)}',
            type: InsightType.routineTiming,
            severity: InsightSeverity.suggestion,
            title: 'Try ${routine.title} earlier',
            message:
                '${routine.title} performs poorly around ${_formatClock(preferredStart)}. Try ${_formatClock(suggested)} next week.',
            reason:
                'Recent misses cluster around the preferred routine time, so the deterministic suggestion shifts it earlier.',
            createdAt: now,
            relatedRoutineId: routine.id,
            actions: [
              InsightAction(
                id: 'shift-routine-time',
                type: InsightActionType.shiftRoutineTime,
                label: 'Shift Time',
                routineId: routine.id,
                suggestedStartMinuteOfDay: suggested,
                explanation:
                    'This opens routine editing with a safer time suggestion. It is never applied automatically.',
              ),
            ],
          ),
        );
      }

      final currentWeekStart = _weekStart(now);
      final previousWeekStart = currentWeekStart.subtract(
        const Duration(days: 7),
      );
      final current = _completionRateForRange(
        history,
        currentWeekStart,
        currentWeekStart.add(const Duration(days: 6)),
        now,
      );
      final previous = _completionRateForRange(
        history,
        previousWeekStart,
        previousWeekStart.add(const Duration(days: 6)),
        now,
      );
      if (previous.closed >= 3 &&
          current.closed >= 2 &&
          previous.rate - current.rate >= 0.35) {
        insights.add(
          PlanningInsight(
            id: 'consistency-drop:${routine.id}:${_ymd(currentWeekStart)}',
            type: InsightType.consistencyDrop,
            severity: InsightSeverity.info,
            title: '${routine.title} consistency dropped',
            message:
                '${routine.title} fell from ${(previous.rate * 100).round()}% to ${(current.rate * 100).round()}% completion this week.',
            reason:
                'This week completion rate is at least 35 points below last week.',
            createdAt: now,
            relatedRoutineId: routine.id,
            actions: [
              InsightAction(
                id: 'edit-routine',
                type: InsightActionType.editRoutine,
                label: 'Review Routine',
                routineId: routine.id,
              ),
            ],
          ),
        );
      }

      if (closed >= 4 && completionRate >= 0.8) {
        insights.add(
          PlanningInsight(
            id: 'positive-pattern:${routine.id}:${_ym(now)}',
            type: InsightType.positivePattern,
            severity: InsightSeverity.info,
            title: '${routine.title} is working',
            message:
                '${routine.title} is at ${(completionRate * 100).round()}% completion over recent closed occurrences. Keep this pattern stable.',
            reason:
                'Completion rate is at least 80 percent with enough recent evidence.',
            createdAt: now,
            relatedRoutineId: routine.id,
            actions: const [],
          ),
        );
      }
    }
    return insights;
  }

  List<PlanningInsight> _buildGoalInsights(PlanningInsightContext context) {
    final now = context.now;
    final activeGoals = context.goals.where(
      (goal) => goal.status == GoalStatus.active,
    );
    final insights = <PlanningInsight>[];
    for (final goal in activeGoals) {
      final linkedRoutines = context.routines
          .where(
            (routine) =>
                routine.linkedGoalId == goal.id && routine.generatesOccurrences,
          )
          .toList();
      final linkedTasks = context.tasks
          .where((task) => task.goalId == goal.id && !task.isArchived)
          .toList();
      final targetDate = goal.targetDate;
      if (targetDate != null) {
        final daysLeft = _dateOnly(
          targetDate,
        ).difference(_dateOnly(now)).inDays;
        if (daysLeft >= 0 && daysLeft <= 14) {
          final linkedOccurrences = context.occurrences
              .where(
                (occurrence) => linkedRoutines.any(
                  (routine) => routine.id == occurrence.routineId,
                ),
              )
              .toList();
          final closed = linkedOccurrences.where((occurrence) {
            final status = occurrence.effectiveStatusAt(now);
            return status == RoutineOccurrenceStatus.completed ||
                status == RoutineOccurrenceStatus.missed ||
                status == RoutineOccurrenceStatus.skipped;
          }).length;
          final completed = linkedOccurrences
              .where(
                (occurrence) =>
                    occurrence.effectiveStatusAt(now) ==
                    RoutineOccurrenceStatus.completed,
              )
              .length;
          final completionRate = closed == 0 ? 0.0 : completed / closed;
          if (linkedRoutines.isEmpty || completionRate < 0.5) {
            insights.add(
              PlanningInsight(
                id: 'goal-risk:${goal.id}:${_ymd(_dateOnly(now))}',
                type: InsightType.goalRisk,
                severity: daysLeft <= 3
                    ? InsightSeverity.warning
                    : InsightSeverity.suggestion,
                title: '${goal.title} needs routine support',
                message:
                    '${goal.title} is due in $daysLeft day(s), but linked routines are ${linkedRoutines.isEmpty ? 'missing' : 'below 50% completion'}.',
                reason:
                    'Goal deadline is close and routine support is weak or absent.',
                createdAt: now,
                relatedGoalId: goal.id,
                actions: [
                  InsightAction(
                    id: 'link-to-goal',
                    type: InsightActionType.linkToGoal,
                    label: 'Link Routine',
                    goalId: goal.id,
                  ),
                  const InsightAction(
                    id: 'open-weekly-planner',
                    type: InsightActionType.openWeeklyPlanner,
                    label: 'Open Weekly Review',
                    requiresConfirmation: false,
                  ),
                ],
              ),
            );
          }
        }
      }
      if (linkedRoutines.isEmpty && linkedTasks.isNotEmpty) {
        insights.add(
          PlanningInsight(
            id: 'goal-no-routine:${goal.id}',
            type: InsightType.goalRisk,
            severity: InsightSeverity.info,
            title: '${goal.title} has no active routine',
            message:
                '${goal.title} has active task work but no recurring routine support. A small weekly block may reduce deadline pressure.',
            reason:
                'The goal has linked tasks but no active routine linked to it.',
            createdAt: now,
            relatedGoalId: goal.id,
            actions: [
              InsightAction(
                id: 'link-to-goal',
                type: InsightActionType.linkToGoal,
                label: 'Link Routine',
                goalId: goal.id,
              ),
            ],
          ),
        );
      }
    }

    final unlinkedWeeklyMinutes = context.routines
        .where(
          (routine) =>
              routine.generatesOccurrences && routine.linkedGoalId == null,
        )
        .fold<int>(0, (total, routine) {
          return total +
              ((routine.preferredDurationMinutes ?? 0) *
                  _weeklyOccurrences(routine));
        });
    if (unlinkedWeeklyMinutes >= 6 * 60) {
      insights.add(
        PlanningInsight(
          id: 'unlinked-routine-load:${_ym(context.now)}',
          type: InsightType.goalRisk,
          severity: InsightSeverity.info,
          title: 'Some routine load is not goal-linked',
          message:
              'About ${_formatMinutes(unlinkedWeeklyMinutes)} of weekly routine time is not linked to a goal. Link the meaningful routines or reduce low-value load.',
          reason:
              'Unlinked active routines consume a meaningful amount of weekly capacity.',
          createdAt: now,
          actions: const [
            InsightAction(
              id: 'open-planner',
              type: InsightActionType.openPlanner,
              label: 'Review Load',
              requiresConfirmation: false,
            ),
          ],
        ),
      );
    }
    return insights;
  }

  int _sortInsights(PlanningInsight left, PlanningInsight right) {
    final severity = _severityRank(
      right.severity,
    ).compareTo(_severityRank(left.severity));
    if (severity != 0) {
      return severity;
    }
    return left.title.compareTo(right.title);
  }
}

class _RoutineScore {
  _RoutineScore({required this.routineId});

  final String routineId;
  int completed = 0;
  int fragile = 0;
}

class _LoadBucket {
  _LoadBucket({required this.day});

  final DateTime day;
  int plannedMinutes = 0;
  int eveningMinutes = 0;
  int busyMinutes = 0;
  int recoveryBlocks = 0;
}

class _CompletionWindow {
  const _CompletionWindow({required this.rate, required this.closed});

  final double rate;
  final int closed;
}

_CompletionWindow _completionRateForRange(
  List<RoutineOccurrence> occurrences,
  DateTime start,
  DateTime end,
  DateTime now,
) {
  var completed = 0;
  var closed = 0;
  for (final occurrence in occurrences) {
    final day = _dateOnly(occurrence.occurrenceDate);
    if (day.isBefore(start) || day.isAfter(end)) {
      continue;
    }
    final status = occurrence.effectiveStatusAt(now);
    if (status == RoutineOccurrenceStatus.completed) {
      completed += 1;
      closed += 1;
    } else if (status == RoutineOccurrenceStatus.missed ||
        status == RoutineOccurrenceStatus.skipped) {
      closed += 1;
    }
  }
  return _CompletionWindow(
    rate: closed == 0 ? 0 : completed / closed,
    closed: closed,
  );
}

int _weeklyOccurrences(Routine routine) {
  switch (routine.repeatRule.type) {
    case RoutineRepeatType.daily:
      return 7;
    case RoutineRepeatType.weekdays:
      return 5;
    case RoutineRepeatType.selectedWeekdays:
      return routine.repeatRule.weekdays.length;
    case RoutineRepeatType.weekly:
      return 1;
    case RoutineRepeatType.monthly:
      return 1;
  }
}

int _suggestEarlierMinute(int minute) {
  if (minute >= 20 * 60) {
    return minute - 2 * 60;
  }
  if (minute >= 18 * 60) {
    return minute - 90;
  }
  if (minute >= 12 * 60) {
    return minute - 60;
  }
  return minute;
}

int _eveningOverlapMinutes(DateTime start, DateTime end) {
  final eveningStart = DateTime(start.year, start.month, start.day, 18);
  final overlapStart = start.isAfter(eveningStart) ? start : eveningStart;
  if (!end.isAfter(overlapStart)) {
    return 0;
  }
  return end.difference(overlapStart).inMinutes;
}

int _severityRank(InsightSeverity severity) {
  switch (severity) {
    case InsightSeverity.info:
      return 0;
    case InsightSeverity.suggestion:
      return 1;
    case InsightSeverity.warning:
      return 2;
    case InsightSeverity.critical:
      return 3;
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _weekStart(DateTime value) {
  final day = _dateOnly(value);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

String _ym(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}';

String _ymd(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}';

String _weekday(DateTime value) {
  switch (value.weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
  }
  return 'Day';
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) {
    return '${remainder}m';
  }
  if (remainder == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainder}m';
}

String _formatClock(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  final period = hour >= 12 ? 'PM' : 'AM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:${minute.toString().padLeft(2, '0')} $period';
}
