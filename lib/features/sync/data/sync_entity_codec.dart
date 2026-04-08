import 'dart:convert';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/domain/routine_repeat_rule.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_group.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../routines/models/routine_template.dart';
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
      case SyncEntityType.routine:
        return _routineToJson(entity as Routine);
      case SyncEntityType.routineOccurrence:
        return _routineOccurrenceToJson(entity as RoutineOccurrence);
      case SyncEntityType.routineTemplate:
        return _routineTemplateToJson(entity as RoutineTemplate);
      case SyncEntityType.routineGroup:
        return _routineGroupToJson(entity as RoutineGroup);
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
      case SyncEntityType.routine:
        return (entity as Routine).id;
      case SyncEntityType.routineOccurrence:
        return (entity as RoutineOccurrence).id;
      case SyncEntityType.routineTemplate:
        return (entity as RoutineTemplate).id;
      case SyncEntityType.routineGroup:
        return (entity as RoutineGroup).id;
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
      case SyncEntityType.routine:
        return _routineFromJson(json);
      case SyncEntityType.routineOccurrence:
        return _routineOccurrenceFromJson(json);
      case SyncEntityType.routineTemplate:
        return _routineTemplateFromJson(json);
      case SyncEntityType.routineGroup:
        return _routineGroupFromJson(json);
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
    'progressResetAt': task.progressResetAt?.toIso8601String(),
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
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: _dateTimeOrNull(json['updatedAt']) ??
          DateTime.parse(json['createdAt'] as String),
      completedAt: _dateTimeOrNull(json['completedAt']),
      archivedAt: _dateTimeOrNull(json['archivedAt']),
      progressResetAt: _dateTimeOrNull(json['progressResetAt']),
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

  Map<String, dynamic> _routineToJson(Routine routine) => {
    'id': routine.id,
    'title': routine.title,
    'description': routine.description,
    'isArchived': routine.isArchived,
    'createdAt': routine.createdAt.toIso8601String(),
    'updatedAt': routine.updatedAt?.toIso8601String(),
    'anchorDate': routine.anchorDate.toIso8601String(),
    'repeatRule': _repeatRuleToJson(routine.repeatRule),
    'preferredStartMinuteOfDay': routine.preferredStartMinuteOfDay,
    'preferredDurationMinutes': routine.preferredDurationMinutes,
    'timeWindowStartMinuteOfDay': routine.timeWindowStartMinuteOfDay,
    'timeWindowEndMinuteOfDay': routine.timeWindowEndMinuteOfDay,
    'isFlexible': routine.isFlexible,
    'autoRescheduleMissed': routine.autoRescheduleMissed,
    'countsTowardConsistency': routine.countsTowardConsistency,
    'linkedGoalId': routine.linkedGoalId,
    'linkedProjectId': routine.linkedProjectId,
    'sourceTemplateId': routine.sourceTemplateId,
    'categoryId': routine.categoryId,
    'tagIds': routine.tagIds,
    'routineType': routine.routineType.name,
    'isActive': routine.isActive,
    'archivedAt': routine.archivedAt?.toIso8601String(),
    'priority': routine.priority,
    'energyType': routine.energyType,
    'colorHex': routine.colorHex,
    'iconName': routine.iconName,
    'remindersEnabled': routine.remindersEnabled,
    'reminderLeadMinutes': routine.reminderLeadMinutes,
  };

  Routine _routineFromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: _dateTimeOrNull(json['updatedAt']) ??
          DateTime.parse(json['createdAt'] as String),
      anchorDate: DateTime.parse(json['anchorDate'] as String),
      repeatRule: _repeatRuleFromJson(json['repeatRule'] as Map<String, dynamic>),
      preferredStartMinuteOfDay: json['preferredStartMinuteOfDay'] as int?,
      preferredDurationMinutes: json['preferredDurationMinutes'] as int?,
      timeWindowStartMinuteOfDay: json['timeWindowStartMinuteOfDay'] as int?,
      timeWindowEndMinuteOfDay: json['timeWindowEndMinuteOfDay'] as int?,
      isFlexible: json['isFlexible'] as bool? ?? true,
      autoRescheduleMissed: json['autoRescheduleMissed'] as bool? ?? false,
      countsTowardConsistency: json['countsTowardConsistency'] as bool? ?? true,
      linkedGoalId: json['linkedGoalId'] as String?,
      linkedProjectId: json['linkedProjectId'] as String?,
      sourceTemplateId: json['sourceTemplateId'] as String?,
      categoryId: json['categoryId'] as String?,
      tagIds:
          (json['tagIds'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
      routineType: RoutineType.values.byName(
        json['routineType'] as String? ?? RoutineType.custom.name,
      ),
      isActive: json['isActive'] as bool? ?? true,
      archivedAt: _dateTimeOrNull(json['archivedAt']),
      priority: json['priority'] as int? ?? 3,
      energyType: json['energyType'] as String?,
      colorHex: json['colorHex'] as String?,
      iconName: json['iconName'] as String?,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderLeadMinutes: json['reminderLeadMinutes'] as int?,
    );
  }

  Map<String, dynamic> _routineOccurrenceToJson(RoutineOccurrence occurrence) => {
    'id': occurrence.id,
    'routineId': occurrence.routineId,
    'occurrenceDate': occurrence.occurrenceDate.toIso8601String(),
    'scheduledStart': occurrence.scheduledStart?.toIso8601String(),
    'scheduledEnd': occurrence.scheduledEnd?.toIso8601String(),
    'status': occurrence.status.name,
    'createdAt': occurrence.createdAt.toIso8601String(),
    'updatedAt': occurrence.updatedAt?.toIso8601String(),
    'completedAt': occurrence.completedAt?.toIso8601String(),
    'skippedAt': occurrence.skippedAt?.toIso8601String(),
    'missedAt': occurrence.missedAt?.toIso8601String(),
    'sourceTaskId': occurrence.sourceTaskId,
    'notes': occurrence.notes,
    'isRecoveryInstance': occurrence.isRecoveryInstance,
    'recoveredFromOccurrenceId': occurrence.recoveredFromOccurrenceId,
    'needsAttention': occurrence.needsAttention,
    'isAutoScheduled': occurrence.isAutoScheduled,
    'schedulingNote': occurrence.schedulingNote,
    'isManualOverride': occurrence.isManualOverride,
    'recoveryDismissedAt': occurrence.recoveryDismissedAt?.toIso8601String(),
  };

  RoutineOccurrence _routineOccurrenceFromJson(Map<String, dynamic> json) {
    return RoutineOccurrence(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      occurrenceDate: DateTime.parse(json['occurrenceDate'] as String),
      scheduledStart: _dateTimeOrNull(json['scheduledStart']),
      scheduledEnd: _dateTimeOrNull(json['scheduledEnd']),
      status: RoutineOccurrenceStatus.values.byName(
        json['status'] as String? ?? RoutineOccurrenceStatus.pending.name,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: _dateTimeOrNull(json['updatedAt']) ??
          DateTime.parse(json['createdAt'] as String),
      completedAt: _dateTimeOrNull(json['completedAt']),
      skippedAt: _dateTimeOrNull(json['skippedAt']),
      missedAt: _dateTimeOrNull(json['missedAt']),
      sourceTaskId: json['sourceTaskId'] as String?,
      notes: json['notes'] as String?,
      isRecoveryInstance: json['isRecoveryInstance'] as bool? ?? false,
      recoveredFromOccurrenceId: json['recoveredFromOccurrenceId'] as String?,
      needsAttention: json['needsAttention'] as bool? ?? false,
      isAutoScheduled: json['isAutoScheduled'] as bool? ?? false,
      schedulingNote: json['schedulingNote'] as String?,
      isManualOverride: json['isManualOverride'] as bool? ?? false,
      recoveryDismissedAt: _dateTimeOrNull(json['recoveryDismissedAt']),
    );
  }

  Map<String, dynamic> _routineTemplateToJson(RoutineTemplate template) => {
    'id': template.id,
    'name': template.name,
    'description': template.description,
    'category': template.category,
    'items': template.items.map(_routineTemplateItemToJson).toList(),
    'createdAt': template.createdAt.toIso8601String(),
    'updatedAt': template.updatedAt?.toIso8601String(),
    'isBuiltIn': template.isBuiltIn,
    'starterPackId': template.starterPackId,
    'starterPackName': template.starterPackName,
    'setupNotes': template.setupNotes,
    'estimatedWeeklyMinutes': template.estimatedWeeklyMinutes,
    'tags': template.tags,
  };

  RoutineTemplate _routineTemplateFromJson(Map<String, dynamic> json) {
    return RoutineTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'general',
      items: (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_routineTemplateItemFromJson)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: _dateTimeOrNull(json['updatedAt']) ??
          DateTime.parse(json['createdAt'] as String),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      starterPackId: json['starterPackId'] as String?,
      starterPackName: json['starterPackName'] as String?,
      setupNotes: json['setupNotes'] as String?,
      estimatedWeeklyMinutes: json['estimatedWeeklyMinutes'] as int?,
      tags: (json['tags'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
    );
  }

  Map<String, dynamic> _routineTemplateItemToJson(RoutineTemplateItem item) => {
    'title': item.title,
    'description': item.description,
    'repeatRule': _repeatRuleToJson(item.repeatRule),
    'preferredStartMinuteOfDay': item.preferredStartMinuteOfDay,
    'preferredDurationMinutes': item.preferredDurationMinutes,
    'timeWindowStartMinuteOfDay': item.timeWindowStartMinuteOfDay,
    'timeWindowEndMinuteOfDay': item.timeWindowEndMinuteOfDay,
    'isFlexible': item.isFlexible,
    'autoRescheduleMissed': item.autoRescheduleMissed,
    'countsTowardConsistency': item.countsTowardConsistency,
    'suggestedGoalTag': item.suggestedGoalTag,
    'suggestedProjectTag': item.suggestedProjectTag,
    'categoryId': item.categoryId,
    'tagIds': item.tagIds,
    'routineType': item.routineType.name,
    'priority': item.priority,
    'energyType': item.energyType,
    'colorHex': item.colorHex,
    'iconName': item.iconName,
    'remindersEnabled': item.remindersEnabled,
    'reminderLeadMinutes': item.reminderLeadMinutes,
  };

  RoutineTemplateItem _routineTemplateItemFromJson(Map<String, dynamic> json) {
    return RoutineTemplateItem(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      initialRepeatRule: _repeatRuleFromJson(
        (json['repeatRule'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      preferredStartMinuteOfDay: json['preferredStartMinuteOfDay'] as int?,
      preferredDurationMinutes: json['preferredDurationMinutes'] as int?,
      timeWindowStartMinuteOfDay: json['timeWindowStartMinuteOfDay'] as int?,
      timeWindowEndMinuteOfDay: json['timeWindowEndMinuteOfDay'] as int?,
      isFlexible: json['isFlexible'] as bool? ?? true,
      autoRescheduleMissed: json['autoRescheduleMissed'] as bool? ?? false,
      countsTowardConsistency: json['countsTowardConsistency'] as bool? ?? true,
      suggestedGoalTag: json['suggestedGoalTag'] as String?,
      suggestedProjectTag: json['suggestedProjectTag'] as String?,
      categoryId: json['categoryId'] as String?,
      tagIds:
          (json['tagIds'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
      routineType: RoutineType.values.byName(
        json['routineType'] as String? ?? RoutineType.custom.name,
      ),
      priority: json['priority'] as int? ?? 3,
      energyType: json['energyType'] as String?,
      colorHex: json['colorHex'] as String?,
      iconName: json['iconName'] as String?,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderLeadMinutes: json['reminderLeadMinutes'] as int?,
    );
  }

  Map<String, dynamic> _routineGroupToJson(RoutineGroup group) => {
    'id': group.id,
    'name': group.name,
    'description': group.description,
    'routineIds': group.routineIds,
    'createdAt': group.createdAt.toIso8601String(),
    'updatedAt': group.updatedAt?.toIso8601String(),
    'colorHex': group.colorHex,
    'iconName': group.iconName,
    'linkedGoalId': group.linkedGoalId,
    'linkedProjectId': group.linkedProjectId,
    'isArchived': group.isArchived,
  };

  RoutineGroup _routineGroupFromJson(Map<String, dynamic> json) {
    return RoutineGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      routineIds:
          (json['routineIds'] as List?)?.map((item) => item.toString()).toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: _dateTimeOrNull(json['updatedAt']) ??
          DateTime.parse(json['createdAt'] as String),
      colorHex: json['colorHex'] as String?,
      iconName: json['iconName'] as String?,
      linkedGoalId: json['linkedGoalId'] as String?,
      linkedProjectId: json['linkedProjectId'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _repeatRuleToJson(RoutineRepeatRule rule) => {
    'type': rule.type.name,
    'interval': rule.interval,
    'weekdays': rule.weekdays,
    'dayOfMonth': rule.dayOfMonth,
  };

  RoutineRepeatRule _repeatRuleFromJson(Map<String, dynamic> json) {
    return RoutineRepeatRule(
      type: RoutineRepeatType.values.byName(
        json['type'] as String? ?? RoutineRepeatType.daily.name,
      ),
      interval: json['interval'] as int? ?? 1,
      weekdays:
          (json['weekdays'] as List?)?.whereType<int>().toList() ?? const [],
      dayOfMonth: json['dayOfMonth'] as int?,
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



