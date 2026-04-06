import 'package:isar/isar.dart';

part 'quick_capture_item.g.dart';

enum QuickCaptureSuggestedType { task, goal, note, unknown }

enum QuickCaptureProcessedEntityType { task, goal, note }

@collection
class QuickCaptureItem {
  QuickCaptureItem({
    required this.id,
    required this.rawText,
    required this.createdAt,
    DateTime? updatedAt,
    this.suggestedType = QuickCaptureSuggestedType.unknown,
    this.isProcessed = false,
    this.processedAt,
    this.linkedEntityId,
    this.processedEntityType,
    this.isArchived = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String rawText;
  late DateTime createdAt;
  DateTime? updatedAt;

  @Enumerated(EnumType.name)
  late QuickCaptureSuggestedType suggestedType;

  late bool isProcessed;
  DateTime? processedAt;
  String? linkedEntityId;

  @Enumerated(EnumType.name)
  QuickCaptureProcessedEntityType? processedEntityType;

  late bool isArchived;

  QuickCaptureItem copyWith({
    String? id,
    String? rawText,
    DateTime? createdAt,
    DateTime? updatedAt,
    QuickCaptureSuggestedType? suggestedType,
    bool? isProcessed,
    DateTime? processedAt,
    bool clearProcessedAt = false,
    String? linkedEntityId,
    bool clearLinkedEntityId = false,
    QuickCaptureProcessedEntityType? processedEntityType,
    bool clearProcessedEntityType = false,
    bool? isArchived,
  }) {
    return QuickCaptureItem(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      suggestedType: suggestedType ?? this.suggestedType,
      isProcessed: isProcessed ?? this.isProcessed,
      processedAt: clearProcessedAt ? null : processedAt ?? this.processedAt,
      linkedEntityId: clearLinkedEntityId
          ? null
          : linkedEntityId ?? this.linkedEntityId,
      processedEntityType: clearProcessedEntityType
          ? null
          : processedEntityType ?? this.processedEntityType,
      isArchived: isArchived ?? this.isArchived,
    )..isarId = isarId;
  }
}
