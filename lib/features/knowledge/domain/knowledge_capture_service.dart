import '../models/knowledge_item.dart';
import 'revision_planning_service.dart';

class FollowUpTaskDraft {
  const FollowUpTaskDraft({required this.title, required this.description});

  final String title;
  final String description;
}

class KnowledgeCaptureService {
  const KnowledgeCaptureService({
    this.revisionPlanningService = const RevisionPlanningService(),
  });

  final RevisionPlanningService revisionPlanningService;

  KnowledgeItem buildFocusSessionNote({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    required String focusSessionId,
    String? taskId,
  }) {
    return KnowledgeItem(
      id: id,
      title: title,
      content: content,
      type: KnowledgeItemType.note,
      status: KnowledgeStatus.active,
      createdAt: createdAt,
      tags: const ['focus'],
      links: [
        EntityLink(
          entityId: focusSessionId,
          entityType: LinkedEntityType.focusSession,
          relationLabel: 'Captured during focus session',
        ),
        if (taskId != null)
          EntityLink(
            entityId: taskId,
            entityType: LinkedEntityType.task,
            relationLabel: 'Linked task',
          ),
      ],
    );
  }

  FollowUpTaskDraft buildFollowUpTask(KnowledgeItem item) {
    return FollowUpTaskDraft(
      title: item.title.trim().isEmpty
          ? 'Follow up on knowledge item'
          : item.title.trim(),
      description: [
        if (item.content?.trim().isNotEmpty == true) item.content!.trim(),
        'Created from knowledge item ${item.id}.',
      ].join('\n\n'),
    );
  }

  RevisionTaskDraft? buildRevisionDraftForItem(KnowledgeItem item) {
    return revisionPlanningService.buildRevisionTaskDraft([
      item,
    ], groupLabel: item.title);
  }
}
