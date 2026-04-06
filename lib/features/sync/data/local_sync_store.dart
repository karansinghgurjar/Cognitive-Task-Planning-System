// ignore_for_file: annotate_overrides

import 'package:isar/isar.dart';

import '../../goals/models/goal_milestone.dart';
import '../../goals/models/learning_goal.dart';
import '../../goals/models/task_dependency.dart';
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
    final settings = await _isar.notificationPreferences.count();
    return tasks +
        timetableSlots +
        sessions +
        goals +
        milestones +
        dependencies +
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

  Future<void> applyRemoteChanges(List<SyncEntityEnvelope> envelopes) async {
    if (envelopes.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      for (final envelope in envelopes) {
        await _applyEnvelopeInsideTxn(envelope);
      }
    });
  }

  Future<void> replaceAllWithRemote(List<SyncEntityEnvelope> envelopes) async {
    await _isar.writeTxn(() async {
      await _isar.tasks.clear();
      await _isar.timetableSlots.clear();
      await _isar.plannedSessions.clear();
      await _isar.learningGoals.clear();
      await _isar.goalMilestones.clear();
      await _isar.taskDependencys.clear();
      await _isar.notificationPreferences.clear();
      await _isar.syncEntityMetadatas.clear();

      for (final envelope in envelopes) {
        await _applyEnvelopeInsideTxn(envelope);
      }
    });
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
      case SyncEntityType.notificationPreferences:
        await _isar.notificationPreferences.delete(1);
        break;
    }
  }
}
