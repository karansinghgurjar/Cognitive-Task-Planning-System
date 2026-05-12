import 'package:isar/isar.dart';

part 'knowledge_item.g.dart';

enum KnowledgeItemType {
  note,
  resource,
  researchPaper,
  book,
  article,
  video,
  course,
  codeSnippet,
  idea,
  question,
}

enum KnowledgeStatus { inbox, active, reviewing, completed, archived }

enum KnowledgePriority { low, normal, high }

enum LinkedEntityType {
  goal,
  project,
  task,
  routine,
  routineOccurrence,
  focusSession,
  milestone,
}

enum ReviewDifficulty { hard, normal, easy }

@embedded
class EntityLink {
  EntityLink({
    this.entityId = '',
    this.entityType = LinkedEntityType.task,
    this.relationLabel,
    this.isStale = false,
  });

  late String entityId;

  @Enumerated(EnumType.name)
  late LinkedEntityType entityType;

  String? relationLabel;
  late bool isStale;

  EntityLink copyWith({
    String? entityId,
    LinkedEntityType? entityType,
    String? relationLabel,
    bool clearRelationLabel = false,
    bool? isStale,
  }) {
    return EntityLink(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      relationLabel: clearRelationLabel
          ? null
          : relationLabel ?? this.relationLabel,
      isStale: isStale ?? this.isStale,
    );
  }
}

@collection
class KnowledgeItem {
  KnowledgeItem({
    required this.id,
    required this.title,
    this.content,
    this.type = KnowledgeItemType.note,
    this.status = KnowledgeStatus.inbox,
    this.priority = KnowledgePriority.normal,
    required this.createdAt,
    DateTime? updatedAt,
    this.dueReviewAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.reviewIntervalDays,
    this.tags = const <String>[],
    this.sourceUrl,
    this.localFilePath,
    this.externalReference,
    this.links = const <EntityLink>[],
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index(caseSensitive: false)
  late String title;

  String? content;

  @Enumerated(EnumType.name)
  late KnowledgeItemType type;

  @Enumerated(EnumType.name)
  late KnowledgeStatus status;

  @Enumerated(EnumType.name)
  late KnowledgePriority priority;

  late DateTime createdAt;
  DateTime? updatedAt;
  DateTime? dueReviewAt;
  DateTime? lastReviewedAt;
  late int reviewCount;
  int? reviewIntervalDays;
  List<String> tags = <String>[];
  String? sourceUrl;
  String? localFilePath;
  String? externalReference;
  List<EntityLink> links = <EntityLink>[];

  KnowledgeItem copyWith({
    String? id,
    String? title,
    String? content,
    bool clearContent = false,
    KnowledgeItemType? type,
    KnowledgeStatus? status,
    KnowledgePriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    DateTime? dueReviewAt,
    bool clearDueReviewAt = false,
    DateTime? lastReviewedAt,
    bool clearLastReviewedAt = false,
    int? reviewCount,
    int? reviewIntervalDays,
    bool clearReviewIntervalDays = false,
    List<String>? tags,
    String? sourceUrl,
    bool clearSourceUrl = false,
    String? localFilePath,
    bool clearLocalFilePath = false,
    String? externalReference,
    bool clearExternalReference = false,
    List<EntityLink>? links,
  }) {
    final next = KnowledgeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: clearContent ? null : content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      dueReviewAt: clearDueReviewAt ? null : dueReviewAt ?? this.dueReviewAt,
      lastReviewedAt: clearLastReviewedAt
          ? null
          : lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      reviewIntervalDays: clearReviewIntervalDays
          ? null
          : reviewIntervalDays ?? this.reviewIntervalDays,
      tags: tags ?? List<String>.from(this.tags),
      sourceUrl: clearSourceUrl ? null : sourceUrl ?? this.sourceUrl,
      localFilePath: clearLocalFilePath
          ? null
          : localFilePath ?? this.localFilePath,
      externalReference: clearExternalReference
          ? null
          : externalReference ?? this.externalReference,
      links: links ?? List<EntityLink>.from(this.links),
    )..isarId = isarId;
    return next;
  }

  bool get isDueForReview {
    if (dueReviewAt == null) {
      return false;
    }
    return !dueReviewAt!.isAfter(DateTime.now());
  }

  bool get hasStaleLinks => links.any((link) => link.isStale);
}

extension KnowledgeItemTypeX on KnowledgeItemType {
  String get label {
    switch (this) {
      case KnowledgeItemType.note:
        return 'Note';
      case KnowledgeItemType.resource:
        return 'Resource';
      case KnowledgeItemType.researchPaper:
        return 'Research Paper';
      case KnowledgeItemType.book:
        return 'Book';
      case KnowledgeItemType.article:
        return 'Article';
      case KnowledgeItemType.video:
        return 'Video';
      case KnowledgeItemType.course:
        return 'Course';
      case KnowledgeItemType.codeSnippet:
        return 'Code Snippet';
      case KnowledgeItemType.idea:
        return 'Idea';
      case KnowledgeItemType.question:
        return 'Question';
    }
  }
}

extension KnowledgeStatusX on KnowledgeStatus {
  String get label {
    switch (this) {
      case KnowledgeStatus.inbox:
        return 'Inbox';
      case KnowledgeStatus.active:
        return 'Active';
      case KnowledgeStatus.reviewing:
        return 'Reviewing';
      case KnowledgeStatus.completed:
        return 'Completed';
      case KnowledgeStatus.archived:
        return 'Archived';
    }
  }
}

extension KnowledgePriorityX on KnowledgePriority {
  String get label {
    switch (this) {
      case KnowledgePriority.low:
        return 'Low';
      case KnowledgePriority.normal:
        return 'Normal';
      case KnowledgePriority.high:
        return 'High';
    }
  }
}

extension LinkedEntityTypeX on LinkedEntityType {
  String get label {
    switch (this) {
      case LinkedEntityType.goal:
        return 'Goal';
      case LinkedEntityType.project:
        return 'Project';
      case LinkedEntityType.task:
        return 'Task';
      case LinkedEntityType.routine:
        return 'Routine';
      case LinkedEntityType.routineOccurrence:
        return 'Routine Occurrence';
      case LinkedEntityType.focusSession:
        return 'Focus Session';
      case LinkedEntityType.milestone:
        return 'Milestone';
    }
  }
}

extension ReviewDifficultyX on ReviewDifficulty {
  String get label {
    switch (this) {
      case ReviewDifficulty.hard:
        return 'Hard';
      case ReviewDifficulty.normal:
        return 'Normal';
      case ReviewDifficulty.easy:
        return 'Easy';
    }
  }
}
