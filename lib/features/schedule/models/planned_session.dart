import 'package:isar/isar.dart';

part 'planned_session.g.dart';

enum PlannedSessionStatus { pending, inProgress, completed, missed, cancelled }

@collection
class PlannedSession {
  PlannedSession({
    required this.id,
    required this.taskId,
    required this.start,
    required this.end,
    this.status = PlannedSessionStatus.pending,
    this.completed = false,
    this.actualMinutesFocused = 0,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String taskId;
  late DateTime start;
  late DateTime end;

  @Enumerated(EnumType.name)
  late PlannedSessionStatus status;

  late bool completed;
  late int actualMinutesFocused;

  PlannedSession copyWith({
    String? id,
    String? taskId,
    DateTime? start,
    DateTime? end,
    PlannedSessionStatus? status,
    bool? completed,
    int? actualMinutesFocused,
  }) {
    final session = PlannedSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      actualMinutesFocused: actualMinutesFocused ?? this.actualMinutesFocused,
    )..isarId = isarId;

    return session;
  }

  int get plannedDurationMinutes => end.difference(start).inMinutes;

  bool get isPending => status == PlannedSessionStatus.pending;

  bool get isInProgress => status == PlannedSessionStatus.inProgress;

  bool get isCompleted => status == PlannedSessionStatus.completed || completed;

  bool get isMissed => status == PlannedSessionStatus.missed;

  bool get isCancelled => status == PlannedSessionStatus.cancelled;

  bool get blocksScheduling =>
      isCompleted || isInProgress || status == PlannedSessionStatus.pending;
}
