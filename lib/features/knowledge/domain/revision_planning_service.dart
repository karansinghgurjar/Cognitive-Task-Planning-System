import '../models/knowledge_item.dart';

class RevisionTaskDraft {
  const RevisionTaskDraft({
    required this.title,
    required this.description,
    required this.estimatedDurationMinutes,
    required this.linkedKnowledgeIds,
  });

  final String title;
  final String description;
  final int estimatedDurationMinutes;
  final List<String> linkedKnowledgeIds;
}

class RevisionPlanningService {
  const RevisionPlanningService();

  DateTime nextReviewAt(ReviewDifficulty difficulty, {DateTime? from}) {
    final anchor = from ?? DateTime.now();
    switch (difficulty) {
      case ReviewDifficulty.hard:
        return anchor.add(const Duration(days: 1));
      case ReviewDifficulty.normal:
        return anchor.add(const Duration(days: 3));
      case ReviewDifficulty.easy:
        return anchor.add(const Duration(days: 7));
    }
  }

  KnowledgeItem recordReview(
    KnowledgeItem item,
    ReviewDifficulty difficulty, {
    DateTime? reviewedAt,
  }) {
    final reviewTime = reviewedAt ?? DateTime.now();
    final nextReview = nextReviewAt(difficulty, from: reviewTime);
    final intervalDays = nextReview.difference(reviewTime).inDays;
    return item.copyWith(
      status: KnowledgeStatus.reviewing,
      dueReviewAt: nextReview,
      lastReviewedAt: reviewTime,
      reviewCount: item.reviewCount + 1,
      reviewIntervalDays: intervalDays,
      updatedAt: reviewTime,
    );
  }

  List<KnowledgeItem> dueItems(List<KnowledgeItem> items, {DateTime? now}) {
    final reviewNow = now ?? DateTime.now();
    final due = items.where((item) {
      final dueReviewAt = item.dueReviewAt;
      return dueReviewAt != null && !dueReviewAt.isAfter(reviewNow);
    }).toList();
    due.sort((left, right) {
      final leftDue = left.dueReviewAt!;
      final rightDue = right.dueReviewAt!;
      final dueCompare = leftDue.compareTo(rightDue);
      if (dueCompare != 0) {
        return dueCompare;
      }
      return right.reviewCount.compareTo(left.reviewCount);
    });
    return due;
  }

  RevisionTaskDraft? buildRevisionTaskDraft(
    List<KnowledgeItem> dueItems, {
    String? groupLabel,
  }) {
    if (dueItems.isEmpty) {
      return null;
    }
    final totalMinutes = dueItems.length * 10;
    final label = groupLabel?.trim().isNotEmpty == true
        ? groupLabel!.trim()
        : 'Knowledge';
    return RevisionTaskDraft(
      title: 'Review $label materials',
      description:
          'Review ${dueItems.length} due knowledge items and capture any weak spots.',
      estimatedDurationMinutes: totalMinutes.clamp(15, 90),
      linkedKnowledgeIds: dueItems.map((item) => item.id).toList(),
    );
  }

  Map<String, List<KnowledgeItem>> groupDueItems(
    List<KnowledgeItem> items, {
    String Function(KnowledgeItem item)? grouper,
    DateTime? now,
  }) {
    final grouped = <String, List<KnowledgeItem>>{};
    for (final item in dueItems(items, now: now)) {
      final key = grouper?.call(item) ?? item.type.label;
      grouped.putIfAbsent(key, () => <KnowledgeItem>[]).add(item);
    }
    return grouped;
  }
}
