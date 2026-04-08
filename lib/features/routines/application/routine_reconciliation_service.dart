import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';
import '../domain/routine_generation_service.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineReconciliationPlan {
  const RoutineReconciliationPlan({
    this.occurrencesToUpsert = const [],
    this.occurrenceIdsToRemove = const [],
    this.shouldRunSchedulingIntegration = false,
  });

  final List<RoutineOccurrence> occurrencesToUpsert;
  final List<String> occurrenceIdsToRemove;
  final bool shouldRunSchedulingIntegration;

  bool get hasChanges =>
      occurrencesToUpsert.isNotEmpty || occurrenceIdsToRemove.isNotEmpty;
}

class RoutineReconciliationService {
  RoutineReconciliationService({RoutineGenerationService? generationService})
      : _generationService = generationService ?? RoutineGenerationService();

  final RoutineGenerationService _generationService;

  RoutineReconciliationPlan reconcile({
    required Routine previousRoutine,
    required Routine nextRoutine,
    required List<RoutineOccurrence> existingOccurrences,
    required DateTime now,
    int horizonDays = 30,
  }) {
    final startDate = normalizeDate(now);
    final endDate = startDate.add(Duration(days: horizonDays));
    final futurePending = existingOccurrences.where((occurrence) {
      return occurrence.status == RoutineOccurrenceStatus.pending &&
          !occurrence.occurrenceDate.isBefore(startDate);
    }).toList();

    if (!_affectsFutureOccurrences(previousRoutine, nextRoutine)) {
      return const RoutineReconciliationPlan();
    }

    if (!nextRoutine.generatesOccurrences) {
      return RoutineReconciliationPlan(
        occurrenceIdsToRemove: futurePending.map((item) => item.id).toList(),
      );
    }

    final expectedDates = _generationService.computeOccurrenceDates(
      nextRoutine,
      startDate: startDate,
      endDate: endDate,
    );
    final expectedDateKeys = expectedDates.map(_dateKey).toSet();
    final generatedByDateKey = {
      for (final occurrence
          in _generationService.buildOccurrences(nextRoutine, expectedDates))
        _dateKey(occurrence.occurrenceDate): occurrence,
    };
    final existingByDateKey = <String, RoutineOccurrence>{};
    final upserts = <RoutineOccurrence>[];
    final removals = <String>[];

    for (final occurrence in futurePending.where((item) => !item.isRecoveryInstance)) {
      final key = _dateKey(occurrence.occurrenceDate);
      existingByDateKey.putIfAbsent(key, () => occurrence);

      if (!expectedDateKeys.contains(key)) {
        if (occurrence.isManualOverride) {
          upserts.add(
            occurrence.copyWith(
              schedulingNote: 'Manual time preserved after routine edit',
              updatedAt: now,
            ),
          );
        } else {
          removals.add(occurrence.id);
        }
      }
    }

    for (final date in expectedDates) {
      final key = _dateKey(date);
      final existing = existingByDateKey[key];
      if (existing == null) {
        final generated = generatedByDateKey[key];
        if (generated != null) {
          upserts.add(generated.copyWith(updatedAt: now));
        }
        continue;
      }

      if (!_requiresScheduleRefresh(previousRoutine, nextRoutine) ||
          existing.isManualOverride) {
        continue;
      }

      upserts.add(
        _refreshPendingOccurrence(
          occurrence: existing,
          routine: nextRoutine,
          now: now,
        ),
      );
    }

    for (final occurrence in futurePending.where((item) => item.isRecoveryInstance)) {
      if (_requiresScheduleRefresh(previousRoutine, nextRoutine) &&
          !occurrence.isManualOverride) {
        upserts.add(
          _refreshPendingOccurrence(
            occurrence: occurrence,
            routine: nextRoutine,
            now: now,
            preserveRecoveryNote: true,
          ),
        );
      }
    }

    return RoutineReconciliationPlan(
      occurrencesToUpsert: _dedupeOccurrences(upserts),
      occurrenceIdsToRemove: removals.toSet().toList(),
      shouldRunSchedulingIntegration:
          _requiresScheduleRefresh(previousRoutine, nextRoutine),
    );
  }

  RoutineOccurrence refreshOccurrenceSchedule({
    required RoutineOccurrence occurrence,
    required Routine routine,
    required DateTime now,
  }) {
    return _refreshPendingOccurrence(
      occurrence: occurrence,
      routine: routine,
      now: now,
    );
  }

  bool _affectsFutureOccurrences(Routine previous, Routine next) {
    return previous.isArchived != next.isArchived ||
        previous.isActive != next.isActive ||
        previous.repeatRule != next.repeatRule ||
        previous.anchorDate != next.anchorDate ||
        _requiresScheduleRefresh(previous, next);
  }

  bool _requiresScheduleRefresh(Routine previous, Routine next) {
    return previous.preferredStartMinuteOfDay != next.preferredStartMinuteOfDay ||
        previous.preferredDurationMinutes != next.preferredDurationMinutes ||
        previous.timeWindowStartMinuteOfDay != next.timeWindowStartMinuteOfDay ||
        previous.timeWindowEndMinuteOfDay != next.timeWindowEndMinuteOfDay ||
        previous.isFlexible != next.isFlexible;
  }

  RoutineOccurrence _refreshPendingOccurrence({
    required RoutineOccurrence occurrence,
    required Routine routine,
    required DateTime now,
    bool preserveRecoveryNote = false,
  }) {
    if (!routine.isFlexible) {
      final startMinute = routine.preferredStartMinuteOfDay;
      final durationMinutes = routine.preferredDurationMinutes ?? 60;
      if (startMinute == null) {
        return occurrence.copyWith(
          clearScheduledStart: true,
          clearScheduledEnd: true,
          needsAttention: true,
          isAutoScheduled: false,
          schedulingNote: 'Fixed routine needs a preferred time after edit',
          updatedAt: now,
        );
      }
      final start = composeDateAndMinute(occurrence.occurrenceDate, startMinute);
      return occurrence.copyWith(
        scheduledStart: start,
        scheduledEnd: start.add(Duration(minutes: durationMinutes)),
        needsAttention: false,
        isAutoScheduled: false,
        schedulingNote: preserveRecoveryNote
            ? 'Recovery placement refreshed'
            : 'Routine timing updated',
        updatedAt: now,
      );
    }

    return occurrence.copyWith(
      clearScheduledStart: true,
      clearScheduledEnd: true,
      needsAttention: true,
      isAutoScheduled: false,
      schedulingNote: occurrence.isManualOverride
          ? 'Manual time preserved'
          : 'Routine timing changed. Replan to place this block.',
      updatedAt: now,
    );
  }

  List<RoutineOccurrence> _dedupeOccurrences(List<RoutineOccurrence> occurrences) {
    final byId = <String, RoutineOccurrence>{};
    for (final occurrence in occurrences) {
      byId[occurrence.id] = occurrence;
    }
    return byId.values.toList();
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
