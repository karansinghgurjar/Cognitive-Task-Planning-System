import '../models/knowledge_item.dart';

class KnowledgeLinkService {
  const KnowledgeLinkService();

  KnowledgeItem linkItem(KnowledgeItem item, EntityLink link) {
    final nextLinks = [...item.links];
    final existingIndex = nextLinks.indexWhere(
      (existing) =>
          existing.entityId == link.entityId &&
          existing.entityType == link.entityType,
    );
    if (existingIndex >= 0) {
      nextLinks[existingIndex] = link;
    } else {
      nextLinks.add(link);
    }
    return item.copyWith(links: nextLinks, updatedAt: DateTime.now());
  }

  KnowledgeItem unlinkItem(
    KnowledgeItem item, {
    required String entityId,
    required LinkedEntityType entityType,
  }) {
    final nextLinks = item.links
        .where(
          (link) =>
              !(link.entityId == entityId && link.entityType == entityType),
        )
        .toList();
    return item.copyWith(links: nextLinks, updatedAt: DateTime.now());
  }

  KnowledgeItem reconcileStaleLinks(
    KnowledgeItem item, {
    required bool Function(LinkedEntityType entityType, String entityId)
    entityExists,
  }) {
    final nextLinks = item.links.map((link) {
      final exists = entityExists(link.entityType, link.entityId);
      return link.copyWith(isStale: !exists);
    }).toList();
    return item.copyWith(links: nextLinks, updatedAt: DateTime.now());
  }
}
