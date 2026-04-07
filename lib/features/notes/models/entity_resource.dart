import 'package:isar/isar.dart';

import 'entity_note.dart';

part 'entity_resource.g.dart';

enum EntityResourceType { link, video, article, pdf, repo, book, other }

@collection
class EntityResource {
  EntityResource({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.title,
    this.url,
    this.description,
    this.resourceType = EntityResourceType.other,
    required this.createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index(composite: [CompositeIndex('entityId')])
  @Enumerated(EnumType.name)
  late EntityAttachmentType entityType;

  late String entityId;

  late String title;
  String? url;
  String? description;

  @Enumerated(EnumType.name)
  late EntityResourceType resourceType;

  late DateTime createdAt;
  DateTime? updatedAt;
  late bool isPinned;

  EntityResource copyWith({
    String? id,
    EntityAttachmentType? entityType,
    String? entityId,
    String? title,
    String? url,
    bool clearUrl = false,
    String? description,
    bool clearDescription = false,
    EntityResourceType? resourceType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
    bool? isPinned,
  }) {
    final resource = EntityResource(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      title: title ?? this.title,
      url: clearUrl ? null : url ?? this.url,
      description: clearDescription ? null : description ?? this.description,
      resourceType: resourceType ?? this.resourceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    )..isarId = isarId;

    return resource;
  }
}

extension EntityResourceTypeX on EntityResourceType {
  String get label {
    switch (this) {
      case EntityResourceType.link:
        return 'Link';
      case EntityResourceType.video:
        return 'Video';
      case EntityResourceType.article:
        return 'Article';
      case EntityResourceType.pdf:
        return 'PDF';
      case EntityResourceType.repo:
        return 'Repo';
      case EntityResourceType.book:
        return 'Book';
      case EntityResourceType.other:
        return 'Other';
    }
  }
}
