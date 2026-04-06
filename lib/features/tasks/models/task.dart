import 'package:isar/isar.dart';

part 'task.g.dart';

enum TaskType { study, coding, reading, project, misc }

@collection
class Task {
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.estimatedDurationMinutes,
    this.dueDate,
    required this.priority,
    this.resourceUrl,
    this.resourceTag,
    this.goalId,
    this.milestoneId,
    this.isCompleted = false,
    this.isArchived = false,
    required this.createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.archivedAt,
    this.progressResetAt,
  }) : updatedAt = updatedAt ?? createdAt;

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;
  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late TaskType type;

  late int estimatedDurationMinutes;
  DateTime? dueDate;
  late int priority;
  String? resourceUrl;
  String? resourceTag;
  String? goalId;
  String? milestoneId;
  late bool isCompleted;
  late bool isArchived;
  late DateTime createdAt;
  DateTime? updatedAt;
  DateTime? completedAt;
  DateTime? archivedAt;
  DateTime? progressResetAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    int? estimatedDurationMinutes,
    DateTime? dueDate,
    bool clearDueDate = false,
    int? priority,
    String? resourceUrl,
    bool clearResourceUrl = false,
    String? resourceTag,
    bool clearResourceTag = false,
    String? goalId,
    bool clearGoalId = false,
    String? milestoneId,
    bool clearMilestoneId = false,
    bool? isCompleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    DateTime? progressResetAt,
    bool clearProgressResetAt = false,
  }) {
    final task = Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      resourceUrl: clearResourceUrl ? null : resourceUrl ?? this.resourceUrl,
      resourceTag: clearResourceTag ? null : resourceTag ?? this.resourceTag,
      goalId: clearGoalId ? null : goalId ?? this.goalId,
      milestoneId: clearMilestoneId ? null : milestoneId ?? this.milestoneId,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      archivedAt: clearArchivedAt ? null : archivedAt ?? this.archivedAt,
      progressResetAt: clearProgressResetAt
          ? null
          : progressResetAt ?? this.progressResetAt,
    )..isarId = isarId;

    return task;
  }
}

extension TaskTypeX on TaskType {
  String get label {
    switch (this) {
      case TaskType.study:
        return 'Study';
      case TaskType.coding:
        return 'Coding';
      case TaskType.reading:
        return 'Reading';
      case TaskType.project:
        return 'Project';
      case TaskType.misc:
        return 'Misc';
    }
  }
}
