import 'dart:convert';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';
import '../domain/sync_models.dart';

class SyncEntityCodec {
  const SyncEntityCodec();

  Map<String, dynamic> encodeEntity(SyncEntityType entityType, Object entity) {
    switch (entityType) {
      case SyncEntityType.task:
        return _taskToJson(entity as Task);
      case SyncEntityType.timetableSlot:
        return _slotToJson(entity as TimetableSlot);
      case SyncEntityType.plannedSession:
        return _sessionToJson(entity as PlannedSession);
      case SyncEntityType.learningGoal:
        return _goalToJson(entity as LearningGoal);
      case SyncEntityType.goalMilestone:
        return _milestoneToJson(entity as GoalMilestone);
      case SyncEntityType.taskDependency:
        return _dependencyToJson(entity as TaskDependency);
      case SyncEntityType.notificationPreferences:
        return _preferencesToJson(entity as NotificationPreferences);
    }
  }

  String entityIdOf(SyncEntityType entityType, Object entity) {
    switch (entityType) {
      case SyncEntityType.task:
        return (entity as Task).id;
      case SyncEntityType.timetableSlot:
        return (entity as TimetableSlot).id;
      case SyncEntityType.plannedSession:
        return (entity as PlannedSession).id;
      case SyncEntityType.learningGoal:
        return (entity as LearningGoal).id;
      case SyncEntityType.goalMilestone:
        return (entity as GoalMilestone).id;
      case SyncEntityType.taskDependency:
        return (entity as TaskDependency).id;
      case SyncEntityType.notificationPreferences:
        return 'preferences';
    }
  }

  Object decodeEntity(SyncEntityType entityType, Map<String, dynamic> json) {
    switch (entityType) {
      case SyncEntityType.task:
        return _taskFromJson(json);
      case SyncEntityType.timetableSlot:
        return _slotFromJson(json);
      case SyncEntityType.plannedSession:
        return _sessionFromJson(json);
      case SyncEntityType.learningGoal:
        return _goalFromJson(json);
      case SyncEntityType.goalMilestone:
        return _milestoneFromJson(json);
      case SyncEntityType.taskDependency:
        return _dependencyFromJson(json);
      case SyncEntityType.notificationPreferences:
        return _preferencesFromJson(json);
    }
  }

  Map<String, dynamic>? decodePayloadJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  Map<String, dynamic> _taskToJson(Task task) => {
    'id': task.id,
    'title': task.title,
    'description': task.description,
    'type': task.type.name,
    'estimatedDurationMinutes': task.estimatedDurationMinutes,
    'dueDate': task.dueDate?.toIso8601String(),
    'priority': task.priority,
    'resourceUrl': task.resourceUrl,
    'resourceTag': task.resourceTag,
    'goalId': task.goalId,
    'milestoneId': task.milestoneId,
    'isCompleted': task.isCompleted,
    'isArchived': task.isArchived,
    'createdAt': task.createdAt.toIso8601String(),
    'updatedAt': task.updatedAt?.toIso8601String(),
    'completedAt': task.completedAt?.toIso8601String(),
    'archivedAt': task.archivedAt?.toIso8601String(),
  };

  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: TaskType.values.byName(json['type'] as String),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      dueDate: _dateTimeOrNull(json['dueDate']),
      priority: json['priority'] as int,
      resourceUrl: json['resourceUrl'] as String?,
      resourceTag: json['resourceTag'] as String?,
      goalId: json['goalId'] as String?,
      milestoneId: json['milestoneId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: _dateTimeOrNull(json['completedAt']),
    );
  }

  Map<String, dynamic> _slotToJson(TimetableSlot slot) => {
    'id': slot.id,
    'weekday': slot.weekday,
    'startHour': slot.startHour,
    'startMinute': slot.startMinute,
    'endHour': slot.endHour,
    'endMinute': slot.endMinute,
    'isBusy': slot.isBusy,
    'label': slot.label,
  };

  TimetableSlot _slotFromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      id: json['id'] as String,
      weekday: json['weekday'] as int,
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int,
      isBusy: json['isBusy'] as bool,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> _sessionToJson(PlannedSession session) => {
    'id': session.id,
    'taskId': session.taskId,
    'start': session.start.toIso8601String(),
    'end': session.end.toIso8601String(),
    'status': session.status.name,
    'completed': session.completed,
    'actualMinutesFocused': session.actualMinutesFocused,
  };

  PlannedSession _sessionFromJson(Map<String, dynamic> json) {
    return PlannedSession(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      status: PlannedSessionStatus.values.byName(json['status'] as String),
      completed: json['completed'] as bool? ?? false,
      actualMinutesFocused: json['actualMinutesFocused'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _goalToJson(LearningGoal goal) => {
    'id': goal.id,
    'title': goal.title,
    'description': goal.description,
    'goalType': goal.goalType.name,
    'targetDate': goal.targetDate?.toIso8601String(),
    'priority': goal.priority,
    'status': goal.status.name,
    'estimatedTotalMinutes': goal.estimatedTotalMinutes,
    'createdAt': goal.createdAt.toIso8601String(),
    'completedAt': goal.completedAt?.toIso8601String(),
  };

  LearningGoal _goalFromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      goalType: GoalType.values.byName(json['goalType'] as String),
      targetDate: _dateTimeOrNull(json['targetDate']),
      priority: json['priority'] as int,
      status: GoalStatus.values.byName(json['status'] as String),
      estimatedTotalMinutes: json['estimatedTotalMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: _dateTimeOrNull(json['completedAt']),
    );
  }

  Map<String, dynamic> _milestoneToJson(GoalMilestone milestone) => {
    'id': milestone.id,
    'goalId': milestone.goalId,
    'title': milestone.title,
    'description': milestone.description,
    'sequenceOrder': milestone.sequenceOrder,
    'estimatedMinutes': milestone.estimatedMinutes,
    'isCompleted': milestone.isCompleted,
    'createdAt': milestone.createdAt.toIso8601String(),
    'completedAt': milestone.completedAt?.toIso8601String(),
  };

  GoalMilestone _milestoneFromJson(Map<String, dynamic> json) {
    return GoalMilestone(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sequenceOrder: json['sequenceOrder'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: _dateTimeOrNull(json['completedAt']),
    );
  }

  Map<String, dynamic> _dependencyToJson(TaskDependency dependency) => {
    'id': dependency.id,
    'taskId': dependency.taskId,
    'dependsOnTaskId': dependency.dependsOnTaskId,
    'createdAt': dependency.createdAt.toIso8601String(),
  };

  TaskDependency _dependencyFromJson(Map<String, dynamic> json) {
    return TaskDependency(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      dependsOnTaskId: json['dependsOnTaskId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> _preferencesToJson(
    NotificationPreferences preferences,
  ) => {
    'id': preferences.id,
    'sessionRemindersEnabled': preferences.sessionRemindersEnabled,
    'dailySummaryEnabled': preferences.dailySummaryEnabled,
    'deadlineWarningsEnabled': preferences.deadlineWarningsEnabled,
    'reminderLeadTimeMinutes': preferences.reminderLeadTimeMinutes,
    'dailySummaryHour': preferences.dailySummaryHour,
    'dailySummaryMinute': preferences.dailySummaryMinute,
    'backupReminderEnabled': preferences.backupReminderEnabled,
    'backupReminderCadence': preferences.backupReminderCadence.name,
    'syncEnabled': preferences.syncEnabled,
    'autoSyncEnabled': preferences.autoSyncEnabled,
    'syncOnWifiOnly': preferences.syncOnWifiOnly,
  };

  NotificationPreferences _preferencesFromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] as int? ?? 1,
      sessionRemindersEnabled: json['sessionRemindersEnabled'] as bool? ?? true,
      dailySummaryEnabled: json['dailySummaryEnabled'] as bool? ?? true,
      deadlineWarningsEnabled: json['deadlineWarningsEnabled'] as bool? ?? true,
      reminderLeadTimeMinutes: json['reminderLeadTimeMinutes'] as int? ?? 10,
      dailySummaryHour: json['dailySummaryHour'] as int? ?? 7,
      dailySummaryMinute: json['dailySummaryMinute'] as int? ?? 0,
      backupReminderEnabled: json['backupReminderEnabled'] as bool? ?? false,
      backupReminderCadence: BackupReminderCadence.values.byName(
        json['backupReminderCadence'] as String? ??
            BackupReminderCadence.weekly.name,
      ),
      syncEnabled: json['syncEnabled'] as bool? ?? false,
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
      syncOnWifiOnly: json['syncOnWifiOnly'] as bool? ?? false,
    );
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return null;
  }
}
