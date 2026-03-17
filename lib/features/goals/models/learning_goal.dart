import 'package:isar/isar.dart';

part 'learning_goal.g.dart';

enum GoalType { learning, project, examPrep, work }

enum GoalStatus { active, completed, paused, archived }

@collection
class LearningGoal {
  LearningGoal({
    required this.id,
    required this.title,
    this.description,
    this.goalType = GoalType.learning,
    this.targetDate,
    required this.priority,
    this.status = GoalStatus.active,
    this.estimatedTotalMinutes,
    required this.createdAt,
    this.completedAt,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late GoalType goalType;

  DateTime? targetDate;
  late int priority;

  @Enumerated(EnumType.name)
  late GoalStatus status;

  int? estimatedTotalMinutes;
  late DateTime createdAt;
  DateTime? completedAt;

  LearningGoal copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    GoalType? goalType,
    DateTime? targetDate,
    bool clearTargetDate = false,
    int? priority,
    GoalStatus? status,
    int? estimatedTotalMinutes,
    bool clearEstimatedTotalMinutes = false,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    final goal = LearningGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      goalType: goalType ?? this.goalType,
      targetDate: clearTargetDate ? null : targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedTotalMinutes: clearEstimatedTotalMinutes
          ? null
          : estimatedTotalMinutes ?? this.estimatedTotalMinutes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    )..isarId = isarId;

    return goal;
  }
}

extension GoalTypeX on GoalType {
  String get label {
    switch (this) {
      case GoalType.learning:
        return 'Learning';
      case GoalType.project:
        return 'Project';
      case GoalType.examPrep:
        return 'Exam Prep';
      case GoalType.work:
        return 'Work';
    }
  }
}

extension GoalStatusX on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.archived:
        return 'Archived';
    }
  }
}
