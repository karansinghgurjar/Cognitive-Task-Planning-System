import 'package:uuid/uuid.dart';

import '../../goals/domain/dependency_resolution_service.dart';
import '../../goals/models/task_dependency.dart';
import '../../tasks/models/task.dart';
import '../../timetable/domain/availability_service.dart';
import '../models/planned_session.dart';
import 'scheduling_models.dart';
import 'task_progress_service.dart';

class ScheduleGeneratorService {
  ScheduleGeneratorService({
    this.targetSessionLengthMinutes = 60,
    this.minimumSessionLengthMinutes = 25,
    TaskProgressService taskProgressService = const TaskProgressService(),
    DependencyResolutionService dependencyResolutionService =
        const DependencyResolutionService(),
    String Function()? idGenerator,
  }) : _taskProgressService = taskProgressService,
       _dependencyResolutionService = dependencyResolutionService,
       _idGenerator = idGenerator ?? const Uuid().v4;

  final int targetSessionLengthMinutes;
  final int minimumSessionLengthMinutes;
  final TaskProgressService _taskProgressService;
  final DependencyResolutionService _dependencyResolutionService;
  final String Function() _idGenerator;

  SchedulingResult generateNext7DaysSchedule({
    required List<Task> tasks,
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required List<PlannedSession> existingSessions,
    required DateTime now,
    List<TaskDependency> dependencies = const [],
  }) {
    final normalizedNow = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final horizonStart = DateTime(now.year, now.month, now.day);
    final horizonEnd = horizonStart.add(const Duration(days: 7));

    final incompleteTasks = tasks
        .where(
          (task) =>
              !task.isArchived &&
              !task.isCompleted &&
              !_taskProgressService.isTaskSatisfied(task, existingSessions),
        )
        .toList();

    final dependencyResolution = _dependencyResolutionService
        .resolveSchedulableTasks(
          tasks: incompleteTasks,
          dependencies: dependencies,
          sessions: existingSessions,
        );
    final schedulableTasks = dependencyResolution.schedulableTasks
      ..sort((left, right) => _compareTasks(left, right, normalizedNow));

    final concreteWindows = _buildConcreteAvailabilityWindows(
      weeklyAvailability: weeklyAvailability,
      horizonStart: horizonStart,
      now: normalizedNow,
    );

    final blockedSessions =
        existingSessions
            .where(
              (session) =>
                  session.blocksScheduling &&
                  session.start.isBefore(horizonEnd) &&
                  session.end.isAfter(normalizedNow),
            )
            .toList()
          ..sort((left, right) => left.start.compareTo(right.start));

    final availableRanges = _subtractBlockedSessions(
      concreteWindows,
      blockedSessions,
    );
    final mutableRanges = availableRanges
        .where((range) => range.durationMinutes >= minimumSessionLengthMinutes)
        .map((range) => _MutableDateTimeRange(range.start, range.end))
        .toList();

    final generatedSessions = <PlannedSession>[];
    final failures = dependencyResolution.blockedTaskIds.map((taskId) {
      final task = incompleteTasks.firstWhere((item) => item.id == taskId);
      return SchedulingFailure(
        taskId: task.id,
        taskTitle: task.title,
        scheduledMinutes: 0,
        unscheduledMinutes: _taskProgressService.getRemainingMinutesForTask(
          task,
          existingSessions,
        ),
        reason: dependencyResolution.cycleTaskIds.contains(taskId)
            ? SchedulingFailureReason.dependencyCycle
            : SchedulingFailureReason.dependencyBlocked,
        blockedByTaskIds:
            dependencyResolution.blockedByTaskIds[taskId] ?? const [],
      );
    }).toList();

    for (final task in schedulableTasks) {
      var remainingMinutes = _taskProgressService.getRemainingMinutesForTask(
        task,
        existingSessions,
      );
      var scheduledMinutes = 0;

      for (final range in mutableRanges) {
        while (remainingMinutes > 0) {
          final availableMinutes = range.remainingMinutes;
          if (availableMinutes < minimumSessionLengthMinutes) {
            break;
          }

          if (remainingMinutes < minimumSessionLengthMinutes) {
            final isShortTask =
                scheduledMinutes == 0 &&
                remainingMinutes == task.estimatedDurationMinutes;
            if (isShortTask && availableMinutes >= remainingMinutes) {
              final start = range.start;
              final end = start.add(Duration(minutes: remainingMinutes));

              generatedSessions.add(
                PlannedSession(
                  id: _idGenerator(),
                  taskId: task.id,
                  start: start,
                  end: end,
                  status: PlannedSessionStatus.pending,
                  completed: false,
                  actualMinutesFocused: 0,
                ),
              );

              range.start = end;
              scheduledMinutes += remainingMinutes;
              remainingMinutes = 0;
              continue;
            }

            if (_canAttachRemainder(
              generatedSessions: generatedSessions,
              taskId: task.id,
              range: range,
              remainderMinutes: remainingMinutes,
            )) {
              final lastSession = generatedSessions.last;
              lastSession.end = lastSession.end.add(
                Duration(minutes: remainingMinutes),
              );
              range.start = range.start.add(
                Duration(minutes: remainingMinutes),
              );
              scheduledMinutes += remainingMinutes;
              remainingMinutes = 0;
            }
            break;
          }

          final chunkMinutes = _selectChunkMinutes(
            remainingMinutes: remainingMinutes,
            availableMinutes: availableMinutes,
          );
          if (chunkMinutes < minimumSessionLengthMinutes) {
            break;
          }

          final start = range.start;
          final end = start.add(Duration(minutes: chunkMinutes));

          generatedSessions.add(
            PlannedSession(
              id: _idGenerator(),
              taskId: task.id,
              start: start,
              end: end,
              status: PlannedSessionStatus.pending,
              completed: false,
              actualMinutesFocused: 0,
            ),
          );

          range.start = end;
          scheduledMinutes += chunkMinutes;
          remainingMinutes -= chunkMinutes;
        }

        if (remainingMinutes == 0) {
          break;
        }
      }

      if (remainingMinutes > 0) {
        failures.add(
          SchedulingFailure(
            taskId: task.id,
            taskTitle: task.title,
            scheduledMinutes: scheduledMinutes,
            unscheduledMinutes: remainingMinutes,
          ),
        );
      }
    }

    return SchedulingResult(
      generatedSessions: generatedSessions,
      failures: failures,
      horizonStart: horizonStart,
      horizonEnd: horizonEnd,
    );
  }

  List<_DateTimeRange> _buildConcreteAvailabilityWindows({
    required Map<int, List<AvailabilityWindow>> weeklyAvailability,
    required DateTime horizonStart,
    required DateTime now,
  }) {
    final ranges = <_DateTimeRange>[];

    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final currentDate = horizonStart.add(Duration(days: dayOffset));
      final windows = weeklyAvailability[currentDate.weekday] ?? const [];

      for (final window in windows) {
        final rawStart = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          window.startHour,
          window.startMinute,
        );
        final rawEnd = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          window.endHour,
          window.endMinute,
        );

        final start = rawStart.isBefore(now) ? now : rawStart;
        if (!start.isBefore(rawEnd)) {
          continue;
        }

        ranges.add(_DateTimeRange(start, rawEnd));
      }
    }

    ranges.sort((left, right) => left.start.compareTo(right.start));
    return ranges;
  }

  List<_DateTimeRange> _subtractBlockedSessions(
    List<_DateTimeRange> windows,
    List<PlannedSession> blockedSessions,
  ) {
    final availableRanges = <_DateTimeRange>[];

    for (final window in windows) {
      var segments = <_DateTimeRange>[window];

      for (final blocked in blockedSessions) {
        if (!blocked.start.isBefore(window.end) ||
            !blocked.end.isAfter(window.start)) {
          continue;
        }

        final nextSegments = <_DateTimeRange>[];
        for (final segment in segments) {
          nextSegments.addAll(
            _subtractRange(segment, _DateTimeRange(blocked.start, blocked.end)),
          );
        }
        segments = nextSegments;
        if (segments.isEmpty) {
          break;
        }
      }

      availableRanges.addAll(segments);
    }

    availableRanges.sort((left, right) => left.start.compareTo(right.start));
    return availableRanges;
  }

  List<_DateTimeRange> _subtractRange(
    _DateTimeRange source,
    _DateTimeRange blocker,
  ) {
    final overlapStart = blocker.start.isAfter(source.start)
        ? blocker.start
        : source.start;
    final overlapEnd = blocker.end.isBefore(source.end)
        ? blocker.end
        : source.end;

    if (!overlapStart.isBefore(overlapEnd)) {
      return [source];
    }

    final segments = <_DateTimeRange>[];
    if (source.start.isBefore(overlapStart)) {
      segments.add(_DateTimeRange(source.start, overlapStart));
    }
    if (overlapEnd.isBefore(source.end)) {
      segments.add(_DateTimeRange(overlapEnd, source.end));
    }
    return segments;
  }

  int _selectChunkMinutes({
    required int remainingMinutes,
    required int availableMinutes,
  }) {
    if (remainingMinutes <= availableMinutes) {
      if (remainingMinutes <= targetSessionLengthMinutes) {
        return remainingMinutes;
      }

      final leftover = remainingMinutes - targetSessionLengthMinutes;
      if (leftover > 0 && leftover < minimumSessionLengthMinutes) {
        return remainingMinutes;
      }

      return targetSessionLengthMinutes;
    }

    if (availableMinutes <= targetSessionLengthMinutes) {
      return availableMinutes;
    }

    return targetSessionLengthMinutes;
  }

  bool _canAttachRemainder({
    required List<PlannedSession> generatedSessions,
    required String taskId,
    required _MutableDateTimeRange range,
    required int remainderMinutes,
  }) {
    if (generatedSessions.isEmpty || remainderMinutes <= 0) {
      return false;
    }

    final lastSession = generatedSessions.last;
    return lastSession.taskId == taskId &&
        lastSession.end.isAtSameMomentAs(range.start) &&
        remainderMinutes <= range.remainingMinutes;
  }

  int _compareTasks(Task left, Task right, DateTime now) {
    final leftOverdue = left.dueDate != null && left.dueDate!.isBefore(now);
    final rightOverdue = right.dueDate != null && right.dueDate!.isBefore(now);
    if (leftOverdue != rightOverdue) {
      return leftOverdue ? -1 : 1;
    }

    final priorityCompare = left.priority.compareTo(right.priority);
    if (priorityCompare != 0) {
      return priorityCompare;
    }

    final leftDueDate = left.dueDate;
    final rightDueDate = right.dueDate;
    if (leftDueDate == null && rightDueDate != null) {
      return 1;
    }
    if (leftDueDate != null && rightDueDate == null) {
      return -1;
    }
    if (leftDueDate != null && rightDueDate != null) {
      final dueDateCompare = leftDueDate.compareTo(rightDueDate);
      if (dueDateCompare != 0) {
        return dueDateCompare;
      }
    }

    return left.createdAt.compareTo(right.createdAt);
  }
}

class _DateTimeRange {
  const _DateTimeRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get durationMinutes => end.difference(start).inMinutes;
}

class _MutableDateTimeRange {
  _MutableDateTimeRange(this.start, this.end);

  DateTime start;
  final DateTime end;

  int get remainingMinutes => end.difference(start).inMinutes;
}

