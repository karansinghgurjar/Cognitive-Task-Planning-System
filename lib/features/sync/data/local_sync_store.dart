// ignore_for_file: annotate_overrides

import 'package:isar/isar.dart';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../knowledge/models/knowledge_item.dart';
import '../../goals/models/task_dependency.dart';
import '../../routines/domain/routine_enums.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_group.dart';
import '../../routines/models/routine_occurrence.dart';
import '../../routines/models/routine_template.dart';
import '../../schedule/models/planned_session.dart';
import '../../settings/models/notification_preferences.dart';
import '../../tasks/models/task.dart';
import '../../timetable/models/timetable_slot.dart';
import '../domain/sync_models.dart';
import '../domain/sync_store_contracts.dart';
import '../models/sync_entity_metadata.dart';
import 'sync_entity_codec.dart';

class LocalSyncStore implements LocalSyncStoreContract {
  LocalSyncStore(this._isar, {this.codec = const SyncEntityCodec()});

  final Isar _isar;
  final SyncEntityCodec codec;

  Future<int> countLocalEntities() async {
    final tasks = await _isar.tasks.count();
    final timetableSlots = await _isar.timetableSlots.count();
    final sessions = await _isar.plannedSessions.count();
    final goals = await _isar.learningGoals.count();
    final milestones = await _isar.goalMilestones.count();
    final dependencies = await _isar.taskDependencys.count();
    final routines = await _isar.routines.count();
    final routineOccurrences = await _isar.routineOccurrences.count();
    final routineTemplates = await _isar.routineTemplates.count();
    final routineGroups = await _isar.routineGroups.count();
    final knowledgeItems = await _isar.knowledgeItems.count();
    final settings = await _isar.notificationPreferences.count();
    return tasks +
        timetableSlots +
        sessions +
        goals +
        milestones +
        dependencies +
        routines +
        routineOccurrences +
        routineTemplates +
        routineGroups +
        knowledgeItems +
        settings;
  }

  Future<List<SyncEntityEnvelope>> exportAllEntities({
    required String userId,
    required String deviceId,
  }) async {
    final envelopes = <SyncEntityEnvelope>[];
    final tasks = await _isar.tasks.where().findAll();
    final timetableSlots = await _isar.timetableSlots.where().findAll();
    final sessions = await _isar.plannedSessions.where().findAll();
    final goals = await _isar.learningGoals.where().findAll();
    final milestones = await _isar.goalMilestones.where().findAll();
    final dependencies = await _isar.taskDependencys.where().findAll();
    final routines = await _isar.routines.where().findAll();
    final routineOccurrences = await _isar.routineOccurrences.where().findAll();
    final routineTemplates = await _isar.routineTemplates.where().findAll();
    final routineGroups = await _isar.routineGroups.where().findAll();
    final knowledgeItems = await _isar.knowledgeItems.where().findAll();
    final preferences = await _isar.notificationPreferences.get(1);

    for (final task in tasks) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.task,
          entityId: task.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.task, task),
          fallbackModifiedAt: task.updatedAt ?? task.createdAt,
        ),
      );
    }
    for (final slot in timetableSlots) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.timetableSlot,
          entityId: slot.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.timetableSlot, slot),
          fallbackModifiedAt: DateTime.now(),
        ),
      );
    }
    for (final session in sessions) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.plannedSession,
          entityId: session.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.plannedSession, session),
          fallbackModifiedAt: session.start,
        ),
      );
    }
    for (final goal in goals) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.learningGoal,
          entityId: goal.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.learningGoal, goal),
          fallbackModifiedAt: goal.createdAt,
        ),
      );
    }
    for (final milestone in milestones) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.goalMilestone,
          entityId: milestone.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.goalMilestone, milestone),
          fallbackModifiedAt: milestone.createdAt,
        ),
      );
    }
    for (final dependency in dependencies) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.taskDependency,
          entityId: dependency.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(
            SyncEntityType.taskDependency,
            dependency,
          ),
          fallbackModifiedAt: dependency.createdAt,
        ),
      );
    }
    for (final routine in routines) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.routine,
          entityId: routine.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.routine, routine),
          fallbackModifiedAt: routine.updatedAt ?? routine.createdAt,
        ),
      );
    }
    for (final occurrence in routineOccurrences) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.routineOccurrence,
          entityId: occurrence.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(
            SyncEntityType.routineOccurrence,
            occurrence,
          ),
          fallbackModifiedAt: occurrence.updatedAt ?? occurrence.createdAt,
        ),
      );
    }
    for (final template in routineTemplates) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.routineTemplate,
          entityId: template.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.routineTemplate, template),
          fallbackModifiedAt: template.updatedAt ?? template.createdAt,
        ),
      );
    }
    for (final group in routineGroups) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.routineGroup,
          entityId: group.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.routineGroup, group),
          fallbackModifiedAt: group.updatedAt ?? group.createdAt,
        ),
      );
    }
    for (final item in knowledgeItems) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.knowledgeItem,
          entityId: item.id,
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(SyncEntityType.knowledgeItem, item),
          fallbackModifiedAt: item.updatedAt ?? item.createdAt,
        ),
      );
    }
    if (preferences != null) {
      envelopes.add(
        await _buildEnvelope(
          entityType: SyncEntityType.notificationPreferences,
          entityId: 'preferences',
          userId: userId,
          deviceId: deviceId,
          payload: codec.encodeEntity(
            SyncEntityType.notificationPreferences,
            preferences,
          ),
          fallbackModifiedAt: DateTime.now(),
        ),
      );
    }

    return envelopes;
  }

  Future<SyncEntityEnvelope?> exportEntityEnvelope({
    required SyncEntityType entityType,
    required String entityId,
    required String userId,
    required String deviceId,
  }) async {
    final metadata = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo('${entityType.name}::$entityId')
        .findFirst();
    if (metadata?.isDeleted ?? false) {
      return SyncEntityEnvelope(
        entityType: entityType,
        entityId: entityId,
        userId: userId,
        data: null,
        isDeleted: true,
        lastModifiedAt: metadata!.lastModifiedAt,
        lastModifiedByDeviceId: metadata.lastModifiedByDeviceId ?? deviceId,
      );
    }

    final payload = await _readEntityPayload(entityType, entityId);
    if (payload == null) {
      return null;
    }
    return SyncEntityEnvelope(
      entityType: entityType,
      entityId: entityId,
      userId: userId,
      data: payload,
      lastModifiedAt: metadata?.lastModifiedAt ?? DateTime.now(),
      lastModifiedByDeviceId: metadata?.lastModifiedByDeviceId ?? deviceId,
    );
  }

  Future<SyncEntityEnvelope> _buildEnvelope({
    required SyncEntityType entityType,
    required String entityId,
    required String userId,
    required String deviceId,
    required Map<String, dynamic> payload,
    required DateTime fallbackModifiedAt,
  }) async {
    final metadata = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo('${entityType.name}::$entityId')
        .findFirst();
    return SyncEntityEnvelope(
      entityType: entityType,
      entityId: entityId,
      userId: userId,
      data: payload,
      lastModifiedAt: metadata?.lastModifiedAt ?? fallbackModifiedAt,
      lastModifiedByDeviceId: metadata?.lastModifiedByDeviceId ?? deviceId,
      isDeleted: metadata?.isDeleted ?? false,
    );
  }

  Future<SyncApplyReport> applyRemoteChanges(
    List<SyncEntityEnvelope> envelopes,
  ) async {
    if (envelopes.isEmpty) {
      return const SyncApplyReport();
    }
    var dedupedOccurrenceCount = 0;
    await _isar.writeTxn(() async {
      for (final envelope in envelopes) {
        await _applyEnvelopeInsideTxn(envelope);
      }
      dedupedOccurrenceCount = await _dedupeRoutineOccurrencesInsideTxn();
    });
    return SyncApplyReport(
      appliedCount: envelopes.length,
      tombstoneAppliedCount: envelopes.where((item) => item.isDeleted).length,
      dedupedOccurrenceCount: dedupedOccurrenceCount,
    );
  }

  Future<SyncApplyReport> replaceAllWithRemote(
    List<SyncEntityEnvelope> envelopes,
  ) async {
    var dedupedOccurrenceCount = 0;
    await _isar.writeTxn(() async {
      await _isar.tasks.clear();
      await _isar.timetableSlots.clear();
      await _isar.plannedSessions.clear();
      await _isar.learningGoals.clear();
      await _isar.goalMilestones.clear();
      await _isar.taskDependencys.clear();
      await _isar.routines.clear();
      await _isar.routineOccurrences.clear();
      await _isar.routineTemplates.clear();
      await _isar.routineGroups.clear();
      await _isar.knowledgeItems.clear();
      await _isar.notificationPreferences.clear();
      await _isar.syncEntityMetadatas.clear();

      for (final envelope in envelopes) {
        await _applyEnvelopeInsideTxn(envelope);
      }
      dedupedOccurrenceCount = await _dedupeRoutineOccurrencesInsideTxn();
    });
    return SyncApplyReport(
      appliedCount: envelopes.length,
      tombstoneAppliedCount: envelopes.where((item) => item.isDeleted).length,
      dedupedOccurrenceCount: dedupedOccurrenceCount,
    );
  }

  Future<int> _dedupeRoutineOccurrencesInsideTxn() async {
    final all = await _isar.routineOccurrences.where().findAll();
    final keepByLogicalKey = <String, RoutineOccurrence>{};
    final removeIds = <int>[];

    for (final occurrence in all) {
      final key = occurrence.isRecoveryInstance
          ? 'recovery:${occurrence.recoveredFromOccurrenceId ?? occurrence.id}'
          : 'standard:${occurrence.occurrenceKey}';
      final existing = keepByLogicalKey[key];
      if (existing == null) {
        keepByLogicalKey[key] = occurrence;
        continue;
      }
      final winner = _chooseOccurrenceMergeWinner(existing, occurrence);
      final loser = identical(winner, existing) ? occurrence : existing;
      keepByLogicalKey[key] = winner;
      removeIds.add(loser.isarId);
    }

    if (removeIds.isNotEmpty) {
      await _isar.routineOccurrences.deleteAll(removeIds);
    }
    return removeIds.length;
  }

  Future<void> _applyEnvelopeInsideTxn(SyncEntityEnvelope envelope) async {
    if (!envelope.isDeleted && envelope.data != null) {
      final decoded = codec.decodeEntity(envelope.entityType, envelope.data!);
      switch (envelope.entityType) {
        case SyncEntityType.task:
          await _isar.tasks.put(decoded as Task);
          break;
        case SyncEntityType.timetableSlot:
          await _isar.timetableSlots.put(decoded as TimetableSlot);
          break;
        case SyncEntityType.plannedSession:
          await _isar.plannedSessions.put(decoded as PlannedSession);
          break;
        case SyncEntityType.learningGoal:
          await _isar.learningGoals.put(decoded as LearningGoal);
          break;
        case SyncEntityType.goalMilestone:
          await _isar.goalMilestones.put(decoded as GoalMilestone);
          break;
        case SyncEntityType.taskDependency:
          await _isar.taskDependencys.put(decoded as TaskDependency);
          break;
        case SyncEntityType.routine:
          await _isar.routines.put(await _mergeRoutine(decoded as Routine));
          break;
        case SyncEntityType.routineOccurrence:
          await _isar.routineOccurrences.put(
            await _mergeRoutineOccurrence(decoded as RoutineOccurrence),
          );
          break;
        case SyncEntityType.routineTemplate:
          await _isar.routineTemplates.put(decoded as RoutineTemplate);
          break;
        case SyncEntityType.routineGroup:
          await _isar.routineGroups.put(
            await _mergeRoutineGroup(decoded as RoutineGroup),
          );
          break;
        case SyncEntityType.knowledgeItem:
          await _isar.knowledgeItems.put(decoded as KnowledgeItem);
          break;
        case SyncEntityType.notificationPreferences:
          await _isar.notificationPreferences.put(
            decoded as NotificationPreferences,
          );
          break;
      }
    } else {
      await _deleteEntityInsideTxn(envelope.entityType, envelope.entityId);
    }

    final syncKey = envelope.syncKey;
    final existingMetadata = await _isar.syncEntityMetadatas
        .filter()
        .syncKeyEqualTo(syncKey)
        .findFirst();
    final metadata =
        existingMetadata ??
        SyncEntityMetadata(
          syncKey: syncKey,
          entityType: envelope.entityType,
          entityId: envelope.entityId,
          lastModifiedAt: envelope.lastModifiedAt,
        );
    metadata.lastModifiedAt = envelope.lastModifiedAt;
    metadata.lastSyncedAt = DateTime.now();
    metadata.isDeleted = envelope.isDeleted;
    metadata.syncState = envelope.isDeleted
        ? SyncState.deleted
        : SyncState.synced;
    metadata.lastModifiedByDeviceId = envelope.lastModifiedByDeviceId;
    metadata.lastConflictSummary = null;
    metadata.lastError = null;
    await _isar.syncEntityMetadatas.put(metadata);
  }

  Future<Routine> _mergeRoutine(Routine remote) async {
    final existing = await _isar.routines
        .filter()
        .idEqualTo(remote.id)
        .findFirst();
    if (existing == null) {
      return remote;
    }
    if (existing.isArchived && !remote.isArchived) {
      final existingArchivedAt =
          existing.archivedAt ?? existing.updatedAt ?? existing.createdAt;
      final remoteUpdatedAt = remote.updatedAt ?? remote.createdAt;
      if (!remoteUpdatedAt.isAfter(existingArchivedAt)) {
        return remote.copyWith(
          isArchived: true,
          archivedAt: existing.archivedAt,
          updatedAt: existing.updatedAt,
        )..isarId = existing.isarId;
      }
    }
    return remote..isarId = existing.isarId;
  }

  Future<RoutineOccurrence> _mergeRoutineOccurrence(
    RoutineOccurrence remote,
  ) async {
    final existing = await _findEquivalentOccurrence(remote);
    if (existing == null) {
      return remote;
    }

    final merged = _chooseOccurrenceMergeWinner(existing, remote);
    return merged..isarId = existing.isarId;
  }

  Future<RoutineOccurrence?> _findEquivalentOccurrence(
    RoutineOccurrence remote,
  ) async {
    final byId = await _isar.routineOccurrences
        .filter()
        .idEqualTo(remote.id)
        .findFirst();
    if (byId != null) {
      return byId;
    }
    if (remote.isRecoveryInstance && remote.recoveredFromOccurrenceId != null) {
      return _isar.routineOccurrences
          .filter()
          .recoveredFromOccurrenceIdEqualTo(remote.recoveredFromOccurrenceId!)
          .findFirst();
    }
    return _isar.routineOccurrences
        .filter()
        .occurrenceKeyEqualTo(remote.occurrenceKey)
        .findFirst();
  }

  RoutineOccurrence _chooseOccurrenceMergeWinner(
    RoutineOccurrence local,
    RoutineOccurrence remote,
  ) {
    if (_isTerminal(local.status) && !_isTerminal(remote.status)) {
      return _mergeSchedulingFields(remote, local);
    }
    if (!_isTerminal(local.status) && _isTerminal(remote.status)) {
      return _mergeSchedulingFields(local, remote);
    }
    if (local.isManualOverride && !remote.isManualOverride) {
      return _mergeSchedulingFields(remote, local);
    }
    if (!local.isManualOverride && remote.isManualOverride) {
      return _mergeSchedulingFields(local, remote);
    }

    final localUpdated = local.updatedAt ?? local.createdAt;
    final remoteUpdated = remote.updatedAt ?? remote.createdAt;
    if (remoteUpdated.isAfter(localUpdated)) {
      return remote;
    }
    return local;
  }

  RoutineOccurrence _mergeSchedulingFields(
    RoutineOccurrence source,
    RoutineOccurrence protected,
  ) {
    return source.copyWith(
      id: protected.id,
      scheduledStart: protected.scheduledStart,
      clearScheduledStart: protected.scheduledStart == null,
      scheduledEnd: protected.scheduledEnd,
      clearScheduledEnd: protected.scheduledEnd == null,
      status: protected.status,
      completedAt: protected.completedAt,
      clearCompletedAt: protected.completedAt == null,
      skippedAt: protected.skippedAt,
      clearSkippedAt: protected.skippedAt == null,
      missedAt: protected.missedAt,
      clearMissedAt: protected.missedAt == null,
      notes: protected.notes,
      clearNotes: protected.notes == null,
      isManualOverride: protected.isManualOverride,
      updatedAt: _maxDate(
        source.updatedAt ?? source.createdAt,
        protected.updatedAt ?? protected.createdAt,
      ),
    );
  }

  bool _isTerminal(RoutineOccurrenceStatus status) {
    return status == RoutineOccurrenceStatus.completed ||
        status == RoutineOccurrenceStatus.skipped ||
        status == RoutineOccurrenceStatus.missed;
  }

  Future<RoutineGroup> _mergeRoutineGroup(RoutineGroup remote) async {
    final existing = await _isar.routineGroups
        .filter()
        .idEqualTo(remote.id)
        .findFirst();
    if (existing == null) {
      return remote;
    }
    final mergedRoutineIds = <String>{
      ...existing.routineIds,
      ...remote.routineIds,
    }.toList()..sort();
    return remote.copyWith(routineIds: mergedRoutineIds)
      ..isarId = existing.isarId;
  }

  DateTime _maxDate(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Future<Map<String, dynamic>?> _readEntityPayload(
    SyncEntityType entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case SyncEntityType.task:
        final task = await _isar.tasks.filter().idEqualTo(entityId).findFirst();
        return task == null ? null : codec.encodeEntity(entityType, task);
      case SyncEntityType.timetableSlot:
        final slot = await _isar.timetableSlots
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return slot == null ? null : codec.encodeEntity(entityType, slot);
      case SyncEntityType.plannedSession:
        final session = await _isar.plannedSessions
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return session == null ? null : codec.encodeEntity(entityType, session);
      case SyncEntityType.learningGoal:
        final goal = await _isar.learningGoals
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return goal == null ? null : codec.encodeEntity(entityType, goal);
      case SyncEntityType.goalMilestone:
        final milestone = await _isar.goalMilestones
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return milestone == null
            ? null
            : codec.encodeEntity(entityType, milestone);
      case SyncEntityType.taskDependency:
        final dependency = await _isar.taskDependencys
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return dependency == null
            ? null
            : codec.encodeEntity(entityType, dependency);
      case SyncEntityType.routine:
        final routine = await _isar.routines
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return routine == null ? null : codec.encodeEntity(entityType, routine);
      case SyncEntityType.routineOccurrence:
        final occurrence = await _isar.routineOccurrences
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return occurrence == null
            ? null
            : codec.encodeEntity(entityType, occurrence);
      case SyncEntityType.routineTemplate:
        final template = await _isar.routineTemplates
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return template == null
            ? null
            : codec.encodeEntity(entityType, template);
      case SyncEntityType.routineGroup:
        final group = await _isar.routineGroups
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return group == null ? null : codec.encodeEntity(entityType, group);
      case SyncEntityType.knowledgeItem:
        final item = await _isar.knowledgeItems
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        return item == null ? null : codec.encodeEntity(entityType, item);
      case SyncEntityType.notificationPreferences:
        final preferences = await _isar.notificationPreferences.get(1);
        return preferences == null
            ? null
            : codec.encodeEntity(entityType, preferences);
    }
  }

  Future<void> _deleteEntityInsideTxn(
    SyncEntityType entityType,
    String entityId,
  ) async {
    switch (entityType) {
      case SyncEntityType.task:
        final task = await _isar.tasks.filter().idEqualTo(entityId).findFirst();
        if (task != null) {
          await _isar.tasks.delete(task.isarId);
        }
        break;
      case SyncEntityType.timetableSlot:
        final slot = await _isar.timetableSlots
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (slot != null) {
          await _isar.timetableSlots.delete(slot.isarId);
        }
        break;
      case SyncEntityType.plannedSession:
        final session = await _isar.plannedSessions
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (session != null) {
          await _isar.plannedSessions.delete(session.isarId);
        }
        break;
      case SyncEntityType.learningGoal:
        final goal = await _isar.learningGoals
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (goal != null) {
          await _isar.learningGoals.delete(goal.isarId);
        }
        break;
      case SyncEntityType.goalMilestone:
        final milestone = await _isar.goalMilestones
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (milestone != null) {
          await _isar.goalMilestones.delete(milestone.isarId);
        }
        break;
      case SyncEntityType.taskDependency:
        final dependency = await _isar.taskDependencys
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (dependency != null) {
          await _isar.taskDependencys.delete(dependency.isarId);
        }
        break;
      case SyncEntityType.routine:
        final routine = await _isar.routines
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (routine != null) {
          await _isar.routines.delete(routine.isarId);
        }
        break;
      case SyncEntityType.routineOccurrence:
        final occurrence = await _isar.routineOccurrences
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (occurrence != null) {
          await _isar.routineOccurrences.delete(occurrence.isarId);
        }
        break;
      case SyncEntityType.routineTemplate:
        final template = await _isar.routineTemplates
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (template != null) {
          await _isar.routineTemplates.delete(template.isarId);
        }
        break;
      case SyncEntityType.routineGroup:
        final group = await _isar.routineGroups
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (group != null) {
          await _isar.routineGroups.delete(group.isarId);
        }
        break;
      case SyncEntityType.knowledgeItem:
        final item = await _isar.knowledgeItems
            .filter()
            .idEqualTo(entityId)
            .findFirst();
        if (item != null) {
          await _isar.knowledgeItems.delete(item.isarId);
        }
        break;
      case SyncEntityType.notificationPreferences:
        await _isar.notificationPreferences.delete(1);
        break;
    }
  }
}
