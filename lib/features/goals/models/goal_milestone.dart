import 'package:isar/isar.dart';

part 'goal_milestone.g.dart';

@collection
class GoalMilestone {
  GoalMilestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.description,
    required this.sequenceOrder,
    required this.estimatedMinutes,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String goalId;

  late String title;
  String? description;
  late int sequenceOrder;
  late int estimatedMinutes;
  late bool isCompleted;
  late DateTime createdAt;
  DateTime? completedAt;

  GoalMilestone copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    bool clearDescription = false,
    int? sequenceOrder,
    int? estimatedMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    final milestone = GoalMilestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    )..isarId = isarId;

    return milestone;
  }
}
