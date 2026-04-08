import 'package:isar/isar.dart';

import '../domain/routine_date_utils.dart';
import '../domain/routine_enums.dart';

part 'routine_occurrence.g.dart';

@collection
class RoutineOccurrence {
  RoutineOccurrence({
    required this.id,
    required this.routineId,
    required DateTime occurrenceDate,
    this.scheduledStart,
    this.scheduledEnd,
    this.status = RoutineOccurrenceStatus.pending,
    required this.createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.skippedAt,
    this.missedAt,
    this.sourceTaskId,
    this.notes,
    this.isRecoveryInstance = false,
    this.recoveredFromOccurrenceId,
    this.needsAttention = false,
    this.isAutoScheduled = false,
    this.schedulingNote,
    this.isManualOverride = false,
    this.recoveryDismissedAt,
  }) : occurrenceDate = normalizeDate(occurrenceDate),
       updatedAt = updatedAt ?? createdAt,
       occurrenceKey = buildOccurrenceKey(routineId, occurrenceDate) {
    _validate();
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String routineId;

  @Index(unique: true, replace: true)
  late String occurrenceKey;

  @Index()
  late DateTime occurrenceDate;

  DateTime? scheduledStart;
  DateTime? scheduledEnd;

  @Enumerated(EnumType.name)
  late RoutineOccurrenceStatus status;

  late DateTime createdAt;
  DateTime? updatedAt;
  DateTime? completedAt;
  DateTime? skippedAt;
  DateTime? missedAt;
  String? sourceTaskId;
  String? notes;
  late bool isRecoveryInstance;
  String? recoveredFromOccurrenceId;
  late bool needsAttention;
  late bool isAutoScheduled;
  String? schedulingNote;
  late bool isManualOverride;
  DateTime? recoveryDismissedAt;

  RoutineOccurrence copyWith({
    String? id,
    String? routineId,
    DateTime? occurrenceDate,
    DateTime? scheduledStart,
    bool clearScheduledStart = false,
    DateTime? scheduledEnd,
    bool clearScheduledEnd = false,
    RoutineOccurrenceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? skippedAt,
    bool clearSkippedAt = false,
    DateTime? missedAt,
    bool clearMissedAt = false,
    String? sourceTaskId,
    bool clearSourceTaskId = false,
    String? notes,
    bool clearNotes = false,
    bool? isRecoveryInstance,
    String? recoveredFromOccurrenceId,
    bool clearRecoveredFromOccurrenceId = false,
    bool? needsAttention,
    bool? isAutoScheduled,
    String? schedulingNote,
    bool clearSchedulingNote = false,
    bool? isManualOverride,
    DateTime? recoveryDismissedAt,
    bool clearRecoveryDismissedAt = false,
  }) {
    final occurrence = RoutineOccurrence(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      scheduledStart: clearScheduledStart ? null : scheduledStart ?? this.scheduledStart,
      scheduledEnd: clearScheduledEnd ? null : scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      skippedAt: clearSkippedAt ? null : skippedAt ?? this.skippedAt,
      missedAt: clearMissedAt ? null : missedAt ?? this.missedAt,
      sourceTaskId: clearSourceTaskId ? null : sourceTaskId ?? this.sourceTaskId,
      notes: clearNotes ? null : notes ?? this.notes,
      isRecoveryInstance: isRecoveryInstance ?? this.isRecoveryInstance,
      recoveredFromOccurrenceId: clearRecoveredFromOccurrenceId
          ? null
          : recoveredFromOccurrenceId ?? this.recoveredFromOccurrenceId,
      needsAttention: needsAttention ?? this.needsAttention,
      isAutoScheduled: isAutoScheduled ?? this.isAutoScheduled,
      schedulingNote: clearSchedulingNote
          ? null
          : schedulingNote ?? this.schedulingNote,
      isManualOverride: isManualOverride ?? this.isManualOverride,
      recoveryDismissedAt: clearRecoveryDismissedAt
          ? null
          : recoveryDismissedAt ?? this.recoveryDismissedAt,
    )..isarId = isarId;
    return occurrence;
  }

  @ignore
  int? get durationMinutes {
    final start = scheduledStart;
    final end = scheduledEnd;
    if (start == null || end == null) {
      return null;
    }
    return end.difference(start).inMinutes;
  }

  @ignore
  bool get isCompleted => status == RoutineOccurrenceStatus.completed;

  @ignore
  String? get linkedTaskId => sourceTaskId;

  @ignore
  DateTime get scheduledDate => occurrenceDate;

  @ignore
  RoutineOccurrenceStatus get effectiveStatus => status;

  bool isMissedAt(DateTime now) {
    return status == RoutineOccurrenceStatus.pending &&
        ((scheduledEnd ?? composeDateAndMinute(occurrenceDate, 23 * 60 + 59))
            .isBefore(now));
  }

  void _validate() {
    final start = scheduledStart;
    final end = scheduledEnd;
    if (start != null && end != null && !start.isBefore(end)) {
      throw ArgumentError(
        'Scheduled end must be after scheduled start for an occurrence.',
      );
    }
  }
}

extension EffectiveRoutineOccurrenceStatusX on RoutineOccurrence {
  RoutineOccurrenceStatus effectiveStatusAt(DateTime now) {
    if (status == RoutineOccurrenceStatus.pending && isMissedAt(now)) {
      return RoutineOccurrenceStatus.missed;
    }
    return status;
  }
}
