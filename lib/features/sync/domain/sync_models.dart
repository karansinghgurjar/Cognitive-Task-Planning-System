import 'dart:convert';

enum SyncEntityType {
  task,
  timetableSlot,
  plannedSession,
  learningGoal,
  goalMilestone,
  taskDependency,
  notificationPreferences,
}

enum SyncDirection { push, pull }

enum SyncOperationType { create, update, delete }

enum SyncOperationStatus { pending, processing, failed, completed }

enum SyncState { localOnly, pendingPush, synced, conflict, failed, deleted }

enum SyncConflictResolution { useLocal, useRemote }

enum BootstrapChoice { uploadLocal, downloadRemote, merge }

enum BootstrapRequirement { none, uploadLocal, downloadRemote, choose }

class SyncAccountSummary {
  const SyncAccountSummary({
    required this.isConfigured,
    required this.isSignedIn,
    this.userId,
    this.email,
  });

  final bool isConfigured;
  final bool isSignedIn;
  final String? userId;
  final String? email;
}

class SyncEntityEnvelope {
  const SyncEntityEnvelope({
    required this.entityType,
    required this.entityId,
    required this.userId,
    required this.lastModifiedAt,
    required this.lastModifiedByDeviceId,
    this.data,
    this.isDeleted = false,
  });

  final SyncEntityType entityType;
  final String entityId;
  final String userId;
  final Map<String, dynamic>? data;
  final bool isDeleted;
  final DateTime lastModifiedAt;
  final String lastModifiedByDeviceId;

  String get syncKey => '${entityType.name}::$entityId';

  String get payloadJson => data == null ? '{}' : jsonEncode(data);
}

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.status,
    required this.createdAt,
    required this.lastModifiedAt,
    this.payloadJson,
    this.retryCount = 0,
    this.lastError,
    this.lastAttemptAt,
  });

  final String operationId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final SyncOperationStatus status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final String? payloadJson;
  final int retryCount;
  final String? lastError;
  final DateTime? lastAttemptAt;

  String get syncKey => '${entityType.name}::$entityId';
}

class SyncConflict {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localModifiedAt,
    required this.remoteModifiedAt,
    required this.resolution,
    required this.description,
    this.localPayload,
    this.remotePayload,
  });

  final SyncEntityType entityType;
  final String entityId;
  final DateTime localModifiedAt;
  final DateTime remoteModifiedAt;
  final SyncConflictResolution resolution;
  final String description;
  final Map<String, dynamic>? localPayload;
  final Map<String, dynamic>? remotePayload;
}

class SyncResult {
  const SyncResult({
    required this.startedAt,
    required this.finishedAt,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.failedCount = 0,
    this.conflicts = const [],
    this.errors = const [],
    this.wasOffline = false,
    this.requiredBootstrap = false,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final int pushedCount;
  final int pulledCount;
  final int failedCount;
  final List<SyncConflict> conflicts;
  final List<String> errors;
  final bool wasOffline;
  final bool requiredBootstrap;

  bool get success => failedCount == 0 && errors.isEmpty;
}

class SyncStatusSummary {
  const SyncStatusSummary({
    required this.isConfigured,
    required this.isSignedIn,
    required this.isSyncEnabled,
    required this.isOnline,
    required this.pendingCount,
    required this.failedCount,
    required this.conflictCount,
    required this.autoSyncEnabled,
    this.lastSyncAt,
    this.lastSyncError,
    this.email,
    this.deviceId,
  });

  final bool isConfigured;
  final bool isSignedIn;
  final bool isSyncEnabled;
  final bool isOnline;
  final int pendingCount;
  final int failedCount;
  final int conflictCount;
  final bool autoSyncEnabled;
  final DateTime? lastSyncAt;
  final String? lastSyncError;
  final String? email;
  final String? deviceId;

  SyncState get state {
    if (!isConfigured || !isSyncEnabled || !isSignedIn) {
      return SyncState.localOnly;
    }
    if (!isOnline) {
      return pendingCount > 0 ? SyncState.pendingPush : SyncState.localOnly;
    }
    if (conflictCount > 0) {
      return SyncState.conflict;
    }
    if (failedCount > 0 || lastSyncError != null) {
      return SyncState.failed;
    }
    if (pendingCount > 0) {
      return SyncState.pendingPush;
    }
    return SyncState.synced;
  }

  String get statusLabel {
    switch (state) {
      case SyncState.localOnly:
        return isOnline ? 'Local only' : 'Offline';
      case SyncState.pendingPush:
        return isOnline ? 'Pending sync' : 'Offline with pending changes';
      case SyncState.synced:
        return 'Synced';
      case SyncState.conflict:
        return 'Conflict detected';
      case SyncState.failed:
        return 'Sync failed';
      case SyncState.deleted:
        return 'Deleted';
    }
  }
}

class BootstrapPlan {
  const BootstrapPlan({
    required this.requirement,
    required this.localEntityCount,
    required this.remoteEntityCount,
    this.message,
  });

  final BootstrapRequirement requirement;
  final int localEntityCount;
  final int remoteEntityCount;
  final String? message;

  bool get requiresChoice => requirement == BootstrapRequirement.choose;
}

