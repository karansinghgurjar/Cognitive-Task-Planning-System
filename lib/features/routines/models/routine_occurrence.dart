import 'package:isar/isar.dart';

part 'routine_occurrence.g.dart';

enum RoutineOccurrenceStatus {
  pending,
  completed,
  skipped,
  missed,
  cancelled,
}

@collection
class RoutineOccurrence {
  RoutineOccurrence({
    required this.id,
    required this.routineId,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.status = RoutineOccurrenceStatus.pending,
    this.generatedFromRule = true,
    this.linkedPlannedSessionId,
    this.linkedTaskId,
    this.completedAt,
    this.notes,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String routineId;

  late DateTime scheduledStart;
  late DateTime scheduledEnd;

  @Enumerated(EnumType.name)
  late RoutineOccurrenceStatus status;

  late bool generatedFromRule;
  String? linkedPlannedSessionId;
  String? linkedTaskId;
  DateTime? completedAt;
  String? notes;
  late DateTime createdAt;
  DateTime? updatedAt;

  RoutineOccurrence copyWith({
    String? id,
    String? routineId,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    RoutineOccurrenceStatus? status,
    bool? generatedFromRule,
    String? linkedPlannedSessionId,
    bool clearLinkedPlannedSessionId = false,
    String? linkedTaskId,
    bool clearLinkedTaskId = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final occurrence = RoutineOccurrence(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      generatedFromRule: generatedFromRule ?? this.generatedFromRule,
      linkedPlannedSessionId: clearLinkedPlannedSessionId
          ? null
          : linkedPlannedSessionId ?? this.linkedPlannedSessionId,
      linkedTaskId: clearLinkedTaskId ? null : linkedTaskId ?? this.linkedTaskId,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )..isarId = isarId;

    return occurrence;
  }

  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  bool get isCompleted => effectiveStatus == RoutineOccurrenceStatus.completed;

  @ignore
  DateTime get scheduledDate => DateTime(
    scheduledStart.year,
    scheduledStart.month,
    scheduledStart.day,
  );

  @ignore
  RoutineOccurrenceStatus get effectiveStatus {
    if (status == RoutineOccurrenceStatus.cancelled) {
      return RoutineOccurrenceStatus.skipped;
    }
    return status;
  }

  bool isMissedAt(DateTime now) {
    return effectiveStatus == RoutineOccurrenceStatus.pending &&
        scheduledEnd.isBefore(now);
  }
}

extension RoutineOccurrenceStatusX on RoutineOccurrenceStatus {
  String get label {
    switch (this) {
      case RoutineOccurrenceStatus.pending:
        return 'Pending';
      case RoutineOccurrenceStatus.completed:
        return 'Completed';
      case RoutineOccurrenceStatus.skipped:
        return 'Skipped';
      case RoutineOccurrenceStatus.missed:
        return 'Missed';
      case RoutineOccurrenceStatus.cancelled:
        return 'Skipped';
    }
  }
}

extension EffectiveRoutineOccurrenceStatusX on RoutineOccurrence {
  RoutineOccurrenceStatus effectiveStatusAt(DateTime now) {
    if (isMissedAt(now)) {
      return RoutineOccurrenceStatus.missed;
    }
    return effectiveStatus;
  }
}
