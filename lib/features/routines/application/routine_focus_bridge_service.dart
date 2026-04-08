import 'package:uuid/uuid.dart';

import '../../schedule/models/planned_session.dart';
import '../../tasks/models/task.dart';
import '../domain/routine_enums.dart';
import '../models/routine.dart';
import '../models/routine_occurrence.dart';

class RoutineFocusBridgeResult {
  const RoutineFocusBridgeResult({
    required this.task,
    required this.session,
  });

  final Task task;
  final PlannedSession session;
}

class RoutineFocusBridgeService {
  RoutineFocusBridgeService({String Function()? idGenerator})
    : _idGenerator = idGenerator ?? const Uuid().v4;

  final String Function() _idGenerator;

  RoutineFocusBridgeResult createFocusArtifacts({
    required Routine routine,
    required RoutineOccurrence occurrence,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    final taskId = _idGenerator();
    final start = occurrence.scheduledStart ??
        DateTime(
          occurrence.occurrenceDate.year,
          occurrence.occurrenceDate.month,
          occurrence.occurrenceDate.day,
          18,
        );
    final durationMinutes =
        occurrence.durationMinutes ?? routine.preferredDurationMinutes ?? 30;
    final end = occurrence.scheduledEnd ?? start.add(Duration(minutes: durationMinutes));
    final task = Task(
      id: taskId,
      title: routine.title,
      description: routine.description,
      type: _taskTypeForRoutine(routine),
      estimatedDurationMinutes: durationMinutes,
      dueDate: end,
      priority: routine.priority,
      goalId: routine.linkedGoalId,
      resourceTag: routine.linkedProjectId ?? routine.categoryId,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final session = PlannedSession(
      id: _idGenerator(),
      taskId: task.id,
      start: start,
      end: end,
    );
    return RoutineFocusBridgeResult(task: task, session: session);
  }

  TaskType _taskTypeForRoutine(Routine routine) {
    switch (routine.routineType) {
      case RoutineType.study:
        return TaskType.study;
      case RoutineType.project:
        return TaskType.project;
      case RoutineType.review:
        return TaskType.reading;
      case RoutineType.health:
      case RoutineType.custom:
        return TaskType.misc;
    }
  }
}
