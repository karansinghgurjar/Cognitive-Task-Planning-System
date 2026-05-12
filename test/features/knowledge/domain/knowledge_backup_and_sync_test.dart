import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/database/database_version.dart';
import 'package:study_flow/features/backup/data/backup_serialization.dart';
import 'package:study_flow/features/backup/domain/backup_models.dart';
import 'package:study_flow/features/knowledge/models/knowledge_item.dart';
import 'package:study_flow/features/settings/models/notification_preferences.dart';
import 'package:study_flow/features/sync/data/sync_entity_codec.dart';
import 'package:study_flow/features/sync/domain/sync_models.dart';

void main() {
  group('Knowledge backup and sync compatibility', () {
    const serialization = BackupSerialization();
    const codec = SyncEntityCodec();

    AppBackupBundle buildBundle(KnowledgeItem item) {
      return AppBackupBundle(
        metadata: BackupMetadata(
          appVersion: '1.0.0',
          schemaVersion: AppDatabaseVersion.schemaVersion,
          backupFormatVersion: AppDatabaseVersion.backupFormatVersion,
          createdAt: DateTime(2026, 5, 12),
          platform: 'windows',
          entityCounts: const {'knowledgeItems': 1, 'settings': 1},
        ),
        tasks: const [],
        timetableSlots: const [],
        plannedSessions: const [],
        goals: const [],
        milestones: const [],
        dependencies: const [],
        entityNotes: const [],
        entityResources: const [],
        knowledgeItems: [item],
        preferences: NotificationPreferences(),
      );
    }

    test('backup round-trips knowledge items and preserves stale links', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'Paper notes',
        content: 'Open questions in related work section.',
        type: KnowledgeItemType.researchPaper,
        status: KnowledgeStatus.reviewing,
        priority: KnowledgePriority.high,
        createdAt: DateTime(2026, 5, 10),
        dueReviewAt: DateTime(2026, 5, 13),
        tags: const ['research'],
        links: [
          EntityLink(
            entityId: 'goal-1',
            entityType: LinkedEntityType.goal,
            isStale: true,
          ),
        ],
      );

      final json = serialization.encodeBundle(buildBundle(item));
      final decoded = serialization.decodeBundle(json);

      expect(decoded.isValid, isTrue);
      expect(decoded.bundle!.knowledgeItems, hasLength(1));
      expect(
        decoded.bundle!.knowledgeItems.single.links.single.isStale,
        isTrue,
      );
      expect(decoded.bundle!.knowledgeItems.single.tags, ['research']);
    });

    test('sync codec round-trips knowledge item payload deterministically', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'Revision card',
        content: 'Binary lifting notes',
        type: KnowledgeItemType.note,
        status: KnowledgeStatus.active,
        priority: KnowledgePriority.normal,
        createdAt: DateTime(2026, 5, 12),
        links: [
          EntityLink(
            entityId: 'routine-1',
            entityType: LinkedEntityType.routine,
            relationLabel: 'Weekly revision',
          ),
        ],
      );

      final json = codec.encodeEntity(SyncEntityType.knowledgeItem, item);
      final decoded =
          codec.decodeEntity(SyncEntityType.knowledgeItem, json)
              as KnowledgeItem;

      expect(decoded.id, item.id);
      expect(decoded.title, item.title);
      expect(decoded.links.single.entityType, LinkedEntityType.routine);
      expect(decoded.links.single.relationLabel, 'Weekly revision');
    });
  });
}
