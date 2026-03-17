import '../models/sync_entity_metadata.dart';
import 'sync_models.dart';

class ConflictResolutionService {
  const ConflictResolutionService();

  SyncConflict? detectConflict({
    required SyncEntityEnvelope remoteEnvelope,
    required SyncEntityMetadata? localMetadata,
  }) {
    if (localMetadata == null || localMetadata.lastSyncedAt == null) {
      return null;
    }

    final lastSyncedAt = localMetadata.lastSyncedAt!;
    final localChangedSinceSync =
        localMetadata.lastModifiedAt.isAfter(lastSyncedAt) ||
        (localMetadata.isDeleted && localMetadata.lastModifiedAt.isAtSameMomentAs(lastSyncedAt));
    final remoteChangedSinceSync = remoteEnvelope.lastModifiedAt.isAfter(lastSyncedAt);

    if (!localChangedSinceSync || !remoteChangedSinceSync) {
      return null;
    }

    final resolution = chooseResolution(
      localModifiedAt: localMetadata.lastModifiedAt,
      remoteModifiedAt: remoteEnvelope.lastModifiedAt,
    );

    return SyncConflict(
      entityType: remoteEnvelope.entityType,
      entityId: remoteEnvelope.entityId,
      localModifiedAt: localMetadata.lastModifiedAt,
      remoteModifiedAt: remoteEnvelope.lastModifiedAt,
      resolution: resolution,
      description:
          'Local and remote versions changed after the last sync. ${resolution == SyncConflictResolution.useLocal ? 'Local' : 'Remote'} version won by lastModifiedAt.',
      remotePayload: remoteEnvelope.data,
    );
  }

  SyncConflictResolution chooseResolution({
    required DateTime localModifiedAt,
    required DateTime remoteModifiedAt,
  }) {
    if (localModifiedAt.isAfter(remoteModifiedAt)) {
      return SyncConflictResolution.useLocal;
    }
    return SyncConflictResolution.useRemote;
  }
}

