import 'dart:convert';

import '../../../core/database/database_version.dart';
import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
import '../../notes/models/entity_note.dart';
import '../../notes/models/entity_resource.dart';
import '../../review/models/weekly_review.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';
import '../domain/backup_models.dart';

class BackupSerialization {
  const BackupSerialization();

  String encodeBundle(AppBackupBundle bundle) {
    return const JsonEncoder.withIndent('  ').convert(bundleToJson(bundle));
  }

  Map<String, dynamic> bundleToJson(AppBackupBundle bundle) {
    return {
      'backupFormatVersion': bundle.metadata.backupFormatVersion,
      'metadata': {
        'appVersion': bundle.metadata.appVersion,
        'schemaVersion': bundle.metadata.schemaVersion,
        'createdAt': bundle.metadata.createdAt.toIso8601String(),
        'platform': bundle.metadata.platform,
        'entityCounts': bundle.metadata.entityCounts,
      },
      'collections': {
        'tasks': bundle.tasks.map(_taskToJson).toList(),
        'timetableSlots': bundle.timetableSlots
            .map(_timetableSlotToJson)
            .toList(),
        'plannedSessions': bundle.plannedSessions
            .map(_plannedSessionToJson)
            .toList(),
        'goals': bundle.goals.map(_goalToJson).toList(),
        'milestones': bundle.milestones.map(_milestoneToJson).toList(),
        'dependencies': bundle.dependencies.map(_dependencyToJson).toList(),
        'entityNotes': bundle.entityNotes.map(_entityNoteToJson).toList(),
        'entityResources': bundle.entityResources.map(_entityResourceToJson).toList(),
        'weeklyReviews': bundle.weeklyReviews.map(_weeklyReviewToJson).toList(),
        'settings': _preferencesToJson(bundle.preferences),
      },
    };
  }

  BackupValidationResult decodeBundle(String jsonString) {
    final warnings = <String>[];
    final errors = <String>[];

    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (error) {
      return BackupValidationResult(
        isValid: false,
        errors: ['Malformed JSON: $error'],
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const BackupValidationResult(
        isValid: false,
        errors: ['Backup root must be a JSON object.'],
      );
    }

    final formatVersion = _asInt(decoded['backupFormatVersion']);
    if (formatVersion == null) {
      errors.add('Missing backupFormatVersion.');
    } else if (formatVersion > AppDatabaseVersion.backupFormatVersion) {
      errors.add(
        'Backup format version $formatVersion is newer than this app supports.',
      );
    }

    final metadataMap = decoded['metadata'];
    if (metadataMap is! Map<String, dynamic>) {
      errors.add('Missing metadata object.');
    }

    final collections = decoded['collections'];
    if (collections is! Map<String, dynamic>) {
      errors.add('Missing collections object.');
    }

    if (errors.isNotEmpty) {
      return BackupValidationResult(
        isValid: false,
        warnings: warnings,
        errors: errors,
      );
    }

    final validMetadataMap = metadataMap as Map<String, dynamic>;
    final validCollections = collections as Map<String, dynamic>;
    final metadata = _parseMetadata(
      metadataMap: validMetadataMap,
      formatVersion: formatVersion!,
      warnings: warnings,
      errors: errors,
    );
    final tasks = _parseCollection<Task>(
      name: 'tasks',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _taskFromJson(json, itemWarnings),
    );
    final timetableSlots = _parseCollection<TimetableSlot>(
      name: 'timetableSlots',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) =>
          _timetableSlotFromJson(json, itemWarnings),
    );
    final plannedSessions = _parseCollection<PlannedSession>(
      name: 'plannedSessions',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) =>
          _plannedSessionFromJson(json, itemWarnings),
    );
    final goals = _parseCollection<LearningGoal>(
      name: 'goals',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _goalFromJson(json, itemWarnings),
    );
    final milestones = _parseCollection<GoalMilestone>(
      name: 'milestones',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _milestoneFromJson(json, itemWarnings),
    );
    final dependencies = _parseCollection<TaskDependency>(
      name: 'dependencies',
      source: validCollections,
      warnings: warnings,
      errors: errors,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _dependencyFromJson(json, itemWarnings),
    );
    final entityNotes = _parseOptionalCollection<EntityNote>(
      name: 'entityNotes',
      source: validCollections,
      warnings: warnings,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _entityNoteFromJson(json, itemWarnings),
    );
    final entityResources = _parseOptionalCollection<EntityResource>(
      name: 'entityResources',
      source: validCollections,
      warnings: warnings,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) =>
          _entityResourceFromJson(json, itemWarnings),
    );
    final weeklyReviews = _parseOptionalCollection<WeeklyReview>(
      name: 'weeklyReviews',
      source: validCollections,
      warnings: warnings,
      idOf: (item) => item.id,
      parser: (json, itemWarnings) => _weeklyReviewFromJson(json, itemWarnings),
    );

    final settingsMap = validCollections['settings'];
    final preferences = _preferencesFromJson(settingsMap, warnings, errors);

    if (metadata == null || preferences == null || errors.isNotEmpty) {
      return BackupValidationResult(
        isValid: false,
        warnings: warnings,
        errors: errors,
      );
    }

    final normalizedBundle = _normalizeBundle(
      bundle: AppBackupBundle(
        metadata: metadata,
        tasks: tasks,
        timetableSlots: timetableSlots,
        plannedSessions: plannedSessions,
        goals: goals,
        milestones: milestones,
        dependencies: dependencies,
        entityNotes: entityNotes,
        entityResources: entityResources,
        weeklyReviews: weeklyReviews,
        preferences: preferences,
      ),
      warnings: warnings,
    );

    return BackupValidationResult(
      isValid: true,
      bundle: normalizedBundle,
      warnings: warnings,
      errors: errors,
    );
  }

  BackupMetadata? _parseMetadata({
    required Map<String, dynamic> metadataMap,
    required int formatVersion,
    required List<String> warnings,
    required List<String> errors,
  }) {
    final appVersion = metadataMap['appVersion']?.toString();
    final schemaVersion = _asInt(metadataMap['schemaVersion']);
    final createdAt = _asDateTime(metadataMap['createdAt']);
    final platform = metadataMap['platform']?.toString();
    final entityCountsMap = metadataMap['entityCounts'];
    final entityCounts = <String, int>{};

    if (appVersion == null || appVersion.isEmpty) {
      errors.add('Metadata appVersion is missing.');
    }
    if (schemaVersion == null) {
      errors.add('Metadata schemaVersion is missing or invalid.');
    }
    if (createdAt == null) {
      errors.add('Metadata createdAt is missing or invalid.');
    }
    if (platform == null || platform.isEmpty) {
      errors.add('Metadata platform is missing.');
    }
    if (entityCountsMap is Map) {
      for (final entry in entityCountsMap.entries) {
        final count = _asInt(entry.value);
        if (count != null) {
          entityCounts[entry.key.toString()] = count;
        }
      }
    } else {
      warnings.add('Metadata entityCounts is missing or invalid.');
    }

    if (errors.isNotEmpty) {
      return null;
    }

    return BackupMetadata(
      appVersion: appVersion!,
      schemaVersion: schemaVersion!,
      backupFormatVersion: formatVersion,
      createdAt: createdAt!,
      platform: platform!,
      entityCounts: entityCounts,
    );
  }

  List<T> _parseCollection<T>({
    required String name,
    required Map<String, dynamic> source,
    required List<String> warnings,
    required List<String> errors,
    required String Function(T item) idOf,
    required T? Function(Map<String, dynamic> json, List<String> warnings)
    parser,
  }) {
    final raw = source[name];
    if (raw is! List) {
      errors.add('Collection $name is missing or invalid.');
      return const [];
    }

    final valuesById = <String, T>{};
    for (var index = 0; index < raw.length; index++) {
      final item = raw[index];
      if (item is! Map<String, dynamic>) {
        warnings.add('Skipping invalid $name[$index] entry.');
        continue;
      }
      final itemWarnings = <String>[];
      final parsed = parser(item, itemWarnings);
      warnings.addAll(itemWarnings.map((warning) => '$name[$index]: $warning'));
      if (parsed == null) {
        continue;
      }
      final id = idOf(parsed);
      if (valuesById.containsKey(id)) {
        warnings.add(
          'Duplicate $name id "$id" found in backup; later entry will replace the earlier one.',
        );
      }
      valuesById[id] = parsed;
    }
    return valuesById.values.toList();
  }

  List<T> _parseOptionalCollection<T>({
    required String name,
    required Map<String, dynamic> source,
    required List<String> warnings,
    required String Function(T item) idOf,
    required T? Function(Map<String, dynamic> json, List<String> warnings)
    parser,
  }) {
    final raw = source[name];
    if (raw == null) {
      return const [];
    }
    if (raw is! List) {
      warnings.add('Collection $name is invalid and will be ignored.');
      return const [];
    }

    final valuesById = <String, T>{};
    for (var index = 0; index < raw.length; index++) {
      final item = raw[index];
      if (item is! Map<String, dynamic>) {
        warnings.add('Skipping invalid $name[$index] entry.');
        continue;
      }
      final itemWarnings = <String>[];
      final parsed = parser(item, itemWarnings);
      warnings.addAll(itemWarnings.map((warning) => '$name[$index]: $warning'));
      if (parsed == null) {
        continue;
      }
      valuesById[idOf(parsed)] = parsed;
    }
    return valuesById.values.toList();
  }

  AppBackupBundle _normalizeBundle({
    required AppBackupBundle bundle,
    required List<String> warnings,
  }) {
    final goalIds = bundle.goals.map((item) => item.id).toSet();
    final milestoneIds = bundle.milestones.map((item) => item.id).toSet();
    final taskIds = bundle.tasks.map((item) => item.id).toSet();
    final goalIdsForAttachments = bundle.goals.map((item) => item.id).toSet();

    final normalizedMilestones = <GoalMilestone>[];
    for (final milestone in bundle.milestones) {
      if (!goalIds.contains(milestone.goalId)) {
        warnings.add(
          'Milestone ${milestone.id} references missing goal ${milestone.goalId} and will be skipped.',
        );
        continue;
      }
      normalizedMilestones.add(milestone);
    }

    final normalizedTasks = <Task>[];
    for (final task in bundle.tasks) {
      var normalizedTask = task;
      if (task.goalId != null && !goalIds.contains(task.goalId)) {
        warnings.add(
          'Task ${task.id} references missing goal ${task.goalId}; goal link will be cleared.',
        );
        normalizedTask = normalizedTask.copyWith(clearGoalId: true);
      }
      if (task.milestoneId != null &&
          !milestoneIds.contains(task.milestoneId)) {
        warnings.add(
          'Task ${task.id} references missing milestone ${task.milestoneId}; milestone link will be cleared.',
        );
        normalizedTask = normalizedTask.copyWith(clearMilestoneId: true);
      }
      normalizedTasks.add(normalizedTask);
    }

    final normalizedSessions = <PlannedSession>[];
    for (final session in bundle.plannedSessions) {
      if (!taskIds.contains(session.taskId)) {
        warnings.add(
          'Planned session ${session.id} references missing task ${session.taskId} and will be skipped.',
        );
        continue;
      }
      normalizedSessions.add(session);
    }

    final normalizedDependencies = <TaskDependency>[];
    for (final dependency in bundle.dependencies) {
      if (!taskIds.contains(dependency.taskId) ||
          !taskIds.contains(dependency.dependsOnTaskId)) {
        warnings.add(
          'Dependency ${dependency.id} references missing task ids and will be skipped.',
        );
        continue;
      }
      normalizedDependencies.add(dependency);
    }

    final normalizedNotes = <EntityNote>[];
    for (final note in bundle.entityNotes) {
      final entityExists = switch (note.entityType) {
        EntityAttachmentType.task => taskIds.contains(note.entityId),
        EntityAttachmentType.goal => goalIdsForAttachments.contains(note.entityId),
      };
      if (!entityExists) {
        warnings.add(
          'Note ${note.id} references missing ${note.entityType.name} ${note.entityId} and will be skipped.',
        );
        continue;
      }
      normalizedNotes.add(note);
    }

    final normalizedResources = <EntityResource>[];
    for (final resource in bundle.entityResources) {
      final entityExists = switch (resource.entityType) {
        EntityAttachmentType.task => taskIds.contains(resource.entityId),
        EntityAttachmentType.goal =>
          goalIdsForAttachments.contains(resource.entityId),
      };
      if (!entityExists) {
        warnings.add(
          'Resource ${resource.id} references missing ${resource.entityType.name} ${resource.entityId} and will be skipped.',
        );
        continue;
      }
      normalizedResources.add(resource);
    }

    final normalizedWeeklyReviews = <WeeklyReview>[];
    for (final review in bundle.weeklyReviews) {
      if (review.weekEnd.isBefore(review.weekStart)) {
        warnings.add(
          'Weekly review ${review.id} has an invalid date range and will be skipped.',
        );
        continue;
      }
      normalizedWeeklyReviews.add(review);
    }

    return AppBackupBundle(
      metadata: bundle.metadata,
      tasks: normalizedTasks,
      timetableSlots: bundle.timetableSlots,
      plannedSessions: normalizedSessions,
      goals: bundle.goals,
      milestones: normalizedMilestones,
      dependencies: normalizedDependencies,
      entityNotes: normalizedNotes,
      entityResources: normalizedResources,
      weeklyReviews: normalizedWeeklyReviews,
      preferences: bundle.preferences,
      warnings: List<String>.from(warnings),
    );
  }

  Map<String, dynamic> _taskToJson(Task task) {
    return {
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
  }

  Task? _taskFromJson(Map<String, dynamic> json, List<String> warnings) {
    final id = json['id']?.toString();
    final title = json['title']?.toString();
    final type = _taskTypeFromJson(json['type'], warnings);
    final estimatedDurationMinutes = _asInt(json['estimatedDurationMinutes']);
    final priority = _asInt(json['priority']);
    final createdAt = _asDateTime(json['createdAt']);
    if ([
      id,
      title,
      type,
      estimatedDurationMinutes,
      priority,
      createdAt,
    ].any((value) => value == null)) {
      warnings.add('Task is missing required fields and will be skipped.');
      return null;
    }

    final validTitle = title!;
    final validEstimatedDurationMinutes = estimatedDurationMinutes!;
    final validPriority = priority!;
    final validCreatedAt = createdAt!;
    return Task(
      id: id!,
      title: validTitle,
      description: json['description']?.toString(),
      type: type,
      estimatedDurationMinutes: validEstimatedDurationMinutes,
      dueDate: _asDateTime(json['dueDate']),
      priority: validPriority,
      resourceUrl: json['resourceUrl']?.toString(),
      resourceTag: json['resourceTag']?.toString(),
      goalId: json['goalId']?.toString(),
      milestoneId: json['milestoneId']?.toString(),
      isCompleted: _asBool(json['isCompleted']) ?? false,
      isArchived: _asBool(json['isArchived']) ?? false,
      createdAt: validCreatedAt,
      updatedAt: _asDateTime(json['updatedAt']) ?? validCreatedAt,
      completedAt: _asDateTime(json['completedAt']),
      archivedAt: _asDateTime(json['archivedAt']),
      progressResetAt: _asDateTime(json['progressResetAt']),
    );
  }

  Map<String, dynamic> _timetableSlotToJson(TimetableSlot slot) {
    return {
      'id': slot.id,
      'weekday': slot.weekday,
      'startHour': slot.startHour,
      'startMinute': slot.startMinute,
      'endHour': slot.endHour,
      'endMinute': slot.endMinute,
      'isBusy': slot.isBusy,
      'label': slot.label,
    };
  }

  TimetableSlot? _timetableSlotFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final weekday = _asInt(json['weekday']);
    final startHour = _asInt(json['startHour']);
    final startMinute = _asInt(json['startMinute']);
    final endHour = _asInt(json['endHour']);
    final endMinute = _asInt(json['endMinute']);
    final label = json['label']?.toString();
    final isBusy = _asBool(json['isBusy']);
    if ([
      id,
      weekday,
      startHour,
      startMinute,
      endHour,
      endMinute,
      label,
      isBusy,
    ].any((value) => value == null)) {
      warnings.add(
        'Timetable slot is missing required fields and will be skipped.',
      );
      return null;
    }

    final validWeekday = weekday!;
    final validStartHour = startHour!;
    final validStartMinute = startMinute!;
    final validEndHour = endHour!;
    final validEndMinute = endMinute!;
    final validIsBusy = isBusy!;
    final validLabel = label!;
    return TimetableSlot(
      id: id!,
      weekday: validWeekday,
      startHour: validStartHour,
      startMinute: validStartMinute,
      endHour: validEndHour,
      endMinute: validEndMinute,
      isBusy: validIsBusy,
      label: validLabel,
    );
  }

  Map<String, dynamic> _plannedSessionToJson(PlannedSession session) {
    return {
      'id': session.id,
      'taskId': session.taskId,
      'start': session.start.toIso8601String(),
      'end': session.end.toIso8601String(),
      'status': session.status.name,
      'completed': session.completed,
      'actualMinutesFocused': session.actualMinutesFocused,
    };
  }

  PlannedSession? _plannedSessionFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final taskId = json['taskId']?.toString();
    final start = _asDateTime(json['start']);
    final end = _asDateTime(json['end']);
    final status = _plannedSessionStatusFromJson(json['status'], warnings);
    final completed = _asBool(json['completed']) ?? false;
    final actualMinutesFocused = _asInt(json['actualMinutesFocused']) ?? 0;
    if ([id, taskId, start, end, status].any((value) => value == null)) {
      warnings.add(
        'Planned session is missing required fields and will be skipped.',
      );
      return null;
    }

    final validTaskId = taskId!;
    final validStart = start!;
    final validEnd = end!;
    final validStatus = status;
    return PlannedSession(
      id: id!,
      taskId: validTaskId,
      start: validStart,
      end: validEnd,
      status: validStatus,
      completed: completed,
      actualMinutesFocused: actualMinutesFocused,
    );
  }

  Map<String, dynamic> _goalToJson(LearningGoal goal) {
    return {
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
  }

  LearningGoal? _goalFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final title = json['title']?.toString();
    final goalType = _goalTypeFromJson(json['goalType'], warnings);
    final priority = _asInt(json['priority']);
    final status = _goalStatusFromJson(json['status'], warnings);
    final createdAt = _asDateTime(json['createdAt']);
    if ([
      id,
      title,
      goalType,
      priority,
      status,
      createdAt,
    ].any((value) => value == null)) {
      warnings.add('Goal is missing required fields and will be skipped.');
      return null;
    }

    final validTitle = title!;
    final validPriority = priority!;
    final validCreatedAt = createdAt!;
    return LearningGoal(
      id: id!,
      title: validTitle,
      description: json['description']?.toString(),
      goalType: goalType,
      targetDate: _asDateTime(json['targetDate']),
      priority: validPriority,
      status: status,
      estimatedTotalMinutes: _asInt(json['estimatedTotalMinutes']),
      createdAt: validCreatedAt,
      completedAt: _asDateTime(json['completedAt']),
    );
  }

  Map<String, dynamic> _milestoneToJson(GoalMilestone milestone) {
    return {
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
  }

  GoalMilestone? _milestoneFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final goalId = json['goalId']?.toString();
    final title = json['title']?.toString();
    final sequenceOrder = _asInt(json['sequenceOrder']);
    final estimatedMinutes = _asInt(json['estimatedMinutes']);
    final createdAt = _asDateTime(json['createdAt']);
    if ([
      id,
      goalId,
      title,
      sequenceOrder,
      estimatedMinutes,
      createdAt,
    ].any((value) => value == null)) {
      warnings.add('Milestone is missing required fields and will be skipped.');
      return null;
    }

    final validGoalId = goalId!;
    final validTitle = title!;
    final validSequenceOrder = sequenceOrder!;
    final validEstimatedMinutes = estimatedMinutes!;
    final validCreatedAt = createdAt!;
    return GoalMilestone(
      id: id!,
      goalId: validGoalId,
      title: validTitle,
      description: json['description']?.toString(),
      sequenceOrder: validSequenceOrder,
      estimatedMinutes: validEstimatedMinutes,
      isCompleted: _asBool(json['isCompleted']) ?? false,
      createdAt: validCreatedAt,
      completedAt: _asDateTime(json['completedAt']),
    );
  }

  Map<String, dynamic> _dependencyToJson(TaskDependency dependency) {
    return {
      'id': dependency.id,
      'taskId': dependency.taskId,
      'dependsOnTaskId': dependency.dependsOnTaskId,
      'createdAt': dependency.createdAt.toIso8601String(),
    };
  }

  TaskDependency? _dependencyFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final taskId = json['taskId']?.toString();
    final dependsOnTaskId = json['dependsOnTaskId']?.toString();
    final createdAt = _asDateTime(json['createdAt']);
    if ([
      id,
      taskId,
      dependsOnTaskId,
      createdAt,
    ].any((value) => value == null)) {
      warnings.add(
        'Dependency is missing required fields and will be skipped.',
      );
      return null;
    }

    final validTaskId = taskId!;
    final validDependsOnTaskId = dependsOnTaskId!;
    final validCreatedAt = createdAt!;
    return TaskDependency(
      id: id!,
      taskId: validTaskId,
      dependsOnTaskId: validDependsOnTaskId,
      createdAt: validCreatedAt,
    );
  }

  Map<String, dynamic> _entityNoteToJson(EntityNote note) {
    return {
      'id': note.id,
      'entityType': note.entityType.name,
      'entityId': note.entityId,
      'title': note.title,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt?.toIso8601String(),
      'isPinned': note.isPinned,
      'isArchived': note.isArchived,
    };
  }

  EntityNote? _entityNoteFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final entityType = _entityAttachmentTypeFromJson(
      json['entityType'],
      warnings,
    );
    final entityId = json['entityId']?.toString();
    final content = json['content']?.toString();
    final createdAt = _asDateTime(json['createdAt']);
    if ([id, entityType, entityId, content, createdAt].any((v) => v == null)) {
      warnings.add('Entity note is missing required fields and will be skipped.');
      return null;
    }
    return EntityNote(
      id: id!,
      entityType: entityType,
      entityId: entityId!,
      title: json['title']?.toString(),
      content: content!,
      createdAt: createdAt!,
      updatedAt: _asDateTime(json['updatedAt']) ?? createdAt,
      isPinned: _asBool(json['isPinned']) ?? false,
      isArchived: _asBool(json['isArchived']) ?? false,
    );
  }

  Map<String, dynamic> _entityResourceToJson(EntityResource resource) {
    return {
      'id': resource.id,
      'entityType': resource.entityType.name,
      'entityId': resource.entityId,
      'title': resource.title,
      'url': resource.url,
      'description': resource.description,
      'resourceType': resource.resourceType.name,
      'createdAt': resource.createdAt.toIso8601String(),
      'updatedAt': resource.updatedAt?.toIso8601String(),
      'isPinned': resource.isPinned,
    };
  }

  EntityResource? _entityResourceFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final entityType = _entityAttachmentTypeFromJson(
      json['entityType'],
      warnings,
    );
    final entityId = json['entityId']?.toString();
    final title = json['title']?.toString();
    final resourceType = _entityResourceTypeFromJson(
      json['resourceType'],
      warnings,
    );
    final createdAt = _asDateTime(json['createdAt']);
    if ([id, entityType, entityId, title, resourceType, createdAt].any(
      (v) => v == null,
    )) {
      warnings.add(
        'Entity resource is missing required fields and will be skipped.',
      );
      return null;
    }
    return EntityResource(
      id: id!,
      entityType: entityType,
      entityId: entityId!,
      title: title!,
      url: json['url']?.toString(),
      description: json['description']?.toString(),
      resourceType: resourceType,
      createdAt: createdAt!,
      updatedAt: _asDateTime(json['updatedAt']) ?? createdAt,
      isPinned: _asBool(json['isPinned']) ?? false,
    );
  }

  Map<String, dynamic> _weeklyReviewToJson(WeeklyReview review) {
    return {
      'id': review.id,
      'weekStart': review.weekStart.toIso8601String(),
      'weekEnd': review.weekEnd.toIso8601String(),
      'createdAt': review.createdAt.toIso8601String(),
      'updatedAt': review.updatedAt?.toIso8601String(),
      'summaryText': review.summaryText,
      'winsText': review.winsText,
      'challengesText': review.challengesText,
      'nextWeekFocusText': review.nextWeekFocusText,
      'isLocked': review.isLocked,
    };
  }

  WeeklyReview? _weeklyReviewFromJson(
    Map<String, dynamic> json,
    List<String> warnings,
  ) {
    final id = json['id']?.toString();
    final weekStart = _asDateTime(json['weekStart']);
    final weekEnd = _asDateTime(json['weekEnd']);
    final createdAt = _asDateTime(json['createdAt']);
    if ([id, weekStart, weekEnd, createdAt].any((v) => v == null)) {
      warnings.add('Weekly review is missing required fields and will be skipped.');
      return null;
    }
    return WeeklyReview(
      id: id!,
      weekStart: weekStart!,
      weekEnd: weekEnd!,
      createdAt: createdAt!,
      updatedAt: _asDateTime(json['updatedAt']) ?? createdAt,
      summaryText: json['summaryText']?.toString(),
      winsText: json['winsText']?.toString(),
      challengesText: json['challengesText']?.toString(),
      nextWeekFocusText: json['nextWeekFocusText']?.toString(),
      isLocked: _asBool(json['isLocked']) ?? false,
    );
  }

  Map<String, dynamic> _preferencesToJson(NotificationPreferences preferences) {
    return {
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
  }

  NotificationPreferences? _preferencesFromJson(
    Object? raw,
    List<String> warnings,
    List<String> errors,
  ) {
    if (raw is! Map<String, dynamic>) {
      errors.add('Settings collection is missing or invalid.');
      return null;
    }

    return NotificationPreferences(
      sessionRemindersEnabled: _asBool(raw['sessionRemindersEnabled']) ?? true,
      dailySummaryEnabled: _asBool(raw['dailySummaryEnabled']) ?? true,
      deadlineWarningsEnabled: _asBool(raw['deadlineWarningsEnabled']) ?? true,
      reminderLeadTimeMinutes: _asInt(raw['reminderLeadTimeMinutes']) ?? 10,
      dailySummaryHour: _asInt(raw['dailySummaryHour']) ?? 7,
      dailySummaryMinute: _asInt(raw['dailySummaryMinute']) ?? 0,
      backupReminderEnabled: _asBool(raw['backupReminderEnabled']) ?? false,
      backupReminderCadence: _backupReminderCadenceFromJson(
        raw['backupReminderCadence'],
        warnings,
      ),
      syncEnabled: _asBool(raw['syncEnabled']) ?? false,
      autoSyncEnabled: _asBool(raw['autoSyncEnabled']) ?? true,
      syncOnWifiOnly: _asBool(raw['syncOnWifiOnly']) ?? false,
    );
  }

  TaskType _taskTypeFromJson(Object? raw, List<String> warnings) {
    return _enumByName<TaskType>(
          TaskType.values,
          raw,
          warnings,
          fallback: TaskType.misc,
          label: 'task type',
        ) ??
        TaskType.misc;
  }

  PlannedSessionStatus _plannedSessionStatusFromJson(
    Object? raw,
    List<String> warnings,
  ) {
    return _enumByName<PlannedSessionStatus>(
          PlannedSessionStatus.values,
          raw,
          warnings,
          fallback: PlannedSessionStatus.pending,
          label: 'planned session status',
        ) ??
        PlannedSessionStatus.pending;
  }

  GoalType _goalTypeFromJson(Object? raw, List<String> warnings) {
    return _enumByName<GoalType>(
          GoalType.values,
          raw,
          warnings,
          fallback: GoalType.learning,
          label: 'goal type',
        ) ??
        GoalType.learning;
  }

  GoalStatus _goalStatusFromJson(Object? raw, List<String> warnings) {
    return _enumByName<GoalStatus>(
          GoalStatus.values,
          raw,
          warnings,
          fallback: GoalStatus.active,
          label: 'goal status',
        ) ??
        GoalStatus.active;
  }

  EntityAttachmentType _entityAttachmentTypeFromJson(
    Object? raw,
    List<String> warnings,
  ) {
    return _enumByName<EntityAttachmentType>(
          EntityAttachmentType.values,
          raw,
          warnings,
          fallback: EntityAttachmentType.task,
          label: 'entity attachment type',
        ) ??
        EntityAttachmentType.task;
  }

  EntityResourceType _entityResourceTypeFromJson(
    Object? raw,
    List<String> warnings,
  ) {
    return _enumByName<EntityResourceType>(
          EntityResourceType.values,
          raw,
          warnings,
          fallback: EntityResourceType.other,
          label: 'entity resource type',
        ) ??
        EntityResourceType.other;
  }

  BackupReminderCadence _backupReminderCadenceFromJson(
    Object? raw,
    List<String> warnings,
  ) {
    return _enumByName<BackupReminderCadence>(
          BackupReminderCadence.values,
          raw,
          warnings,
          fallback: BackupReminderCadence.weekly,
          label: 'backup reminder cadence',
        ) ??
        BackupReminderCadence.weekly;
  }

  T? _enumByName<T extends Enum>(
    List<T> values,
    Object? raw,
    List<String> warnings, {
    required T fallback,
    required String label,
  }) {
    final name = raw?.toString();
    if (name == null || name.isEmpty) {
      warnings.add('Missing $label; using ${fallback.name}.');
      return fallback;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    warnings.add('Unknown $label "$name"; using ${fallback.name}.');
    return fallback;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  bool? _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return true;
      }
      if (value.toLowerCase() == 'false') {
        return false;
      }
    }
    return null;
  }

  DateTime? _asDateTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}



