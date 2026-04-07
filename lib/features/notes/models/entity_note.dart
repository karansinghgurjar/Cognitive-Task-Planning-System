import 'package:isar/isar.dart';

part 'entity_note.g.dart';

enum EntityAttachmentType { task, goal }

@collection
class EntityNote {
  EntityNote({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.title,
    required this.content,
    required this.createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.isArchived = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index(composite: [CompositeIndex('entityId')])
  @Enumerated(EnumType.name)
  late EntityAttachmentType entityType;

  late String entityId;

  String? title;
  late String content;
  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isPinned;
  late bool isArchived;

  EntityNote copyWith({
    String? id,
    EntityAttachmentType? entityType,
    String? entityId,
    String? title,
    bool clearTitle = false,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    bool? isPinned,
    bool? isArchived,
  }) {
    final note = EntityNote(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      title: clearTitle ? null : title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    )..isarId = isarId;

    return note;
  }
}

extension EntityAttachmentTypeX on EntityAttachmentType {
  String get label {
    switch (this) {
      case EntityAttachmentType.task:
        return 'Task';
      case EntityAttachmentType.goal:
        return 'Goal';
    }
  }
}
