import 'package:isar/isar.dart';

part 'routine_occurrence.g.dart';

enum RoutineOccurrenceStatus { pending, completed, missed, cancelled }

@collection
class RoutineOccurrence {
  RoutineOccurrence({
    required this.id,
    required this.routineId,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.status = RoutineOccurrenceStatus.pending,
    this.linkedPlannedSessionId,
    required this.createdAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String routineId;

  late DateTime scheduledStart;
  late DateTime scheduledEnd;

  @Enumerated(EnumType.name)
  late RoutineOccurrenceStatus status;

  String? linkedPlannedSessionId;
  late DateTime createdAt;

  RoutineOccurrence copyWith({
    String? id,
    String? routineId,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    RoutineOccurrenceStatus? status,
    String? linkedPlannedSessionId,
    bool clearLinkedPlannedSessionId = false,
    DateTime? createdAt,
  }) {
    final occurrence = RoutineOccurrence(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      linkedPlannedSessionId: clearLinkedPlannedSessionId
          ? null
          : linkedPlannedSessionId ?? this.linkedPlannedSessionId,
      createdAt: createdAt ?? this.createdAt,
    )..isarId = isarId;

    return occurrence;
  }

  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  bool get isCompleted => status == RoutineOccurrenceStatus.completed;
}

extension RoutineOccurrenceStatusX on RoutineOccurrenceStatus {
  String get label {
    switch (this) {
      case RoutineOccurrenceStatus.pending:
        return 'Pending';
      case RoutineOccurrenceStatus.completed:
        return 'Completed';
      case RoutineOccurrenceStatus.missed:
        return 'Missed';
      case RoutineOccurrenceStatus.cancelled:
        return 'Cancelled';
    }
  }
}

extension EffectiveRoutineOccurrenceStatusX on RoutineOccurrence {
  RoutineOccurrenceStatus effectiveStatusAt(DateTime now) {
    if (status == RoutineOccurrenceStatus.pending &&
        scheduledEnd.isBefore(now)) {
      return RoutineOccurrenceStatus.missed;
    }
    return status;
  }
}
