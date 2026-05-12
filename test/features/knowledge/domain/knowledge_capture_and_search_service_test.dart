import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/knowledge/domain/knowledge_capture_service.dart';
import 'package:study_flow/features/knowledge/domain/knowledge_search_service.dart';
import 'package:study_flow/features/knowledge/models/knowledge_item.dart';

void main() {
  group('KnowledgeCaptureService', () {
    const captureService = KnowledgeCaptureService();

    test('buildFocusSessionNote links focus session and task context', () {
      final note = captureService.buildFocusSessionNote(
        id: 'k1',
        title: 'SAR paper notes',
        content: 'Need clearer methodology diagram.',
        createdAt: DateTime(2026, 5, 12),
        focusSessionId: 'session-1',
        taskId: 'task-1',
      );

      expect(note.status, KnowledgeStatus.active);
      expect(note.tags, contains('focus'));
      expect(
        note.links.map((link) => link.entityType),
        containsAll([LinkedEntityType.focusSession, LinkedEntityType.task]),
      );
    });

    test('buildFollowUpTask turns note into actionable draft', () {
      final item = KnowledgeItem(
        id: 'k1',
        title: 'Redraw figure',
        content: 'Architecture figure still feels muddy.',
        type: KnowledgeItemType.note,
        createdAt: DateTime(2026, 5, 12),
      );

      final draft = captureService.buildFollowUpTask(item);
      expect(draft.title, 'Redraw figure');
      expect(draft.description, contains('Architecture figure'));
      expect(draft.description, contains('k1'));
    });
  });

  group('KnowledgeSearchService', () {
    const searchService = KnowledgeSearchService();

    test('filters by text, tag, due review, and stale links', () {
      final now = DateTime(2026, 5, 12, 12);
      final items = [
        KnowledgeItem(
          id: '1',
          title: 'DSA Arrays',
          content: 'Sliding window patterns',
          type: KnowledgeItemType.note,
          status: KnowledgeStatus.reviewing,
          createdAt: DateTime(2026, 5, 1),
          dueReviewAt: now.subtract(const Duration(hours: 1)),
          tags: const ['dsa'],
          links: [
            EntityLink(
              entityId: 'goal-1',
              entityType: LinkedEntityType.goal,
              isStale: true,
            ),
          ],
        ),
        KnowledgeItem(
          id: '2',
          title: 'Workout guide',
          type: KnowledgeItemType.resource,
          status: KnowledgeStatus.active,
          createdAt: DateTime(2026, 5, 1),
          tags: const ['fitness'],
        ),
      ];

      final filtered = searchService.filter(
        items,
        query: const KnowledgeSearchQuery(
          text: 'arrays',
          tag: 'dsa',
          onlyDueReview: true,
          onlyStale: true,
        ),
        now: now,
      );

      expect(filtered.map((item) => item.id).toList(), ['1']);
    });
  });
}
