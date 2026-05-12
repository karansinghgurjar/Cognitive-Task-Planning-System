import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/knowledge/domain/knowledge_link_service.dart';
import 'package:study_flow/features/knowledge/models/knowledge_item.dart';

void main() {
  group('KnowledgeItem and KnowledgeLinkService', () {
    const service = KnowledgeLinkService();

    test('copyWith preserves fields and allows lifecycle updates', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'Compiler notes',
        content: 'SSA and optimization passes',
        type: KnowledgeItemType.note,
        status: KnowledgeStatus.inbox,
        priority: KnowledgePriority.normal,
        createdAt: DateTime(2026, 5, 1),
        tags: const ['compiler'],
      );

      final updated = item.copyWith(
        status: KnowledgeStatus.active,
        priority: KnowledgePriority.high,
        dueReviewAt: DateTime(2026, 5, 3),
      );

      expect(updated.status, KnowledgeStatus.active);
      expect(updated.priority, KnowledgePriority.high);
      expect(updated.dueReviewAt, DateTime(2026, 5, 3));
      expect(updated.tags, ['compiler']);
      expect(updated.id, item.id);
    });

    test('link and unlink item keep links explicit and stable', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'DSA revision',
        type: KnowledgeItemType.note,
        createdAt: DateTime(2026, 5, 1),
      );

      final linked = service.linkItem(
        item,
        EntityLink(
          entityId: 'goal-1',
          entityType: LinkedEntityType.goal,
          relationLabel: 'Interview prep',
        ),
      );

      expect(linked.links, hasLength(1));
      expect(linked.links.single.entityId, 'goal-1');

      final unlinked = service.unlinkItem(
        linked,
        entityId: 'goal-1',
        entityType: LinkedEntityType.goal,
      );

      expect(unlinked.links, isEmpty);
    });

    test('reconcileStaleLinks keeps item and marks missing links stale', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'Thesis paper',
        type: KnowledgeItemType.researchPaper,
        createdAt: DateTime(2026, 5, 1),
        links: [
          EntityLink(entityId: 'goal-1', entityType: LinkedEntityType.goal),
          EntityLink(entityId: 'task-1', entityType: LinkedEntityType.task),
        ],
      );

      final reconciled = service.reconcileStaleLinks(
        item,
        entityExists: (type, id) =>
            type == LinkedEntityType.goal && id == 'goal-1',
      );

      expect(reconciled.links.first.isStale, isFalse);
      expect(reconciled.links.last.isStale, isTrue);
      expect(reconciled.hasStaleLinks, isTrue);
    });
  });
}
