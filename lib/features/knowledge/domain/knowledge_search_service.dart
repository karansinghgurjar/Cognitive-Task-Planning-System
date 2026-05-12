import '../models/knowledge_item.dart';

class KnowledgeSearchQuery {
  const KnowledgeSearchQuery({
    this.text = '',
    this.type,
    this.status,
    this.priority,
    this.tag,
    this.linkedEntityType,
    this.linkedEntityId,
    this.onlyDueReview = false,
    this.onlyStale = false,
  });

  final String text;
  final KnowledgeItemType? type;
  final KnowledgeStatus? status;
  final KnowledgePriority? priority;
  final String? tag;
  final LinkedEntityType? linkedEntityType;
  final String? linkedEntityId;
  final bool onlyDueReview;
  final bool onlyStale;
}

class KnowledgeSearchService {
  const KnowledgeSearchService();

  List<KnowledgeItem> filter(
    List<KnowledgeItem> items, {
    KnowledgeSearchQuery query = const KnowledgeSearchQuery(),
    DateTime? now,
  }) {
    final normalizedText = query.text.trim().toLowerCase();
    final reviewNow = now ?? DateTime.now();

    final filtered = items.where((item) {
      if (query.type != null && item.type != query.type) {
        return false;
      }
      if (query.status != null && item.status != query.status) {
        return false;
      }
      if (query.priority != null && item.priority != query.priority) {
        return false;
      }
      if (query.tag != null &&
          !item.tags.any(
            (tag) => tag.toLowerCase() == query.tag!.toLowerCase(),
          )) {
        return false;
      }
      if (query.linkedEntityType != null) {
        final match = item.links.any((link) {
          if (link.entityType != query.linkedEntityType) {
            return false;
          }
          if (query.linkedEntityId != null) {
            return link.entityId == query.linkedEntityId;
          }
          return true;
        });
        if (!match) {
          return false;
        }
      }
      if (query.onlyDueReview) {
        final dueReviewAt = item.dueReviewAt;
        if (dueReviewAt == null || dueReviewAt.isAfter(reviewNow)) {
          return false;
        }
      }
      if (query.onlyStale && !item.hasStaleLinks) {
        return false;
      }
      if (normalizedText.isEmpty) {
        return true;
      }
      final haystack = [
        item.title,
        item.content ?? '',
        item.sourceUrl ?? '',
        item.externalReference ?? '',
        ...item.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedText);
    }).toList();

    filtered.sort((left, right) {
      final statusCompare = _statusScore(
        left.status,
      ).compareTo(_statusScore(right.status));
      if (statusCompare != 0) {
        return statusCompare;
      }
      final leftUpdated = left.updatedAt ?? left.createdAt;
      final rightUpdated = right.updatedAt ?? right.createdAt;
      return rightUpdated.compareTo(leftUpdated);
    });

    return filtered;
  }

  int _statusScore(KnowledgeStatus status) {
    switch (status) {
      case KnowledgeStatus.inbox:
        return 0;
      case KnowledgeStatus.active:
        return 1;
      case KnowledgeStatus.reviewing:
        return 2;
      case KnowledgeStatus.completed:
        return 3;
      case KnowledgeStatus.archived:
        return 4;
    }
  }
}
