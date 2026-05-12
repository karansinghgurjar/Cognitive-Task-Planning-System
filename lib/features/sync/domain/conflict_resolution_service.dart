import '../models/sync_entity_metadata.dart';
import 'sync_models.dart';

class ConflictResolutionService {
  const ConflictResolutionService();

  SyncConflict? detectConflict({
    required SyncEntityEnvelope remoteEnvelope,
    required SyncEntityMetadata? localMetadata,
  }) {
    if (localMetadata == null) {
      return null;
    }

    if (localMetadata.isDeleted && !remoteEnvelope.isDeleted) {
      return SyncConflict(
        entityType: remoteEnvelope.entityType,
        entityId: remoteEnvelope.entityId,
        localModifiedAt: localMetadata.lastModifiedAt,
        remoteModifiedAt: remoteEnvelope.lastModifiedAt,
        resolution: _tombstoneResolution(
          tombstoneModifiedAt: localMetadata.lastModifiedAt,
          editModifiedAt: remoteEnvelope.lastModifiedAt,
          tombstoneIsLocal: true,
        ),
        description:
            'Local delete and remote edit both exist. The newer change wins, with delete preserved as a tombstone when it wins.',
        remotePayload: remoteEnvelope.data,
      );
    }

    if (remoteEnvelope.isDeleted && !localMetadata.isDeleted) {
      return SyncConflict(
        entityType: remoteEnvelope.entityType,
        entityId: remoteEnvelope.entityId,
        localModifiedAt: localMetadata.lastModifiedAt,
        remoteModifiedAt: remoteEnvelope.lastModifiedAt,
        resolution: _tombstoneResolution(
          tombstoneModifiedAt: remoteEnvelope.lastModifiedAt,
          editModifiedAt: localMetadata.lastModifiedAt,
          tombstoneIsLocal: false,
        ),
        description:
            'Remote delete and local edit both exist. The newer change wins, with delete preserved as a tombstone when it wins.',
        remotePayload: remoteEnvelope.data,
      );
    }

    if (localMetadata.lastSyncedAt == null) {
      return null;
    }

    final lastSyncedAt = localMetadata.lastSyncedAt!;
    final localChangedSinceSync =
        localMetadata.lastModifiedAt.isAfter(lastSyncedAt) ||
        (localMetadata.isDeleted &&
            localMetadata.lastModifiedAt.isAtSameMomentAs(lastSyncedAt));
    final remoteChangedSinceSync = remoteEnvelope.lastModifiedAt.isAfter(
      lastSyncedAt,
    );

    if (!localChangedSinceSync || !remoteChangedSinceSync) {
      return null;
    }

    final resolution = chooseResolution(
      entityType: remoteEnvelope.entityType,
      localModifiedAt: localMetadata.lastModifiedAt,
      remoteModifiedAt: remoteEnvelope.lastModifiedAt,
      remotePayload: remoteEnvelope.data,
    );

    return SyncConflict(
      entityType: remoteEnvelope.entityType,
      entityId: remoteEnvelope.entityId,
      localModifiedAt: localMetadata.lastModifiedAt,
      remoteModifiedAt: remoteEnvelope.lastModifiedAt,
      resolution: resolution,
      description: _descriptionFor(remoteEnvelope.entityType, resolution),
      remotePayload: remoteEnvelope.data,
    );
  }

  SyncConflictResolution chooseResolution({
    SyncEntityType? entityType,
    required DateTime localModifiedAt,
    required DateTime remoteModifiedAt,
    Map<String, dynamic>? remotePayload,
  }) {
    if (entityType == SyncEntityType.routineOccurrence &&
        remotePayload != null) {
      final remoteStatus = remotePayload['status'] as String?;
      final remoteManual = remotePayload['isManualOverride'] as bool? ?? false;
      if (_isTerminalStatus(remoteStatus) || remoteManual) {
        return SyncConflictResolution.useRemote;
      }
    }
    if (localModifiedAt.isAfter(remoteModifiedAt)) {
      return SyncConflictResolution.useLocal;
    }
    return SyncConflictResolution.useRemote;
  }

  SyncConflictResolution _tombstoneResolution({
    required DateTime tombstoneModifiedAt,
    required DateTime editModifiedAt,
    required bool tombstoneIsLocal,
  }) {
    if (tombstoneModifiedAt.isAfter(editModifiedAt) ||
        tombstoneModifiedAt.isAtSameMomentAs(editModifiedAt)) {
      return tombstoneIsLocal
          ? SyncConflictResolution.useLocal
          : SyncConflictResolution.useRemote;
    }
    return tombstoneIsLocal
        ? SyncConflictResolution.useRemote
        : SyncConflictResolution.useLocal;
  }

  bool _isTerminalStatus(String? status) {
    return status == 'completed' || status == 'skipped' || status == 'missed';
  }

  String _descriptionFor(
    SyncEntityType entityType,
    SyncConflictResolution resolution,
  ) {
    final winner = resolution == SyncConflictResolution.useLocal
        ? 'Local'
        : 'Remote';
    if (entityType == SyncEntityType.routineOccurrence) {
      return '$winner version won with routine occurrence safeguards for terminal states and manual overrides.';
    }
    if (entityType == SyncEntityType.routineGroup) {
      return '$winner version won for display fields; routine membership is merged safely when remote changes are applied.';
    }
    return '$winner version won by deterministic merge policy.';
  }
}
