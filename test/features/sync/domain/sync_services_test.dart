import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/sync/domain/bootstrap_sync_service.dart';
import 'package:study_flow/features/sync/domain/conflict_resolution_service.dart';
import 'package:study_flow/features/sync/domain/sync_models.dart';
import 'package:study_flow/features/sync/models/sync_entity_metadata.dart';

void main() {
  group('ConflictResolutionService', () {
    const service = ConflictResolutionService();

    test('lastModified wins when remote is newer', () {
      final conflict = service.detectConflict(
        remoteEnvelope: SyncEntityEnvelope(
          entityType: SyncEntityType.task,
          entityId: 'task-1',
          userId: 'user-1',
          data: const {'id': 'task-1'},
          lastModifiedAt: DateTime(2026, 3, 16, 12, 30),
          lastModifiedByDeviceId: 'remote-device',
        ),
        localMetadata: SyncEntityMetadata(
          syncKey: 'task::task-1',
          entityType: SyncEntityType.task,
          entityId: 'task-1',
          lastModifiedAt: DateTime(2026, 3, 16, 12),
          lastSyncedAt: DateTime(2026, 3, 16, 11),
        ),
      );

      expect(conflict, isNotNull);
      expect(conflict?.resolution, SyncConflictResolution.useRemote);
    });

    test('lastModified wins when local is newer', () {
      final conflict = service.detectConflict(
        remoteEnvelope: SyncEntityEnvelope(
          entityType: SyncEntityType.task,
          entityId: 'task-1',
          userId: 'user-1',
          data: const {'id': 'task-1'},
          lastModifiedAt: DateTime(2026, 3, 16, 12),
          lastModifiedByDeviceId: 'remote-device',
        ),
        localMetadata: SyncEntityMetadata(
          syncKey: 'task::task-1',
          entityType: SyncEntityType.task,
          entityId: 'task-1',
          lastModifiedAt: DateTime(2026, 3, 16, 12, 30),
          lastSyncedAt: DateTime(2026, 3, 16, 11),
        ),
      );

      expect(conflict?.resolution, SyncConflictResolution.useLocal);
    });
  });

  group('BootstrapSyncService', () {
    const service = BootstrapSyncService();

    test(
      'requires explicit choice when local and remote both contain data',
      () {
        final plan = service.evaluate(
          localEntityCount: 4,
          remoteEntityCount: 7,
          hasPreviousSync: false,
        );

        expect(plan.requirement, BootstrapRequirement.choose);
      },
    );

    test('selects remote download when local is empty', () {
      final plan = service.evaluate(
        localEntityCount: 0,
        remoteEntityCount: 7,
        hasPreviousSync: false,
      );

      expect(plan.requirement, BootstrapRequirement.downloadRemote);
    });
  });

  group('SyncStatusSummary', () {
    test('reports pending local changes while offline', () {
      const summary = SyncStatusSummary(
        isConfigured: true,
        isSignedIn: true,
        isSyncEnabled: true,
        isOnline: false,
        pendingCount: 3,
        failedCount: 0,
        conflictCount: 0,
        autoSyncEnabled: true,
      );

      expect(summary.state, SyncState.pendingPush);
      expect(summary.statusLabel, 'Offline with pending changes');
    });

    test('falls back to local-only when sync backend is unavailable', () {
      const summary = SyncStatusSummary(
        isConfigured: false,
        isSignedIn: false,
        isSyncEnabled: true,
        isOnline: true,
        pendingCount: 2,
        failedCount: 0,
        conflictCount: 0,
        autoSyncEnabled: true,
      );

      expect(summary.state, SyncState.localOnly);
      expect(summary.statusLabel, 'Local only');
    });
  });
}
