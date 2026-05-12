import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/knowledge/domain/revision_planning_service.dart';
import 'package:study_flow/features/knowledge/models/knowledge_item.dart';

void main() {
  group('RevisionPlanningService', () {
    const service = RevisionPlanningService();

    test('review difficulty schedules deterministic next review dates', () {
      final base = DateTime(2026, 5, 12, 9);
      expect(
        service.nextReviewAt(ReviewDifficulty.hard, from: base),
        base.add(const Duration(days: 1)),
      );
      expect(
        service.nextReviewAt(ReviewDifficulty.normal, from: base),
        base.add(const Duration(days: 3)),
      );
      expect(
        service.nextReviewAt(ReviewDifficulty.easy, from: base),
        base.add(const Duration(days: 7)),
      );
    });

    test('recordReview updates status counters and interval', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'OS concepts',
        type: KnowledgeItemType.note,
        createdAt: DateTime(2026, 5, 1),
      );
      final reviewedAt = DateTime(2026, 5, 12, 9);

      final updated = service.recordReview(
        item,
        ReviewDifficulty.normal,
        reviewedAt: reviewedAt,
      );

      expect(updated.status, KnowledgeStatus.reviewing);
      expect(updated.reviewCount, 1);
      expect(updated.lastReviewedAt, reviewedAt);
      expect(updated.dueReviewAt, reviewedAt.add(const Duration(days: 3)));
      expect(updated.reviewIntervalDays, 3);
    });

    test('dueItems returns only due entries ordered by due date', () {
      final now = DateTime(2026, 5, 12, 12);
      final items = [
        KnowledgeItem(
          id: 'late',
          title: 'Late',
          type: KnowledgeItemType.note,
          createdAt: DateTime(2026, 5, 1),
          dueReviewAt: now.subtract(const Duration(days: 2)),
        ),
        KnowledgeItem(
          id: 'soon',
          title: 'Soon',
          type: KnowledgeItemType.note,
          createdAt: DateTime(2026, 5, 1),
          dueReviewAt: now.subtract(const Duration(hours: 1)),
        ),
        KnowledgeItem(
          id: 'future',
          title: 'Future',
          type: KnowledgeItemType.note,
          createdAt: DateTime(2026, 5, 1),
          dueReviewAt: now.add(const Duration(days: 1)),
        ),
      ];

      final due = service.dueItems(items, now: now);
      expect(due.map((item) => item.id).toList(), ['late', 'soon']);
    });
  });
}
